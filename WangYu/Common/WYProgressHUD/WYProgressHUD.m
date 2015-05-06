//
//  WYProgressHUD.m
//  WangYu
//
//  Created by KID on 15/5/6.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYProgressHUD.h"
#import "ProgressHUD.h"
#import "ProgressHUDJF.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@implementation WYProgressHUD

+ (void)AlertLoading
{
    [self AlertLoading:@"正在加载"];
}

+ (void)AlertLoading:(NSString *)Info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF show:Info Interaction:NO];
    });
}

+ (void)AlertLoadDone
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF dismiss];
    });
}

+ (void)AlertSuccess:(NSString *)Info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF showSuccess:Info];
    });
}

+ (void)AlertError:(NSString *)Info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD showError:Info];
    });
}

+ (void)AlertErrorNetwork
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD showError:@"系统网络已被断开\n请连接网络后重试"];
    });
}

+ (void)AlertErrorTimeOut
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUD showError:@"网络连接超时\n请您稍后再试"];
    });
}

+ (void)AlertLoading:(NSString *)Info At:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF show:Info Interaction:NO atView:view];
    });
}

+ (void) AlertSuccess:(NSString *)Info At:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF showSuccess:Info atView:view];
    });
}

+ (void) AlertError:(NSString *)Info At:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF showError:Info atView:view];
    });
}

+ (void) AlertErrorNetworkAt:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF showError:@"系统网络已被断开\n请连接网络后重试" atView:view];
    });
}

+ (void) AlertErrorTimeOutAt:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [ProgressHUDJF showError:@"网络连接超时\n请您稍后再试" atView:view];
    });
}

+ (void) lightAlert:(NSString *)Info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:window animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = Info;
        HUD.margin = 10.f;
        CGRect mFrame = [UIScreen mainScreen].bounds;
        HUD.yOffset = mFrame.size.height/2 - 68;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hide:YES afterDelay:2];
    });
}

@end
