/*
 *
 *    Copyright (c) 2022 Project CHIP Authors
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

// THIS FILE IS GENERATED BY ZAP
// This file is generated from clusters-Commands.h.zapt

#pragma once

#include <app/data-model/DecodableList.h>
#include <app/data-model/Encode.h>
#include <app/data-model/List.h>
#include <app/data-model/NullObject.h>
#include <app/data-model/Nullable.h>
#include <lib/core/DataModelTypes.h>
#include <lib/core/Optional.h>
#include <lib/core/TLV.h>
#include <lib/support/BitMask.h>

#include <clusters/shared/Enums.h>
#include <clusters/shared/Structs.h>

#include <clusters/ClosureControl/ClusterId.h>
#include <clusters/ClosureControl/CommandIds.h>
#include <clusters/ClosureControl/Enums.h>
#include <clusters/ClosureControl/Structs.h>

#include <cstdint>

namespace chip {
namespace app {
namespace Clusters {
namespace ClosureControl {
namespace Commands {
// Forward-declarations so we can reference these later.

namespace Stop {
struct Type;
struct DecodableType;
} // namespace Stop

namespace MoveTo {
struct Type;
struct DecodableType;
} // namespace MoveTo

namespace Calibrate {
struct Type;
struct DecodableType;
} // namespace Calibrate

} // namespace Commands

namespace Commands {
namespace Stop {
enum class Fields : uint8_t
{
};

struct Type
{
public:
    // Use GetCommandId instead of commandId directly to avoid naming conflict with CommandIdentification in ExecutionOfACommand
    static constexpr CommandId GetCommandId() { return Commands::Stop::Id; }
    static constexpr ClusterId GetClusterId() { return Clusters::ClosureControl::Id; }

    CHIP_ERROR Encode(TLV::TLVWriter & aWriter, TLV::Tag aTag) const;

    using ResponseType = DataModel::NullObjectType;

    static constexpr bool MustUseTimedInvoke() { return false; }
};

struct DecodableType
{
public:
    static constexpr CommandId GetCommandId() { return Commands::Stop::Id; }
    static constexpr ClusterId GetClusterId() { return Clusters::ClosureControl::Id; }
    static constexpr bool kIsFabricScoped = false;

    CHIP_ERROR Decode(TLV::TLVReader & reader);
};
}; // namespace Stop
namespace MoveTo {
enum class Fields : uint8_t
{
    kPosition = 0,
    kLatch    = 1,
    kSpeed    = 2,
};

struct Type
{
public:
    // Use GetCommandId instead of commandId directly to avoid naming conflict with CommandIdentification in ExecutionOfACommand
    static constexpr CommandId GetCommandId() { return Commands::MoveTo::Id; }
    static constexpr ClusterId GetClusterId() { return Clusters::ClosureControl::Id; }

    Optional<TargetPositionEnum> position;
    Optional<bool> latch;
    Optional<Globals::ThreeLevelAutoEnum> speed;

    CHIP_ERROR Encode(TLV::TLVWriter & aWriter, TLV::Tag aTag) const;

    using ResponseType = DataModel::NullObjectType;

    static constexpr bool MustUseTimedInvoke() { return true; }
};

struct DecodableType
{
public:
    static constexpr CommandId GetCommandId() { return Commands::MoveTo::Id; }
    static constexpr ClusterId GetClusterId() { return Clusters::ClosureControl::Id; }
    static constexpr bool kIsFabricScoped = false;

    Optional<TargetPositionEnum> position;
    Optional<bool> latch;
    Optional<Globals::ThreeLevelAutoEnum> speed;

    CHIP_ERROR Decode(TLV::TLVReader & reader);
};
}; // namespace MoveTo
namespace Calibrate {
enum class Fields : uint8_t
{
};

struct Type
{
public:
    // Use GetCommandId instead of commandId directly to avoid naming conflict with CommandIdentification in ExecutionOfACommand
    static constexpr CommandId GetCommandId() { return Commands::Calibrate::Id; }
    static constexpr ClusterId GetClusterId() { return Clusters::ClosureControl::Id; }

    CHIP_ERROR Encode(TLV::TLVWriter & aWriter, TLV::Tag aTag) const;

    using ResponseType = DataModel::NullObjectType;

    static constexpr bool MustUseTimedInvoke() { return true; }
};

struct DecodableType
{
public:
    static constexpr CommandId GetCommandId() { return Commands::Calibrate::Id; }
    static constexpr ClusterId GetClusterId() { return Clusters::ClosureControl::Id; }
    static constexpr bool kIsFabricScoped = false;

    CHIP_ERROR Decode(TLV::TLVReader & reader);
};
}; // namespace Calibrate
} // namespace Commands
} // namespace ClosureControl
} // namespace Clusters
} // namespace app
} // namespace chip
