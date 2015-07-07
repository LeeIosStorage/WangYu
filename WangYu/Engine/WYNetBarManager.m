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
#import "WYNetbarInfo.h"
#import "JSONKit.h"

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


//网吧搜索页缓存
- (void)saveAllCacheNetbars:(NSMutableArray *)netbarsArray{
    NSMutableArray *cacheNetbars = [[NSMutableArray alloc] initWithCapacity:netbarsArray.count];
    for (WYNetbarInfo* netbar in netbarsArray) {
        if (netbar.netbarInfoByJsonDic) {
            [cacheNetbars addObject:netbar.netbarInfoByJsonDic];
        }
    }
    NSString* path = [[self getStorePath] stringByAppendingPathComponent:@"allCacheNetbar.xml"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cacheNetbars writeToFile:path atomically:YES];
    });
    
}

- (NSArray *)getAllCacheNetbars{
    NSString* path = [[self getStorePath] stringByAppendingPathComponent:@"allCacheNetbar.xml"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//    });
    NSMutableArray* array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if (array) {
        NSMutableArray* cacheNetbars = [[NSMutableArray alloc] initWithCapacity:array.count];
        for (id item in array) {
            WYNetbarInfo* netbar = [[WYNetbarInfo alloc] init];
            NSDictionary *contentDic = item;
            if ([item isKindOfClass:[NSString class]]) {
                contentDic = [item objectFromJSONString];
            }
            [netbar setNetbarInfoByJsonDic:contentDic];
            [cacheNetbars addObject:netbar];
        }
        return cacheNetbars;
    }
    return nil;
}

- (void)removeAllCacheNetbars{
    NSString* path = [[self getStorePath] stringByAppendingPathComponent:@"allCacheNetbar.xml"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    });
}

//首页推荐网吧缓存
- (NSString*)getRecommendNetbarPath{
    NSString *filePath = [[self getStorePath] stringByAppendingPathComponent:@"recommendCacheNetbar.xml"];
    return filePath;
}
- (void)saveRecommendCacheNetbars:(NSMutableArray *)netbarsArray{
    NSMutableArray *cacheNetbars = [[NSMutableArray alloc] initWithCapacity:netbarsArray.count];
    for (WYNetbarInfo* netbar in netbarsArray) {
        if (netbar.netbarInfoByJsonDic) {
            [cacheNetbars addObject:netbar.netbarInfoByJsonDic];
        }
    }
    NSString* path = [self getRecommendNetbarPath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cacheNetbars writeToFile:path atomically:YES];
    });
}
- (NSArray *)getRecommendCacheNetbars{
    NSString* path = [self getRecommendNetbarPath];
    NSMutableArray* array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if (array) {
        NSMutableArray* cacheNetbars = [[NSMutableArray alloc] initWithCapacity:array.count];
        for (id item in array) {
            WYNetbarInfo* netbar = [[WYNetbarInfo alloc] init];
            NSDictionary *contentDic = item;
            if ([item isKindOfClass:[NSString class]]) {
                contentDic = [item objectFromJSONString];
            }
            [netbar setNetbarInfoByJsonDic:contentDic];
            [cacheNetbars addObject:netbar];
        }
        return cacheNetbars;
    }
    return nil;
}
- (void)removeRecommendCacheNetbars{
    NSString* path = [self getRecommendNetbarPath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    });
}

@end
