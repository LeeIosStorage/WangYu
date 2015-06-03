//
//  WYGameInfo.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYGameInfo.h"
#import "WYEngine.h"

@implementation WYGameInfo

- (void)doSetGameInfoByJsonDic:(NSDictionary*)dic {
    
//    if ([dic stringObjectForKey:@"game_name"]) {
//        _gameName = [dic stringObjectForKey:@"game_name"];
//    }
    if ([dic stringObjectForKey:@"name"]) {
        _gameName = [dic stringObjectForKey:@"name"];
    }
    if ([dic stringObjectForKey:@"intro"]) {
        _gameIntro = [dic stringObjectForKey:@"intro"];
    }
    if ([dic stringObjectForKey:@"icon"]) {
        _gameIcon = [dic stringObjectForKey:@"icon"];
    }
    if ([dic stringObjectForKey:@"cover"]) {
        _gameCover = [dic stringObjectForKey:@"cover"];
    }
    
    
    if ([dic stringObjectForKey:@"des"]) {
        _gameDes = [dic stringObjectForKey:@"des"];
    }
    if ([dic stringObjectForKey:@"version"]) {
        _version = [dic stringObjectForKey:@"version"];
    }
    if ([dic stringObjectForKey:@"url_ios"]) {
        _downloadUrl = [dic stringObjectForKey:@"url_ios"];
    }
    if ([dic intValueForKey:@"ios_file_size"]) {
        _iosFileSize = [dic intValueForKey:@"ios_file_size"];
    }
    if ([dic intValueForKey:@"download_count"]) {
        _downloadCount = [dic intValueForKey:@"download_count"];
    }
    if ([dic intValueForKey:@"favor_count"]) {
        _favorCount = [dic intValueForKey:@"favor_count"];
    }
    _isFavor = [dic intValueForKey:@"has_favor"];
    
    id objectForKey = [dic arrayObjectForKey:@"imgs"];
    if (objectForKey) {
        _coverIds = [NSMutableArray array];
        for (id object in objectForKey) {
            if ([object isKindOfClass:[NSString class]]) {
                [_coverIds addObject:object];
            }else if ([object isKindOfClass:[NSDictionary class]]){
                NSDictionary *dic = object;
                [_coverIds addObject:[dic stringObjectForKey:@"url"]];
            }
        }
    }
}

- (void)setGameInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _gameInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _gameId = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetGameInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYGameInfo setGameInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)gameIconUrl {
    if (_gameIcon == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _gameIcon]];
}
- (NSURL *)gameCoverUrl {
    if (_gameCover == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _gameCover]];
}

- (NSArray *)coverURLs{
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    for (NSString* picId in _coverIds) {
        [urls addObject:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl] ,picId]];
    }
    return urls;
}

@end
