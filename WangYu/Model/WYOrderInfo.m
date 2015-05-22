//
//  WYOrderInfo.m
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYOrderInfo.h"

@implementation WYOrderInfo

- (void)doSetOrderInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"amount"]) {
        _amount = [dic stringObjectForKey:@"amount"];
    }
    _price = [dic intValueForKey:@"price"];
    _isReceive = [dic intValueForKey:@"is_receive"];
    _isValid = [dic intValueForKey:@"is_valid"];
    _isRelated = [dic intValueForKey:@"is_related"];
    _overpay = [dic intValueForKey:@"overpay"];
    _hours = [dic intValueForKey:@"hours"];
    _seating = [dic intValueForKey:@"seating"];
    _status = [dic intValueForKey:@"status"];
    
    _totalAmount = [dic intValueForKey:@"total_amount"];
    _type = [dic intValueForKey:@"type"];
    _scoreAmount = [dic intValueForKey:@"score_amount"];
    _redbagAmount = [dic intValueForKey:@"redbag_amount"];
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"create_date"]) {
        _createDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"create_date"]];
    }
    if ([dic stringObjectForKey:@"reservation_time"]) {
        _reservationDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"reservation_time"]];
    }
    
    if ([dic stringObjectForKey:@"netbar_id"]) {
        _netbarId = [dic stringObjectForKey:@"netbar_id"];
    }
    if ([dic stringObjectForKey:@"name"]) {
        _netbarName = [dic stringObjectForKey:@"name"];
    }
    if ([dic stringObjectForKey:@"netbar_name"]) {
        _netbarName = [dic stringObjectForKey:@"netbar_name"];
    }
    if ([dic stringObjectForKey:@"icon"]) {
        _icon = [dic stringObjectForKey:@"icon"];
    }
    
    if ([dic intValueForKey:@"user_id"]) {
        _userId = [dic stringObjectForKey:@"user_id"];
    }
    if ([dic objectForKey:@"telephone"]) {
        _telephone = [[dic stringObjectForKey:@"telephone"] description];
    }
}

- (void)setOrderInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _orderInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    _orderId = [[dic objectForKey:@"id"] description];
    
    @try {
        [self doSetOrderInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYOrderInfo setOrderInfoByJsonDic exception:%@", exception);
    }
}

@end
