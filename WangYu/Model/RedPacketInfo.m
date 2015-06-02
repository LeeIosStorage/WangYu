//
//  RedPacketInfo.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RedPacketInfo.h"

@implementation RedPacketInfo

- (void)doSetRedPacketInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"explain"]) {
        _explain = [dic stringObjectForKey:@"explain"];
    }
    
    _money = [dic intValueForKey:@"money"];
    _day = [dic intValueForKey:@"day"];
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"begin_date"]) {
        _beginDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"begin_date"]];
    }
    if ([dic stringObjectForKey:@"end_date"]) {
        _endDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"end_date"]];
    }
}

- (void)setRedPacketInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _rid = [[dic objectForKey:@"id"] description];
    _redPacketInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    @try {
        [self doSetRedPacketInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####RedPacketInfo setRedPacketInfoByJsonDic exception:%@", exception);
    }
}

@end
