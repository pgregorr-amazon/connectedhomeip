/**
 *
 *    Copyright (c) 2020-2022 Project CHIP Authors
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

#import <Foundation/Foundation.h>

#import "MTRCastingPlayer.h"

@implementation MTRCastingPlayer

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ with Product ID: %@ and Vendor ID: %@", _name, _productId, _vendorId];
}

- (BOOL)isEqualToMTRCastingPlayer:(MTRCastingPlayer *)other
{
    return [self.identifier isEqualToString:other.identifier];
}

- (BOOL)isEqual:(id)other
{
    if (other == nil) {
        return NO;
    }

    if (self == other) {
        return YES;
    }

    if (![other isKindOfClass:[MTRCastingPlayer class]]) {
        return NO;
    }

    return [self isEqualToMTRCastingPlayer:(MTRCastingPlayer *) other];
}

- (NSUInteger)hash
{
    const NSUInteger prime = 31;
    NSUInteger result = 1;

    result = prime * result + [self.identifier hash];

    return result;
}

//- (void)connectWithTimeout:(long)timeout withCompletionBlock:(void (^_Nonnull __strong)(NSError * _Nullable __strong))completion
//{
//    // TODO: replace stub implementation
//}

//- (void)disconnect
//{
//    // TODO: replace stub implementation
//}

@end
