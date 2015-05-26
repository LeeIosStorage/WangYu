//
//  MineTabViewController.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MineTabViewController.h"
#import "WYTabBarViewController.h"
#import "AboutViewController.h"
#import "WYEngine.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "OrdersViewController.h"

@interface MineTabViewController ()

- (IBAction)editAction:(id)sender;
@end

@implementation MineTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getCacheTopicInfo];
    [self refreshTopicList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"我的"];
    [self setRightButtonWithImageName:@"netbar_service_icon" selector:@selector(serviceAction:)];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - request
- (void)getCacheTopicInfo{
    
}

- (void)refreshTopicList{
    
}

#pragma mark - IBAction
- (void)serviceAction:(id)sender{
    SettingViewController *setVc = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setVc animated:YES];
}
- (IBAction)editAction:(id)sender{
    
    OrdersViewController *orderVc = [[OrdersViewController alloc] init];
    [self.navigationController pushViewController:orderVc animated:YES];
    
}
- (void)settingAction:(id)sender {
    SettingViewController *setVc = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setVc animated:YES];
}

@end
