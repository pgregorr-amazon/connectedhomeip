/**
 *    Copyright (c) 2025 Project CHIP Authors
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

#import <Matter/Matter.h>

#import "MTRDeviceDataValidation.h"
#import "MTRLogging_Internal.h"
#import "MTRUtilities.h"

@implementation MTRCommandWithRequiredResponse
- (instancetype)initWithPath:(MTRCommandPath *)path
               commandFields:(nullable NSDictionary<NSString *, id> *)commandFields
            requiredResponse:(nullable NSDictionary<NSNumber *, NSDictionary<NSString *, id> *> *)requiredResponse
{
    if (self = [super init]) {
        self.path = path;
        self.commandFields = commandFields;
        self.requiredResponse = requiredResponse;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[MTRCommandWithRequiredResponse alloc] initWithPath:self.path commandFields:self.commandFields requiredResponse:self.requiredResponse];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, path: %@, fields: %@, requiredResponse: %@", NSStringFromClass(self.class), self, self.path, self.commandFields, self.requiredResponse];
}

#pragma mark - MTRCommandWithRequiredResponse NSSecureCoding implementation

static NSString * const sPathKey = @"pathKey";
static NSString * const sFieldsKey = @"fieldsKey";
static NSString * const sExpectedResultKey = @"requiredResponseKey";

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _path = [decoder decodeObjectOfClass:MTRCommandPath.class forKey:sPathKey];
    if (!_path || ![_path isKindOfClass:MTRCommandPath.class]) {
        MTR_LOG_ERROR("MTRCommandWithRequiredResponse decoded %@ for endpoint, not MTRCommandPath.", _path);
        return nil;
    }

    // The classes of things that can appear in a data-value dictionary.
    static NSSet * const sDataValueClasses = [NSSet setWithArray:@[ NSDictionary.class, NSArray.class, NSData.class, NSString.class, NSNumber.class ]];

    // Unfortunately, decodeDictionaryWithKeysOfClasses:objectsOfClasses:forKey:
    // does not work when the objects stored in the dictionary can include
    // collections, so we have to use decodeObjectOfClasses: and then manually
    // validate we got a dictionary.
    _commandFields = [decoder decodeObjectOfClasses:sDataValueClasses forKey:sFieldsKey];
    if (_commandFields) {
        if (![_commandFields isKindOfClass:NSDictionary.class]) {
            MTR_LOG_ERROR("MTRCommandWithRequiredResponse decoded %@ for commandFields, not NSDictionary.", _commandFields);
            return nil;
        }

        if (!MTRDataValueDictionaryIsWellFormed(_commandFields) || ![MTRStructureValueType isEqual:_commandFields[MTRTypeKey]]) {
            MTR_LOG_ERROR("MTRCommandWithRequiredResponse decoded %@ for commandFields, not a structure-typed data-value dictionary.", _commandFields);
            return nil;
        }
    }

    _requiredResponse = [decoder decodeObjectOfClasses:sDataValueClasses forKey:sExpectedResultKey];
    if (_requiredResponse) {
        if (![_requiredResponse isKindOfClass:NSDictionary.class]) {
            MTR_LOG_ERROR("MTRCommandWithRequiredResponse decoded %@ for requiredResponse, not NSDictionary.", _requiredResponse);
            return nil;
        }

        for (id key in _requiredResponse) {
            if (![key isKindOfClass:NSNumber.class]) {
                MTR_LOG_ERROR("MTRCommandWithRequiredResponse decoded key %@ in requiredResponse", key);
                return nil;
            }

            if (![_requiredResponse[key] isKindOfClass:NSDictionary.class] || !MTRDataValueDictionaryIsWellFormed(_requiredResponse[key])) {
                MTR_LOG_ERROR("MTRCommandWithRequiredResponse decoded value %@ for key %@ in requiredResponse", _requiredResponse[key], key);
                return nil;
            }
        }
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    // In theory path is not nullable, but we don't really enforce that in init.
    if (self.path) {
        [coder encodeObject:self.path forKey:sPathKey];
    }
    if (self.commandFields) {
        [coder encodeObject:self.commandFields forKey:sFieldsKey];
    }
    if (self.requiredResponse) {
        [coder encodeObject:self.requiredResponse forKey:sExpectedResultKey];
    }
}

- (BOOL)_isEqualToOther:(MTRCommandWithRequiredResponse *)other
{
    return MTREqualObjects(_path, other.path)
        && MTREqualObjects(_commandFields, other.commandFields)
        && MTREqualObjects(_requiredResponse, other.requiredResponse);
}

- (BOOL)isEqual:(id)object
{
    if ([object class] != [self class]) {
        return NO;
    }
    return [self _isEqualToOther:object];
}

@end
