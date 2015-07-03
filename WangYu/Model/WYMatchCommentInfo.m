//
//  WYMatchCommentInfo.m
//  WangYu
//
//  Created by Leejun on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMatchCommentInfo.h"
#import "WYEngine.h"

@implementation WYMatchCommentInfo

- (void)setCommentInfoByDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    @try {
        _content = [[dic objectForKey:@"content"] description];
        _nickName = [[dic objectForKey:@"user_nickname"] description];
        _userId = [[dic objectForKey:@"user_id"] description];
        _userAvatar = [[dic objectForKey:@"user_icon"] description];
        NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
        _createDate = [dateFormatter dateFromString:[dic objectForKey:@"create_date"]];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMatchCommentInfo setCommentInfoByDic exception:%@", exception);
    }
}

- (NSURL *)smallAvatarUrl {
    if (_userAvatar == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _userAvatar]];
}

@end
