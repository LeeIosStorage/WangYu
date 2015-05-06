//
//  WelcomeViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WelcomeViewController.h"
#import "WYEngine.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"

@interface WelcomeViewController ()

- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;
- (IBAction)visitorAction:(id)sender;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.titleNavBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (IBAction)loginAction:(id)sender {
    [WYEngine shareInstance].firstLogin = NO;
    LoginViewController *mpVc = [[LoginViewController alloc] init];
    mpVc.isCanBack = _showBackButton;
    [self.navigationController pushViewController:mpVc animated:YES];
}

- (IBAction)registerAction:(id)sender {
    [WYEngine shareInstance].firstLogin = NO;
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    vc.isCanBack = _showBackButton;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)visitorAction:(id)sender {
    
    [WYEngine shareInstance].firstLogin = NO;
    [[WYEngine shareInstance] visitorLogin];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate signIn];
}


@end
