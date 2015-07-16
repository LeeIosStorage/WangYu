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
        _originalImageUrl = [dic stringObjectForKey:@"icon"];
    }
    if ([dic objectForKey:@"icon_media"]) {
        _middleImageUrl = [dic stringObjectForKey:@"icon"];
    }
    if ([dic objectForKey:@"icon_thumb"]) {
        _thumbImageUrl = [dic stringObjectForKey:@"icon_thumb"];
    }
    if ([dic objectForKey:@"is_subject"]) {
        _isSubject = [dic boolValueForKey:@"is_subject"];
    }
    if ([dic objectForKey:@"cover"]) {
        _cover = [dic stringObjectForKey:@"cover"];
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

- (NSURL *)originalImageURL {
    if (_originalImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _originalImageUrl]];
}

- (NSURL *)middleImageURL {
    if (_middleImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _middleImageUrl]];
}

- (NSURL *)thumbImageURL {
    if (_thumbImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _thumbImageUrl]];
}

- (NSURL *)hotImageURL {
    if (_cover == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _cover]];
}

@end
