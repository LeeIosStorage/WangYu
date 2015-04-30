//
//  AppDelegate.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "AppDelegate.h"
#import "MineTabViewController.h"
#import "GameCommendViewController.h"
#import "WYNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception) {
    
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    application.statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    
    [self signIn];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)signIn{
    NSLog(@"signIn");
    WYTabBarViewController* tabViewController = [[WYTabBarViewController alloc] init];
    tabViewController.viewControllers = [NSArray arrayWithObjects:
                                         [[MineTabViewController alloc] init],
                                         [[MineTabViewController alloc] init],
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
