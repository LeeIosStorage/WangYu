//
//  WelcomeViewController.h
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SuperMainViewController.h"

typedef void(^BackActionCallBack)(BOOL isBack);

@interface WelcomeViewController : SuperMainViewController

@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, strong) BackActionCallBack backActionCallBack;

@end
