//
//  WYActivityInfo.m
//  WangYu
//
//  Created by KID on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYActivityInfo.h"
#import "WYUserInfo.h"
#import "WYEngine.h"

@implementation WYActivityInfo

- (void)doSetActivityInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"title"]) {
        _title = [dic stringObjectForKey:@"title"];
    }
    if ([dic stringObjectForKey:@"icon"]) {
        _activityImageUrl = [dic stringObjectForKey:@"icon"];
    }
    if ([dic intValueForKey:@"status"]) {
        _status = [dic intValueForKey:@"status"];
    }
    if ([dic objectForKey:@"end_time"]) {
        _endTime = [dic stringObjectForKey:@"end_time"];
        if (_endTime.length > 16) {
            _endTime = [_endTime substringToIndex:16];
        }
    }
    if ([dic stringObjectForKey:@"start_time"]) {
        _startTime = [dic stringObjectForKey:@"start_time"];
        if (_startTime.length > 16) {
            _startTime = [_startTime substringToIndex:16];
        }
    }
    if ([dic stringObjectForKey:@"item_name"]) {
        _itemName = [dic stringObjectForKey:@"item_name"];
    }
    if ([dic stringObjectForKey:@"item_pic"]) {
        _itemPicUrl = [dic stringObjectForKey:@"item_pic"];
    }
    if ([dic intValueForKey:@"has_favor"]) {
        _favored = [dic intValueForKey:@"has_favor"];
    }
    if ([dic objectForKey:@"info_id"]) {
        _newsId = [dic stringObjectForKey:@"info_id"];
    }
    if ([dic arrayObjectForKey:@"members"]) {
        _members = [[NSMutableArray alloc] init];
        for (NSDictionary *memberDic in [dic arrayObjectForKey:@"members"]) {
            WYUserInfo *userInfo = [[WYUserInfo alloc] init];
            [userInfo setUserInfoByJsonDic:memberDic];
            [_members addObject:userInfo];
        }
    }
}

- (void)setActivityInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _activityInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _aId = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetActivityInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYActivityInfo setActivityInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)smallImageURL {
    if (_activityImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _activityImageUrl]];
}

- (NSURL *)itemPicURL {
    if (_itemPicUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _itemPicUrl]];
}

@end
