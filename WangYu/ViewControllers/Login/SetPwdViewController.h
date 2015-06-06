//
//  SetPwdViewController.h
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYUserInfo.h"

@interface SetPwdViewController : WYSuperViewController

@property (nonatomic, assign) BOOL isCanBack;
@property (nonatomic, strong) NSString *registerName;
@property (nonatomic, strong) NSString *invitationCode;
@property (nonatomic, strong) WYUserInfo *userInfo;
@property (nonatomic, strong) NSString *phoneCode;

@end
