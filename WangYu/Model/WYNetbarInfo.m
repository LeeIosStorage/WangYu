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
    if ([dic objectForKey:@"telephone"]) {
        _telephone = [dic stringObjectForKey:@"telephone"];
    }
    if ([dic stringObjectForKey:@"netbar_name"]) {
        _netbarName = [dic stringObjectForKey:@"netbar_name"];
    }
    if ([dic stringObjectForKey:@"latitude"]) {
        _latitude = [dic stringObjectForKey:@"latitude"];
    }
    if ([dic stringObjectForKey:@"longitude"]) {
        _longitude = [dic stringObjectForKey:@"longitude"];
    }
    
    id objectForKey = [dic arrayObjectForKey:@"imgs"];
    if (objectForKey) {
        _picIds = [NSMutableArray array];
        for (NSDictionary *objectDic in objectForKey) {
            [_picIds addObject:[objectDic objectForKey:@"url"]];
        }
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

- (NSArray *)picURLs{
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    for (NSString* picId in _picIds) {
        [urls addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl] ,picId]]];
    }
    return urls;
}

@end
