//
//  PathHelper.m
//  WangYu
//
//  Created by KID on 14/12/31.
//
//

#import "PathHelper.h"

@implementation PathHelper

///////////////////////////////////////////////////////////////////////////////////////////////////
//判断目录是否存在
+ (BOOL)documentDirectoryPathIsExist:(NSString*)name
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    
    if(name != nil)
        path = [path stringByAppendingPathComponent:name];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:path];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL)createPathIfNecessary:(NSString*)path {
    BOOL succeeded = YES;
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path]) {
        succeeded = [fm createDirectoryAtPath: path
                  withIntermediateDirectories: YES
                                   attributes: nil
                                        error: nil];
    }
    
    return succeeded;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)documentDirectoryPathWithName:(NSString*)name {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    
    if(name != nil)
        path = [path stringByAppendingPathComponent:name];
    
    [PathHelper createPathIfNecessary:path];
    
    return path;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)cacheDirectoryPathWithName:(NSString*)name {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [paths objectAtIndex:0];
    
    if(name != nil)
        cachePath = [cachePath stringByAppendingPathComponent:name];
    
    [PathHelper createPathIfNecessary:cachePath];
    
    return cachePath;
}


@end
