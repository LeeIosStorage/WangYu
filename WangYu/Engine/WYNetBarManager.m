//
//  WYNetBarManager.m
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYNetBarManager.h"
#import "WYEngine.h"
#import "PathHelper.h"

static WYNetBarManager* _shareInstance = nil;

@interface WYNetBarManager (){
    
}
@end

@implementation WYNetBarManager

+ (WYNetBarManager*)shareInstance{
    @synchronized(self) {
        if (_shareInstance == nil) {
            _shareInstance = [[WYNetBarManager alloc] init];
        }
    }
    return _shareInstance;
}

//关联用户的
- (NSString *)getAccoutStorePath{
    NSString *filePath = [[WYEngine shareInstance] getCurrentAccoutDocDirectory];
    return filePath;
}
//无关用户
- (NSString *)getStorePath{
    NSString *filePath = [PathHelper documentDirectoryPathWithName:@"netBar"];
    return filePath;
}

- (NSMutableArray *)getHistorySearchRecord{
    
    NSString *path = [[self getStorePath] stringByAppendingPathComponent:@"historySearchRecord.xml"];
    NSMutableArray* array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return array;
    
}
- (NSMutableArray *)addSaveHistorySearchRecord:(NSString *)record{
    
    NSMutableArray* array = [self getHistorySearchRecord];
    if (array == nil) {
        array = [[NSMutableArray alloc] init];
    }
    for (NSString *info in array) {
        if ([info isEqualToString:record]) {
            [array removeObject:info];
            break;
        }
    }
    [array insertObject:record atIndex:0];
    NSMutableArray* groupsJson = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSString* info in array) {
        [groupsJson addObject:info];
    }
    NSString* path = [[self getStorePath] stringByAppendingPathComponent:@"historySearchRecord.xml"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [groupsJson writeToFile:path atomically:YES];
    });
    return array;
}
- (void)removeHistorySearchRecord{
    NSString* path = [[self getStorePath] stringByAppendingPathComponent:@"historySearchRecord.xml"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    });
}
@end
