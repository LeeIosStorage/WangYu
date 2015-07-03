//
//  WYTeamInfo.m
//  WangYu
//
//  Created by XuLei on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYTeamInfo.h"

@implementation WYTeamInfo

- (void)doSetTeamInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"header"]) {
        _teamLeader = [dic stringObjectForKey:@"header"];
    }
    if ([dic stringObjectForKey:@"team_name"]) {
        _teamName = [dic stringObjectForKey:@"team_name"];
    }
    if ([dic objectForKey:@"num"]) {
        _applyNum = [dic intValueForKey:@"num"];
    }
    if (([dic objectForKey:@"total_num"])) {
        _totalNum = [dic intValueForKey:@"total_num"];
    }
    if ([dic objectForKey:@"is_join"]) {
        _isJoin = [dic boolValueForKey:@"is_join"];
    }
}

- (void)setTeamInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _teamInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _teamId = [[dic objectForKey:@"team_id"] description];
    
    @try {
        [self doSetTeamInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYTeamInfo setTeamInfoByJsonDic exception:%@", exception);
    }
}

@end
