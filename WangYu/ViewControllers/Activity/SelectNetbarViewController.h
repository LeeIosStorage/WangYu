//
//  SelectNetbarViewController.h
//  WangYu
//
//  Created by XuLei on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYNetbarInfo.h"

typedef void (^SendNetbarCallBack)(WYNetbarInfo *info);

@interface SelectNetbarViewController : WYSuperViewController

@property (nonatomic, strong) NSArray *netbarInfos;

@property (nonatomic, strong) SendNetbarCallBack sendNetbarCallBack;

@end
