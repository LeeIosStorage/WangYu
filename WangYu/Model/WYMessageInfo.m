//
//  WYMessageInfo.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYMessageInfo.h"

@implementation WYMessageInfo

- (void)doSetMessageInfoByJsonDic:(NSDictionary*)dic {
    
    if ([dic stringObjectForKey:@"title"]) {
        _title = [dic stringObjectForKey:@"title"];
    }
    if ([dic stringObjectForKey:@"content"]) {
        _content = [dic stringObjectForKey:@"content"];
    }
    
    _type = [dic intValueForKey:@"type"];
    
    NSDateFormatter *dateFormatter = [WYUIUtils dateFormatterOFUS];
    if ([dic stringObjectForKey:@"create_date"]) {
        _createDate = [dateFormatter dateFromString:[dic stringObjectForKey:@"create_date"]];
    }
}

- (void)setMessageInfoByJsonDic:(NSDictionary*)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return;
    }
    _messageInfoByJsonDic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    
    @try {
        [self doSetMessageInfoByJsonDic:dic];
    }
    @catch (NSException *exception) {
        NSLog(@"####WYMessageInfo setMessageInfoByJsonDic exception:%@", exception);
    }
}

@end
