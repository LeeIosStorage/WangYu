//
//  WYNewsInfo.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYNewsInfo.h"
#import "WYEngine.h"

@implementation WYNewsInfo

- (void)doSetNewsInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"title"]) {
        _title = [dic stringObjectForKey:@"title"];
    }
    if ([dic stringObjectForKey:@"brief"]) {
        _brief = [dic stringObjectForKey:@"brief"];
    }
    if ([dic objectForKey:@"icon"]) {
        _newsImageUrl = [dic stringObjectForKey:@"icon"];
    }
    if ([dic objectForKey:@"is_subject"]) {
        _isSubject = [dic boolValueForKey:@"is_subject"];
    }
}

- (void)setNewsInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _newsInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _nid = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetNewsInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYNewsInfo setNewsInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)smallImageURL {
    if (_newsImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _newsImageUrl]];
}

@end
