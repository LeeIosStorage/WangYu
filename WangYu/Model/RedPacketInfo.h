//
//  RedPacketInfo.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedPacketInfo : NSObject

@property(nonatomic, strong) NSString* rid;
@property(nonatomic, strong) NSString* explain;
@property(nonatomic, assign) int day;
@property(nonatomic, assign) int money;
@property(nonatomic, strong) NSDate* beginDate;
@property(nonatomic, strong) NSDate* endDate;
@property(nonatomic, assign) BOOL selected;

@property(nonatomic, strong) NSDictionary* redPacketInfoByJsonDic;

@end
