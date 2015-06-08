//
//  WYMatchInfo.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMatchInfo.h"
#import "WYNetbarInfo.h"

@implementation WYMatchInfo

- (void)doSetMatchInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"begin_time"]) {
        _startTime = [dic stringObjectForKey:@"begin_time"];
        if (_startTime.length > 16) {
            _startTime = [_startTime substringToIndex:16];
        }
    }
    if ([dic stringObjectForKey:@"over_time"]) {
        _endTime = [dic stringObjectForKey:@"over_time"];
        if (_endTime.length > 16) {
            _endTime = [_endTime substringToIndex:16];
        }
    }
    if ([dic objectForKey:@"round"]) {
        _round = [dic intValueForKey:@"round"];
    }
    if ([dic objectForKey:@"inApply"]) {
        _isApply = [dic boolValueForKey:@"inApply"];
    }
    if ([dic objectForKey:@"hasApply"]) {
        _hasApply = [dic intValueForKey:@"hasApply"];
    }
    if ([dic objectForKey:@"areas"]) {
        _areas = [dic stringObjectForKey:@"areas"];
    }
    if ([dic objectForKey:@"netbars"]) {
        _netbars = [[NSMutableArray alloc] init];
        for (NSDictionary *netbarDic in [dic arrayObjectForKey:@"netbars"]) {
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:netbarDic];
            [_netbars addObject:netbarInfo];
        }
    }
}

- (void)setMatchInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;      
    }
    _matchInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
//    _mid = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetMatchInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMatchInfo setMatchInfoByJsonDic exception:%@", exception);
    }
}

@end
