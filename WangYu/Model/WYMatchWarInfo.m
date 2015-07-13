//
//  WYMatchWarInfo.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMatchWarInfo.h"
#import "WYEngine.h"
#import "WYMatchApplyInfo.h"
#import "WYMatchCommentInfo.h"

@interface WYMatchWarInfo () {
    
    NSMutableArray* _applys;
    NSMutableArray* _comments;
}

@end

@implementation WYMatchWarInfo

- (void)doSetMatchUserByJsonDic:(NSDictionary*)dic{
    if ([dic stringObjectForKey:@"releaser_id"]) {
        _userInfo.uid = [dic stringObjectForKey:@"releaser_id"];
    }
    if ([dic stringObjectForKey:@"nickname"]) {
        _userInfo.nickName = [dic stringObjectForKey:@"nickname"];
    }
    if ([dic stringObjectForKey:@"releaser_telephone"]) {
        _userInfo.telephone = [dic stringObjectForKey:@"releaser_telephone"];
    }
    if ([dic stringObjectForKey:@"releaser_icon"]) {
        _userInfo.avatar = [dic stringObjectForKey:@"releaser_icon"];
    }
}
- (void)doSetMatchWarInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"title"]) {
        _title = [dic stringObjectForKey:@"title"];
    }
    if ([dic stringObjectForKey:@"releaser_id"]) {
        _userInfo = [[WYUserInfo alloc] init];
        [self doSetMatchUserByJsonDic:dic];
    }
    if ([dic stringObjectForKey:@"spoils"]) {
        _spoils = [dic stringObjectForKey:@"spoils"];
    }
    if ([dic stringObjectForKey:@"rule"]) {
        _rule = [dic stringObjectForKey:@"rule"];
    }
    if ([dic stringObjectForKey:@"remark"]) {
        _remark = [dic stringObjectForKey:@"remark"];
    }
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"begin_time"]) {
        _startTime = [dateFormatter dateFromString:[dic stringObjectForKey:@"begin_time"]];
    }
    
    if ([dic stringObjectForKey:@"item_name"]) {
        _itemName = [dic stringObjectForKey:@"item_name"];
    }
    if ([dic stringObjectForKey:@"server"]) {
        _itemServer = [dic stringObjectForKey:@"server"];
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
    if ([dic intValueForKey:@"is_start"]) {
        _isStart = [dic intValueForKey:@"is_start"];
    }
    if ([dic intValueForKey:@"userStatus"]) {
        _userStatus = [dic intValueForKey:@"userStatus"];
    }
    if ([dic intValueForKey:@"people_num"]) {
        _peopleNum = [dic intValueForKey:@"people_num"];
    }
    if ([dic intValueForKey:@"commentsCount"]) {
        _commentsCount = [dic intValueForKey:@"commentsCount"];
    }
    
    if ([dic stringObjectForKey:@"netbar_id"]) {
        _netbarId = [dic stringObjectForKey:@"netbar_id"];
    }
    if ([dic stringObjectForKey:@"address"]) {
        _netbarName = [dic stringObjectForKey:@"address"];
    }
    
    _applys = [[NSMutableArray alloc] init];
    for (NSDictionary*applyDic in [dic objectForKey:@"applies"]) {
        WYMatchApplyInfo* applyInfo = [[WYMatchApplyInfo alloc] init];
        [applyInfo setApplyInfoByDic:applyDic];
        [_applys addObject:applyInfo];
    }
    
    _comments = [[NSMutableArray alloc] init];
    for (NSDictionary*commentDic in [[dic dictionaryObjectForKey:@"comments"] arrayObjectForKey:@"list"]) {
        WYMatchCommentInfo* commentnfo = [[WYMatchCommentInfo alloc] init];
        [commentnfo setCommentInfoByDic:commentDic];
        [_comments addObject:commentnfo];
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
