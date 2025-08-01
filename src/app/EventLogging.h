/*
 *
 *    Copyright (c) 2021 Project CHIP Authors
 *    All rights reserved.
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

#pragma once

#include <app/ConcreteEventPath.h>
#include <app/EventLoggingDelegate.h>
#include <app/EventManagement.h>
#include <app/data-model/Encode.h>
#include <app/data-model/FabricScoped.h>
#include <app/data-model/List.h> // So we can encode lists
#include <lib/core/DataModelTypes.h>

namespace chip {
namespace app {

template <typename T>
class EventLogger : public EventLoggingDelegate
{
public:
    EventLogger(const T & aEventData) : mEventData(aEventData){};
    CHIP_ERROR WriteEvent(chip::TLV::TLVWriter & aWriter) final override
    {
        return DataModel::Encode(aWriter, TLV::ContextTag(EventDataIB::Tag::kData), mEventData);
    }

private:
    const T & mEventData;
};

/**
 * @brief
 *   Log an event via a EventLoggingDelegate, with options.
 *
 * The EventLoggingDelegate writes the event metadata and calls the `apDelegate`
 * with an TLV::TLVWriter reference so that the user code can emit
 * the event data directly into the event log.  This form of event
 * logging minimizes memory consumption, as event data is serialized
 * directly into the target buffer.  The event data MUST contain
 * context tags to be interpreted within the schema identified by
 * `ClusterID` and `EventId`.
 *
 * The consumer has to either lock the Matter stack lock or queue the event to
 * the Matter event queue when using LogEvent. This function is not safe to call
 * outside of the main Matter processing context.
 *
 * @param[in] aEventData  The event cluster object
 * @param[in] aEndpoint    The current cluster's Endpoint Id
 * @param[out] aEventNumber The event Number if the event was written to the
 *                         log, 0 otherwise. The Event number is expected to monotonically increase.
 *
 * @return CHIP_ERROR  CHIP Error Code
 */
template <typename T>
CHIP_ERROR LogEvent(const T & aEventData, EndpointId aEndpoint, EventNumber & aEventNumber)
{
    EventLogger<T> eventData(aEventData);

    EventOptions eventOptions;
    eventOptions.mPath     = ConcreteEventPath(aEndpoint, aEventData.GetClusterId(), aEventData.GetEventId());
    eventOptions.mPriority = aEventData.GetPriorityLevel();

    if constexpr (DataModel::IsFabricScoped<T>::value)
    {
        eventOptions.mFabricIndex = aEventData.GetFabricIndex();
        // A fabric-sensitive event must be associated with a fabric to make sense.
        VerifyOrReturnError(eventOptions.mFabricIndex != kUndefinedFabricIndex, CHIP_ERROR_INVALID_FABRIC_INDEX);
    }

    return EventManagement::GetInstance().LogEvent(&eventData, eventOptions, aEventNumber);
}

} // namespace app
} // namespace chip
