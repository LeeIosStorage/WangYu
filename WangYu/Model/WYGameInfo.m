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
    
    if ([dic stringObjectForKey:@"game_name"]) {
        _gameName = [dic stringObjectForKey:@"game_name"];
    }
    if ([dic stringObjectForKey:@"intro"]) {
        _gameIntro = [dic stringObjectForKey:@"intro"];
    }
    if ([dic stringObjectForKey:@"icon"]) {
        _gameIcon = [dic stringObjectForKey:@"icon"];
    }
}

- (void)setGameInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _gameInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
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
@end
