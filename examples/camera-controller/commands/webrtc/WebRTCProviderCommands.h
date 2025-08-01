/*
 *   Copyright (c) 2025 Project CHIP Authors
 *   All rights reserved.
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 */

#pragma once

#include <commands/common/CHIPCommand.h>
#include <device-manager/DeviceManager.h>

namespace webrtc {

class ConnectCommand : public CHIPCommand
{
public:
    ConnectCommand(CredentialIssuerCommands * credIssuerCommands) : CHIPCommand("connect", credIssuerCommands)
    {
        AddArgument("node-id", 0, UINT64_MAX, &mPeerNodeId);
        AddArgument("endpointid", 0, UINT16_MAX, &mPeerEndpointId);
    }

    /////////// CHIPCommand Interface /////////
    CHIP_ERROR RunCommand() override;

    chip::System::Clock::Timeout GetWaitDuration() const override { return chip::System::Clock::Seconds16(1); }

private:
    chip::NodeId mPeerNodeId         = chip::kUndefinedNodeId;
    chip::EndpointId mPeerEndpointId = chip::kInvalidEndpointId;
};

class ProvideOfferCommand : public CHIPCommand
{
public:
    ProvideOfferCommand(CredentialIssuerCommands * credIssuerCommands) : CHIPCommand("provide-offer", credIssuerCommands)
    {
        AddArgument("stream-usage", 0, UINT8_MAX, &mStreamUsage);
        AddArgument("webrtc-session-id", 0, UINT16_MAX, &mWebRTCSessionId);
        AddArgument("video-stream-id", 0, UINT16_MAX, &mVideoStreamId);
        AddArgument("audio-stream-id", 0, UINT16_MAX, &mAudioStreamId);
    }

    /////////// CHIPCommand Interface /////////
    CHIP_ERROR RunCommand() override;

    chip::System::Clock::Timeout GetWaitDuration() const override { return chip::System::Clock::Seconds16(1); }

private:
    uint8_t mStreamUsage = 0;
    chip::Optional<uint16_t> mWebRTCSessionId;
    chip::Optional<uint16_t> mVideoStreamId;
    chip::Optional<uint16_t> mAudioStreamId;
};

class SolicitOfferCommand : public CHIPCommand
{
public:
    SolicitOfferCommand(CredentialIssuerCommands * credIssuerCommands) : CHIPCommand("solicit-offer", credIssuerCommands)
    {
        AddArgument("stream-usage", 0, UINT8_MAX, &mStreamUsage);
        AddArgument("video-stream-id", 0, UINT16_MAX, &mVideoStreamId);
        AddArgument("audio-stream-id", 0, UINT16_MAX, &mAudioStreamId);
    }

    /////////// CHIPCommand Interface /////////
    CHIP_ERROR RunCommand() override;

    chip::System::Clock::Timeout GetWaitDuration() const override { return chip::System::Clock::Seconds16(1); }

private:
    uint8_t mStreamUsage = 0;
    chip::Optional<uint16_t> mVideoStreamId;
    chip::Optional<uint16_t> mAudioStreamId;
};

class EstablishSessionCommand : public CHIPCommand
{
public:
    EstablishSessionCommand(CredentialIssuerCommands * credIssuerCommands) : CHIPCommand("establish-session", credIssuerCommands)
    {
        AddArgument("node-id", 0, UINT64_MAX, &mPeerNodeId);
        AddArgument("offer-type", 0, 1, &mOfferType, "WebRTC offer type: 0=ProvideOffer (default), 1=SolicitOffer");
    }

    /////////// CHIPCommand Interface /////////
    CHIP_ERROR RunCommand() override;

    chip::System::Clock::Timeout GetWaitDuration() const override { return chip::System::Clock::Seconds16(5); }

private:
    chip::NodeId mPeerNodeId = chip::kUndefinedNodeId;
    chip::Optional<uint8_t> mOfferType;
};

} // namespace webrtc
