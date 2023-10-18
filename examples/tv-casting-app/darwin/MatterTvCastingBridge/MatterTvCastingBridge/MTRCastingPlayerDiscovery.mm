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

#import "MTRCastingPlayerDiscovery.h"
#import <Foundation/Foundation.h>

@implementation MTRCastingPlayerDiscovery

NSString * const didAddCastingPlayersNotification = @"didAddCastingPlayersNotification";
NSString * const didRemoveCastingPlayersNotification = @"didRemoveCastingPlayersNotification";
NSString * const didUpdateCastingPlayersNotification = @"didUpdateCastingPlayersNotification";
NSString * const castingPlayersUserInfo = @"castingPlayers";

+ (MTRCastingPlayerDiscovery * _Nonnull)sharedInstance
{
    static MTRCastingPlayerDiscovery * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)start
{
    // TODO: replace stub implementation
}

- (void)stop
{
    // TODO: replace stub implementation
}

@end
