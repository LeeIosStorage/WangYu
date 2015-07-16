//
//  WYThemeInfo.m
//  WangYu
//
//  Created by XuLei on 15/7/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYThemeInfo.h"
#import "WYEngine.h"

@implementation WYThemeInfo

- (void)doSetThemeInfoByJsonDic:(NSDictionary*)dic {
    if ([dic objectForKey:@"imgThumb"]) {
        _thumbImageUrl = [dic stringObjectForKey:@"imgThumb"];
    }
    if ([dic objectForKey:@"imgMedia"]) {
        _middelImageUrl = [dic stringObjectForKey:@"imgThumb"];
    }
    if ([dic objectForKey:@"img"]) {
        _originalImageUrl = [dic stringObjectForKey:@"img"];
    }
    if ([dic objectForKey:@"type"]) {
        _themeType = [dic intValueForKey:@"type"];
    }
    if ([dic objectForKey:@"url"]) {
        _themeActionUrl = [dic stringObjectForKey:@"url"];
    }
}

- (void)setThemeInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _themeInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _targetId = [[dic objectForKey:@"targetId"] description];
    
    @try {
        [self doSetThemeInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYThemeInfo setThemeInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)thumbImageURL {
    if (_thumbImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _thumbImageUrl]];
}

- (NSURL *)middleImageURL {
    if (_middelImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _middelImageUrl]];
}

- (NSURL *)originalImageURL {
    if (_originalImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _originalImageUrl]];
}

- (NSString *)realUrlHost {
    NSString *realUrlHostString = nil;
    if (_themeType == Theme_Netbar) {
        realUrlHostString = @"netbar";
    }else if (_themeType == Theme_Game) {
        realUrlHostString = @"game";
    }else if (_themeType == Theme_Match) {
        realUrlHostString = @"match";
    }
    return realUrlHostString;
}

@end
