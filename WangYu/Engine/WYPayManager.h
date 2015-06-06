//
//  WYPayManager.h
//  WangYu
//
//  Created by KID on 15/5/20.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@protocol WYPayManagerListener;
@interface WYPayManager : NSObject<WXApiDelegate>

+ (WYPayManager*)shareInstance;
- (void)addListener:(id<WYPayManagerListener>)listener;
- (void)removeListener:(id<WYPayManagerListener>)listener;
- (void)login;
- (void)logout;

- (void)payForWinxinWith:(NSDictionary *)dictionary;

- (void)payForAlipayWith:(NSDictionary *)dictionary;

@end

@protocol WYPayManagerListener <NSObject>
@optional
//status:0失败 1成功 && payType:0支付宝 1微信
- (void)payManagerResultStatus:(int)status payType:(int)payType;
@end