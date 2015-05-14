//
//  WYNetbarInfo.m
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYNetbarInfo.h"
#import "WYEngine.h"

@implementation WYNetbarInfo

- (void)doSetNetbarInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"name"]) {
        _netbarName = [dic stringObjectForKey:@"name"];
    }
    if ([dic stringObjectForKey:@"address"]) {
        _address = [dic stringObjectForKey:@"address"];
    }
    if ([dic stringObjectForKey:@"icon"]) {
        _netbarImageUrl = [dic stringObjectForKey:@"icon"];
    }
    if ([dic objectForKey:@"is_order"]) {
        _isOrder = [dic boolValueForKey:@"is_order"];
    }
    if ([dic objectForKey:@"is_recommend"]) {
        _isRecommend = [dic intValueForKey:@"is_recommend"];
    }
    if ([dic intValueForKey:@"price"]) {
        _price = [dic intValueForKey:@"price"];
    }
    if ([dic objectForKey:@"distance"]) {
        _distance = [[dic stringObjectForKey:@"distance"] description];
    }
}

- (void)setNetbarInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _netbarInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _nid = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetNetbarInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYNetbarInfo setNetbarInfoByJsonDic exception:%@", exception);
    }
}

- (NSURL *)smallImageUrl {
    if (_netbarImageUrl == nil) {
        return nil;
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], _netbarImageUrl]];
}


@end
