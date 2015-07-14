//
//  AppDelegate.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYTabBarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readwrite, nonatomic) WYTabBarViewController* mainTabViewController;
@property (strong, nonatomic)UIMenuController *appMenu;
@property (assign, nonatomic) BOOL bHidden;

- (void)signIn;
- (void)signOut;

@end

