//
//  WYMemberInfo.m
//  WangYu
//
//  Created by XuLei on 15/7/7.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMemberInfo.h"
#import "WYEngine.h"

@implementation WYMemberInfo

- (void)doSetMemberInfoByJsonDic:(NSDictionary*)dic {
    if ([dic stringObjectForKey:@"telephone"]) {
        _telephone = [dic stringObjectForKey:@"telephone"];
    }
    if ([dic stringObjectForKey:@"isCompleted"]) {
        _isCompleted = [dic boolValueForKey:@"isCompleted"];
    }
    if ([dic objectForKey:@"nickname"]) {
        _nickName = [dic stringObjectForKey:@"nickname"];
    }
    if (([dic objectForKey:@"icon"])) {
        _icon = [dic stringObjectForKey:@"icon"];
    }
}

- (void)setMemberInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _memberInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _memberId = [[dic objectForKey:@"member_id"] description];
    
    @try {
        [self doSetMemberInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMemberInfo setMemberInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)smallAvatarUrl {
    if (_icon == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _icon]];
}

@end
