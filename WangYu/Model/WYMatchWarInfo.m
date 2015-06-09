//
//  WYMatchWarInfo.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMatchWarInfo.h"
#import "WYEngine.h"

@implementation WYMatchWarInfo

- (void)doSetMatchWarInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"title"]) {
        _title = [dic stringObjectForKey:@"title"];
    }
    if ([dic stringObjectForKey:@"releaser"]) {
        _releaser = [dic stringObjectForKey:@"releaser"];
    }
    if ([dic stringObjectForKey:@"spoils"]) {
        _spoils = [dic stringObjectForKey:@"spoils"];
    }
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"begin_time"]) {
        _startTime = [dateFormatter dateFromString:[dic stringObjectForKey:@"begin_time"]];
    }
    
    if ([dic stringObjectForKey:@"item_name"]) {
        _itemName = [dic stringObjectForKey:@"item_name"];
    }
    if ([dic stringObjectForKey:@"item_pic"]) {
        _itemPicUrl = [dic stringObjectForKey:@"item_pic"];
    }
    if ([dic intValueForKey:@"way"]) {
        _way = [dic intValueForKey:@"way"];
    }
    if ([dic intValueForKey:@"apply_count"]) {
        _applyCount = [dic intValueForKey:@"apply_count"];
    }
    if ([dic intValueForKey:@"apply_num"]) {
        _applyCount = [dic intValueForKey:@"apply_num"];
    }
    if ([dic intValueForKey:@"people_num"]) {
        _peopleNum = [dic intValueForKey:@"people_num"];
    }
}

- (void)setMatchWarInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _matchWarInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _mId = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetMatchWarInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMatchWarInfo setMatchWarInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)itemPicURL {
    if (_itemPicUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _itemPicUrl]];
}

@end
