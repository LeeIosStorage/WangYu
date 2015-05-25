//
//  QuickPayViewController.h
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYNetbarInfo.h"
#import "WYOrderInfo.h"

@interface QuickPayViewController : WYSuperViewController

@property (nonatomic, strong) WYNetbarInfo *netbarInfo;
@property (nonatomic, assign) BOOL isBooked;
@property (nonatomic, strong) WYOrderInfo *orderInfo;

@end
