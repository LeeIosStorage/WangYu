//
//  RegisterViewController.h
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

typedef enum VcType_{
    VcType_Invitation_Code = 0,  //邀请码
    VcType_Register,             //手机注册
}VcType;

@interface RegisterViewController : WYSuperViewController

@property (nonatomic, assign) BOOL isCanBack;
@property (nonatomic, assign) VcType vcType;

@end
