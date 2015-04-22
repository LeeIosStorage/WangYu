//
//  PathHelper.h
//  WangYu
//
//  Created by KID on 14/12/31.
//
//

#import <Foundation/Foundation.h>

@interface PathHelper : NSObject

+ (BOOL)documentDirectoryPathIsExist:(NSString*)name;

+ (BOOL)createPathIfNecessary:(NSString*)path;

+ (NSString*)documentDirectoryPathWithName:(NSString*)name;

+ (NSString*)cacheDirectoryPathWithName:(NSString*)name;

@end
