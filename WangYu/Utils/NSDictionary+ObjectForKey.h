//
//  NSDictionary+ObjectForKey.h
//  WangYu
//
//  Created by KID on 14/12/31.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ObjectForKey)

- (NSString*)stringObjectForKey:(id)aKey;

- (int)intValueForKey:(id)aKey;

- (float)floatValueForKey:(id)aKey;

- (double)doubleValueForKey:(id)aKey;

- (long) longValueForKey:(id) aKey;

- (BOOL)boolValueForKey:(id)aKey;

- (long long) longLongValueForKey:(id) aKey;

- (unsigned long long) unsignedLongLongValueForKey:(id) aKey;

- (NSArray*)arrayObjectForKey:(id)aKey;

- (NSDictionary*)dictionaryObjectForKey:(id)aKey;

- (NSUInteger)unsignedIntegerValueForKey:(id) aKey;

@end
