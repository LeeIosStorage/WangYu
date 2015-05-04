//
//  LoginViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "LoginViewController.h"
#import "RetrievePwdViewController.h"

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet UITextField *accountTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *quickRegisterButton;
@property (strong, nonatomic) IBOutlet UIButton *forgetPasswordButton;

- (IBAction)loginAction:(id)sender;
- (IBAction)quickRegisterAction:(id)sender;
- (IBAction)forgetPasswordAction:(id)sender;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUIControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"用户登录"];
    [self setBarBackgroundColor:UIColorToRGB(0xf5f5f5) showLine:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshUIControl{
    self.loginButton.backgroundColor = SKIN_COLOR;
    self.loginButton.layer.cornerRadius = 4;
    self.loginButton.layer.masksToBounds = YES;
    [self.quickRegisterButton setTitleColor:UIColorToRGB(0x387cbc) forState:0];
    [self.forgetPasswordButton setTitleColor:UIColorToRGB(0x387cbc) forState:0];
    
}

- (IBAction)loginAction:(id)sender {
}

- (IBAction)quickRegisterAction:(id)sender {
}

- (IBAction)forgetPasswordAction:(id)sender {
    RetrievePwdViewController *vc = [[RetrievePwdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
