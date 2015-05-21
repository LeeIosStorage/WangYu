//
//  WYPayManager.h
//  WangYu
//
//  Created by KID on 15/5/20.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WYPayManager : NSObject<WXApiDelegate>

+ (WYPayManager*)shareInstance;

- (void)payForWinxinWith:(NSDictionary *)dictionary;

- (void)payForAlipayWith:(NSDictionary *)dictionary;

@end
