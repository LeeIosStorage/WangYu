//
//  WYUserInfo.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYUserInfo.h"
#import "JSONKit.h"

@implementation WYUserInfo

- (void)doSetUserInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"nickname"]) {
        _nickName = [dic stringObjectForKey:@"nickname"];
    }
    if ([dic stringObjectForKey:@"telephone"]) {
        _telephone = [dic stringObjectForKey:@"telephone"];
    }
    if ([dic stringObjectForKey:@"icon"]) {
        _avatar = [dic stringObjectForKey:@"icon"];
    }
    
    _score = [dic intValueForKey:@"score"];
    _valid = [dic intValueForKey:@"valid"];
    
    if ([dic stringObjectForKey:@"username"]) {
        _account = [dic stringObjectForKey:@"username"];
    }
    if ([dic stringObjectForKey:@"password"]) {
        _password = [dic stringObjectForKey:@"password"];
    }
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"createDate"]) {
        _createDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"createDate"]];
    }
    if ([dic stringObjectForKey:@"updateDate"]) {
        _updateDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"updateDate"]];
    }
}

- (void)setUserInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _userInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _uid = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetUserInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYUserInfo setUserInfoByJsonDic exception:%@", exception);
    }
    
    self.jsonString = [_userInfoByJsonDic JSONString];
}

@end
