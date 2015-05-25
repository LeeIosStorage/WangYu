//
//  AppDelegate.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "AppDelegate.h"
#import "MineTabViewController.h"
#import "NetbarTabViewController.h"
#import "ActivityTabViewController.h"
#import "GameCommendViewController.h"
#import "WYNavigationController.h"
#import "WYSettingConfig.h"
#import "WYEngine.h"
#import "NewIntroViewController.h"
#import "WelcomeViewController.h"
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WYProgressHUD.h"
#import "WYShareManager.h"
#import "WYPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate () <WYTabBarControllerDelegate,WXApiDelegate>

@property (nonatomic, strong) NewIntroViewController *introView;

@end

@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception) {

    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//    
    application.statusBarHidden = NO;
////    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    [WXApi registerApp:WX_ID withDescription:@"WY"];
    //第三方注册

    
    

    if ([[WYEngine shareInstance] hasAccoutLoggedin] || ![WYEngine shareInstance].firstLogin) {
        if ([WYSettingConfig isFirstEnterVersion]) {
            [self showNewIntro];
        } else {
            [self signIn];
        }
    }else{
        NSLog(@"signOut for accout miss");
        [self signOut];
    }

    [self.window makeKeyAndVisible];

    return YES;
}

//新手引导
-(void)showNewIntro{
    NSArray *coverImageNames = @[@"img_index_01txt", @"img_index_02txt", @"img_index_03txt",@"img_index_01txt"];
    NSArray *backgroundImageNames = @[@"welcome_index1_bg", @"welcome_index2_bg", @"welcome_index3_bg",@"welcome_index4_bg"];
    self.introView = [[NewIntroViewController alloc] initWithCoverImageNames:coverImageNames backgroundImageNames:backgroundImageNames];
    
//    [self.window addSubview:self.introView.view];
    self.window.rootViewController = self.introView;
    
    __weak AppDelegate *weakSelf = self;
    self.introView.didSelectedEnter = ^() {
        [weakSelf.introView.view removeFromSuperview];
        weakSelf.introView = nil;
        [weakSelf signOut];
    };
}

- (void)signIn{
    NSLog(@"signIn");
    WYTabBarViewController* tabViewController = [[WYTabBarViewController alloc] init];
    tabViewController.delegate = self;
    tabViewController.viewControllers = [NSArray arrayWithObjects:
                                         [[NetbarTabViewController alloc] init],
                                         [[ActivityTabViewController alloc] init],
                                         [[GameCommendViewController alloc] init],
                                         [[MineTabViewController alloc] init],
                                         nil];
    
    _mainTabViewController = tabViewController;
    
    WYNavigationController* tabNavVc = [[WYNavigationController alloc] initWithRootViewController:tabViewController];
    tabNavVc.navigationBarHidden = YES;
    
    _mainTabViewController.initialIndex = 0;
    
    self.window.rootViewController = tabNavVc;
}

- (void)signOut{
    NSLog(@"signOut");
    
    if([WYSettingConfig isFirstEnterVersion]){
        [self showNewIntro];
        return;
    }
    
    WelcomeViewController* welcomeViewController = [[WelcomeViewController alloc] init];
    WYNavigationController* navigationController = [[WYNavigationController alloc] initWithRootViewController:welcomeViewController];
    navigationController.navigationBarHidden = YES;
    self.window.rootViewController = navigationController;
    
    _mainTabViewController = nil;
    
    [[WYEngine shareInstance] logout];
}

#pragma mark - WYTabBarControllerDelegate
-(BOOL) tabBarController:(WYTabBarViewController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[MineTabViewController class]]) {
        return [[WYEngine shareInstance] needUserLogin:nil];
    }
    return NO;
}


- (BOOL)handleOpenURL:(NSURL *)url {
    WYLog(@"query=%@,scheme=%@,host=%@", url.query, url.scheme, url.host);
    NSString *scheme = [url scheme];
    
    if ([[url absoluteString] hasPrefix:@"wxb10451ed2c4a6ce3://pay"]) {
        return [WXApi handleOpenURL:url delegate:[WYPayManager shareInstance]];
    }
    if ([scheme hasPrefix:@"wx"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    if ([scheme hasPrefix:@"wb"]) {
        return [WeiboSDK handleOpenURL:url delegate:[WYShareManager shareInstance]];
    }
    if ([scheme hasPrefix:@"tencent"]) {
        return [QQApiInterface handleOpenURL:url delegate:[WYShareManager shareInstance]];
    }
    if ([scheme hasPrefix:@"WY://safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@", resultDic);
            NSInteger status = [[resultDic objectForKey:@"resultStatus"] integerValue];
            switch (status) {
                case 9000:
                {
                    [WYProgressHUD AlertSuccess:@"支付成功"];
                }
                    break;
                default:
                {
                    [WYProgressHUD AlertSuccess:@"支付失败"];
                    NSLog(@"==================失败=======%@",[resultDic objectForKey:@"memo"]);
                }
                    break;
            }
        }];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    WYLog(@"openURL url=%@, sourceApplication=%@, annotation=%@", url, sourceApplication, annotation);
    return [self handleOpenURL:url];
}

#pragma mark - WXApiDelegate
-(void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[SendMessageToWXResp class]]){
        NSString *strMsg = [NSString stringWithFormat:@"Wx发送消息结果:%d", resp.errCode];
        NSLog(@"send ret:%@", strMsg);
        switch (resp.errCode) {
            case WXSuccess:{
                [WYProgressHUD AlertSuccess:@"分享微信成功"];
            }
                break;
                
            default:
                [WYProgressHUD AlertError:@"分享微信失败"];
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
