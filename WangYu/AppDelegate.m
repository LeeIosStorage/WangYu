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
#import "APService.h"
#import "WYLinkerHandler.h"
#import "MobClick.h"

#define kAppCheckNumKey @"kAppCheckNumKey"
#define kAppCheckBoolKey @"kAppCheckBoolKey"

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
    //检测一下你懂的
    NSInteger checkNum = [[NSUserDefaults standardUserDefaults] integerForKey:kAppCheckNumKey];
    _bHidden = [[NSUserDefaults standardUserDefaults] boolForKey:kAppCheckBoolKey];
    if (checkNum == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:checkNum + 1 forKey:kAppCheckNumKey];
        [self checkVersion];
    }
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
//    
    application.statusBarHidden = NO;
////    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    [WXApi registerApp:WX_ID withDescription:@"WY"];
    //友盟统计
    [MobClick startWithAppkey:UMS_APPKEY reportPolicy:BATCH channelId:@"AppStore"];
    //JPush注册
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        
        //        NSMutableSet *categories = [NSMutableSet set];
        //        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
        //        category.identifier = @"identifier";
        //        UIMutableUserNotificationAction *action = [[UIMutableUserNotificationAction alloc] init];
        //        action.identifier = @"test2";
        //        action.title = @"test";
        //        action.activationMode = UIUserNotificationActivationModeBackground;
        //        action.authenticationRequired = YES;
        //        //YES显示为红色，NO显示为蓝色
        //        action.destructive = NO;
        //        NSArray *actions = @[ action ];
        //        [category setActions:actions forContext:UIUserNotificationActionContextMinimal];
        //        [categories addObject:category];
        
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
    [[WYSettingConfig staticInstance] login];
    
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
    NSArray *coverImageNames = @[@"img_index_01txt", @"img_index_02txt", @"img_index_03txt"];
    NSArray *backgroundImageNames = @[SCREEN_HEIGHT==480?@"welcome_index1_4s_bg":@"welcome_index1_bg", SCREEN_HEIGHT==480?@"welcome_index2_4s_bg":@"welcome_index2_bg", SCREEN_HEIGHT==480?@"welcome_index3_4s_bg":@"welcome_index3_bg"];
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
    
    //JPush
    if ([[WYEngine shareInstance] hasAccoutLoggedin]) {
        NSString *alias = [NSString stringWithFormat:@"member_%@",[WYEngine shareInstance].uid];
        NSSet* set=[NSSet setWithObject:@"members"];
        [APService setTags:set alias:alias callbackSelector:@selector(tagsWithAliasCallback:tags:alias:) object:self];
    }
    [[WYPayManager shareInstance] login];
    
    WYTabBarViewController* tabViewController = [[WYTabBarViewController alloc] init];
    tabViewController.delegate = self;
    if (_bHidden) {
        tabViewController.viewControllers = [NSArray arrayWithObjects:
                                             [[NetbarTabViewController alloc] init],
                                             [[ActivityTabViewController alloc] init],
                                             [[MineTabViewController alloc] init],
                                             nil];
    }else{
        tabViewController.viewControllers = [NSArray arrayWithObjects:
                                             [[NetbarTabViewController alloc] init],
                                             [[ActivityTabViewController alloc] init],
                                             [[GameCommendViewController alloc] init],
                                             [[MineTabViewController alloc] init],
                                             nil];
    }
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
    if ([scheme hasPrefix:@"WY"] && [[url absoluteString] hasPrefix:@"WY://safepay"]) {
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
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [APService handleRemoteNotification:userInfo];
    NSLog(@"收到通知:%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [APService handleRemoteNotification:userInfo];
    NSLog(@"收到通知:%@", userInfo);
    if ([userInfo stringObjectForKey:@"wycategory"]) {
        NSString *wyHref = [NSString stringWithFormat:@"wycategory://%@",[userInfo stringObjectForKey:@"wycategory"]];
        [WYLinkerHandler handleDealWithHref:wyHref From:self.mainTabViewController.navigationController];
    }
    [[WYSettingConfig staticInstance] setMineMessageUnreadEvent:YES];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [APService showLocalNotificationAtFront:notification identifierKey:nil];
}

-(void)tagsWithAliasCallback:(int)resultCode tags:(NSSet *)tags alias:(NSString *)alias{
    
    NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:resultCode],@"resultCode",
                        tags==nil?[NSNull null]:[tags allObjects],@"tags",
                        alias==nil?[NSNull null]:alias,@"alias",nil];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSNumber numberWithInt:resultCode] forKey:@"resultCode"];
    [data setObject:tags==nil?[NSNull null]:[tags allObjects] forKey:@"tags"];
    [data setObject:alias==nil?[NSNull null]:alias forKey:@"alias"];
    NSError  *error;
    
    NSData   *jsonData   = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    WYLog(@"tagsWithAliasCallback jsonString = %@",jsonString);
    
}

- (void)checkVersion{
    int tag = [[WYEngine shareInstance] getConnectTag];
    //去服务器取版本信息
    [[WYEngine shareInstance] getAppNewVersionWithTag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        if (!jsonRet || err){
            return ;
        }
        _bHidden = [[jsonRet objectForKey:@"object"] boolValueForKey:@"hiddenElement"];
        [[NSUserDefaults standardUserDefaults] setBool:_bHidden forKey:kAppCheckBoolKey];
    } tag:tag];
}

@end
