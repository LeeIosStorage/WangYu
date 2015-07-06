//
//  WYMessageInfo.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMessageInfo.h"

@implementation WYMessageInfo

- (void)doSetMessageInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"title"]) {
        _title = [dic stringObjectForKey:@"title"];
    }
    if ([dic stringObjectForKey:@"content"]) {
        _content = [dic stringObjectForKey:@"content"];
    }
    if ([dic stringObjectForKey:@"is_read"]) {
        _isRead = [dic boolValueForKey:@"is_read"];
    }
    _type = [dic intValueForKey:@"type"];
    if ([dic stringObjectForKey:@"obj_id"]) {
        _objId = [dic objectForKey:@"obj_id"];
    }
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"create_date"]) {
        _createDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"create_date"]];
    }
}

- (void)setMessageInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _messageInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _msgId = [[dic objectForKey:@"id"] description];
    @try {
        [self doSetMessageInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMessageInfo setMessageInfoByJsonDic exception:%@", exception);
    }
}

- (NSString *) realUrlHost{
    NSString *realUrlHostString = nil;
    if (_type == SYS_NOTIFY) {
        realUrlHostString = @"sys";
    }else if (_type == SYS_REDBAG) {
        realUrlHostString = @"redbag";
    }else if (_type == SYS_MEMBER) {
        realUrlHostString = @"member";
    }else if (_type == ORDER_RESERVE) {
        realUrlHostString = @"reservation";
    }else if (_type == ORDER_PAY) {
        realUrlHostString = @"pay";
    }else if (_type == ACTIVITY_MATCH) {
        realUrlHostString = @"activity";
    }else if (_type == ACTIVITY_FIGHT) {
        realUrlHostString = @"match";
    }
    return realUrlHostString;
}

@end
