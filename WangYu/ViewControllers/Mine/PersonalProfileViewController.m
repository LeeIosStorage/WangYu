//
//  PersonalProfileViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/19.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PersonalProfileViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"

@interface PersonalProfileViewController ()
{
    WYUserInfo *_oldUserInfo;
    WYUserInfo *_newUserInfo;
}
@end

@implementation PersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadUserInfo];
}

-(void)loadUserInfo{
    WYUserInfo* tmpUserInfo = _userInfo;
    if (tmpUserInfo == nil || tmpUserInfo.uid.length == 0) {
        [WYProgressHUD AlertError:@"用户不存在"];
    }
    _oldUserInfo = [[WYUserInfo alloc] init];
    [_oldUserInfo setUserInfoByJsonDic:tmpUserInfo.userInfoByJsonDic];
    _oldUserInfo.uid = _userInfo.uid;
    
    _newUserInfo = [[WYUserInfo alloc] init];
    [_newUserInfo setUserInfoByJsonDic:tmpUserInfo.userInfoByJsonDic];
    _newUserInfo.uid = _userInfo.uid;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"个人信息"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - custom

@end
