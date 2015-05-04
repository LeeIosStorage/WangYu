//
//  RetrievePwdViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RetrievePwdViewController.h"
#import "SetPwdViewController.h"

@interface RetrievePwdViewController ()

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *getCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *resetPasswordButton;

- (IBAction)getCodeAction:(id)sender;
- (IBAction)fresetPasswordAction:(id)sender;

@end

@implementation RetrievePwdViewController

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
    [self setTitle:@"手机找回密码"];
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
    self.getCodeButton.backgroundColor = SKIN_COLOR;
    self.getCodeButton.layer.cornerRadius = 4;
    self.getCodeButton.layer.masksToBounds = YES;
    
    self.resetPasswordButton.backgroundColor = SKIN_COLOR;
    self.resetPasswordButton.layer.cornerRadius = 4;
    self.resetPasswordButton.layer.masksToBounds = YES;
//    self.resetPasswordButton.enabled = NO;//UIColorToRGB(0xe4e4e4)
    
}

#pragma mark - IBAction
- (IBAction)getCodeAction:(id)sender{
    
}
- (IBAction)fresetPasswordAction:(id)sender{
    SetPwdViewController *vc = [[SetPwdViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
