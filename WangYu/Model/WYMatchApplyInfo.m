//
//  WYMatchApplyInfo.m
//  WangYu
//
//  Created by Leejun on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMatchApplyInfo.h"
#import "WYEngine.h"

@implementation WYMatchApplyInfo

- (void)setApplyInfoByDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @try {
        _applyId = [[dic objectForKey:@"apply_id"] description];
        _nickName = [[dic objectForKey:@"user_nickname"] description];
        _userId = [[dic objectForKey:@"user_id"] description];
        _telephone = [[dic objectForKey:@"telephone"] description];
        _userAvatar = [[dic objectForKey:@"user_icon"] description];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMatchApplyInfo setApplyInfoByDic exception:%@", exception);
    }
    
}

- (NSURL *)smallAvatarUrl {
    if (_userAvatar == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _userAvatar]];
}

@end
