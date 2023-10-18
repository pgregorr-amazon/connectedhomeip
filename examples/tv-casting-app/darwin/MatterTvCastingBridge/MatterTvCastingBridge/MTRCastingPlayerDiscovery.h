/**
 *
 *    Copyright (c) 2020-2023 Project CHIP Authors
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

#import "MTRCastingPlayer.h"

#ifndef MTRCastingPlayerDiscovery_h
#define MTRCastingPlayerDiscovery_h

NSString * _Nonnull const MTRCastingPlayerDiscoveryPlayersDidUpdateNotification
    = @"MTRCastingPlayerDiscoveryPlayersDidUpdateNotification";
extern NSString * _Nonnull const didAddCastingPlayersNotification;
extern NSString * _Nonnull const didRemoveCastingPlayersNotification;
extern NSString * _Nonnull const didUpdateCastingPlayersNotification;
extern NSString * _Nonnull const castingPlayersUserInfo;

@interface MTRCastingPlayerDiscovery : NSObject
+ (MTRCastingPlayerDiscovery * _Nonnull)sharedInstance;

- (nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, strong) NSArray<MTRCastingPlayer *> * _Nonnull castingPlayers;

- (void)start;

- (void)stop;

@end

#endif /* MTRCastingPlayerDiscovery_h */
