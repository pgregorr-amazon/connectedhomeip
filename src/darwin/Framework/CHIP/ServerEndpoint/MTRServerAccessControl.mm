/**
 *    Copyright (c) 2024 Project CHIP Authors
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#import "MTRServerAccessControl.h"

#import <Matter/MTRAccessGrant.h>
#import <Matter/MTRBaseDevice.h> // for MTRClusterPath
#import <Matter/MTRClusterConstants.h> // For MTRClusterIDTypeDescriptorID
#import <Matter/MTRDeviceControllerFactory.h>

#import "MTRDeviceControllerFactory_Internal.h"
#import "MTRLogging_Internal.h"

#include <access/AccessControl.h>
#include <access/Privilege.h>
#include <access/ProviderDeviceTypeResolver.h>
#include <access/RequestPath.h>
#include <access/SubjectDescriptor.h>
#include <app/InteractionModelEngine.h>
#include <lib/core/CHIPError.h>
#include <lib/core/CHIPVendorIdentifiers.hpp>
#include <lib/core/DataModelTypes.h>
#include <lib/core/Global.h>
#include <lib/core/NodeId.h>

#include <app/util/privilege-storage.h>

using namespace chip;
using namespace chip::Access;

namespace {

class DeviceTypeResolver : public chip::Access::DynamicProviderDeviceTypeResolver {
public:
    DeviceTypeResolver()
        : chip::Access::DynamicProviderDeviceTypeResolver(
            [] { return chip::app::InteractionModelEngine::GetInstance()->GetDataModelProvider(); })
    {
    }
};

class AccessControlDelegate : public AccessControl::Delegate {
    CHIP_ERROR Check(const SubjectDescriptor & subjectDescriptor, const RequestPath & requestPath,
        Privilege requestPrivilege) override
    {
        auto * clusterPath = [MTRClusterPath clusterPathWithEndpointID:@(requestPath.endpoint) clusterID:@(requestPath.cluster)];
        auto * grants = [[MTRDeviceControllerFactory sharedInstance] accessGrantsForFabricIndex:subjectDescriptor.fabricIndex clusterPath:clusterPath];

        for (MTRAccessGrant * grant in grants) {
            if (!GrantSubjectMatchesDescriptor(grant, subjectDescriptor)) {
                continue;
            }

            // Check whether the desired privilege is granted.  See the Access Control "Overall
            // Algorithm" section in the spec for which privileges imply which other privileges.
            switch (grant.grantedPrivilege) {
            case MTRAccessControlEntryPrivilegeView:
                if (requestPrivilege == Privilege::kView) {
                    return CHIP_NO_ERROR;
                }
                break;
            case MTRAccessControlEntryPrivilegeProxyView:
                if (requestPrivilege == Privilege::kView || requestPrivilege == Privilege::kProxyView) {
                    return CHIP_NO_ERROR;
                }
                break;
            case MTRAccessControlEntryPrivilegeOperate:
                if (requestPrivilege == Privilege::kView || requestPrivilege == Privilege::kOperate) {
                    return CHIP_NO_ERROR;
                }
                break;
            case MTRAccessControlEntryPrivilegeManage:
                if (requestPrivilege == Privilege::kView || requestPrivilege == Privilege::kOperate || requestPrivilege == Privilege::kManage) {
                    return CHIP_NO_ERROR;
                }
                break;
            case MTRAccessControlEntryPrivilegeAdminister:
                if (requestPrivilege == Privilege::kView || requestPrivilege == Privilege::kProxyView || requestPrivilege == Privilege::kOperate || requestPrivilege == Privilege::kManage || requestPrivilege == Privilege::kAdminister) {
                    return CHIP_NO_ERROR;
                }
                break;
            default:
                MTR_LOG_ERROR("Unknown granted privilege %u, ignoring", grant.grantedPrivilege);
                break;
            }

            // If this grant did not match, just move on to the next one.
        }

        // None of the grants matched.
        return CHIP_ERROR_ACCESS_DENIED;
    }

    bool GrantSubjectMatchesDescriptor(MTRAccessGrant * grant, const SubjectDescriptor & descriptor)
    {
        if (grant.subjectID == nil) {
            // This is an all-nodes grant for CASE access only.
            return descriptor.authMode == AuthMode::kCase;
        }

        NodeId grantSubjectNodeId = grant.subjectID.unsignedLongLongValue;
        if (IsOperationalNodeId(grantSubjectNodeId)) {
            return descriptor.authMode == AuthMode::kCase && descriptor.subject == grantSubjectNodeId;
        }

        if (IsGroupId(grantSubjectNodeId)) {
            return descriptor.authMode == AuthMode::kGroup && descriptor.subject == grantSubjectNodeId;
        }

        if (IsCASEAuthTag(grantSubjectNodeId)) {
            return descriptor.cats.CheckSubjectAgainstCATs(grantSubjectNodeId);
        }

        MTR_LOG_ERROR("Unexpected grant subject: 0x%llx", grantSubjectNodeId);
        return false;
    }
};

struct ControllerAccessControl {
    DeviceTypeResolver mDeviceTypeResolver;
    AccessControlDelegate mDelegate;
    ControllerAccessControl() { GetAccessControl().Init(&mDelegate, mDeviceTypeResolver); }
};

Global<ControllerAccessControl> gControllerAccessControl;

} // anonymous namespace

Privilege MatterGetAccessPrivilegeForReadEvent(ClusterId cluster, EventId event)
{
    // We don't support any event bits yet.
    return Privilege::kAdminister;
}

Privilege MatterGetAccessPrivilegeForInvokeCommand(ClusterId cluster, CommandId command)
{
    // For now we only have OTA, which uses Operate.
    return Privilege::kOperate;
}

Privilege MatterGetAccessPrivilegeForReadAttribute(ClusterId cluster, AttributeId attribute)
{
    NSNumber * _Nullable neededPrivilege = [[MTRDeviceControllerFactory sharedInstance] neededReadPrivilegeForClusterID:@(cluster) attributeID:@(attribute)];
    if (neededPrivilege == nil) {
        // No privileges declared for this attribute on this cluster.

        // In some cases, we know based on the spec what the answer is, and our
        // API clients my not be able to provide explicit privileges for
        // these cases because our API surface does not allow them to create
        // custom attribute definitions for them.

        // (1) Global attributes always require View privilege to read.
        if (IsGlobalAttribute(attribute)) {
            return Privilege::kView;
        }

        // (2) All standard descriptor attributes just require View privilege to read.
        if (cluster == MTRClusterIDTypeDescriptorID && ExtractVendorFromMEI(attribute) == VendorId::Common) {
            return Privilege::kView;
        }

        // Treat as "needs admin privileges", so we fail closed.
        return Privilege::kAdminister;
    }

    switch (neededPrivilege.unsignedLongLongValue) {
    case MTRAccessControlEntryPrivilegeView:
        return Privilege::kView;
    case MTRAccessControlEntryPrivilegeOperate:
        return Privilege::kOperate;
    case MTRAccessControlEntryPrivilegeManage:
        return Privilege::kManage;
    case MTRAccessControlEntryPrivilegeAdminister:
        return Privilege::kAdminister;
    case MTRAccessControlEntryPrivilegeProxyView:
        // Just treat this as an unknown value; there is no value for this in privilege-storage.
        FALLTHROUGH;
    default:
        break;
    }

    // To be safe, treat unknown values as "needs admin privileges".  That way the failure case
    // disallows access that maybe should be allowed, instead of allowing access that maybe
    // should be disallowed.
    return Privilege::kAdminister;
}

Privilege MatterGetAccessPrivilegeForWriteAttribute(ClusterId cluster, AttributeId attribute)
{
    // We don't have any writable attributes yet, but default to Operate.
    return Privilege::kOperate;
}

void InitializeServerAccessControl()
{
    assertChipStackLockedByCurrentThread();

    // Ensure the access control bits are created.  No-op after the first call.
    gControllerAccessControl.get();
}
