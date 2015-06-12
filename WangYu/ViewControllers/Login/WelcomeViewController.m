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

@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UIButton *registerBtn;
@property (strong, nonatomic) IBOutlet UIButton *visitorBtn;
@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;

- (IBAction)loginAction:(id)sender;
- (IBAction)registerAction:(id)sender;
- (IBAction)visitorAction:(id)sender;
@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.titleNavBar setHidden:YES];
    
    [self refreshUIControl];
}

- (void)refreshUIControl {
    CGRect frame = _floatView.frame;
    frame.origin.y = self.view.frame.size.height;
    _floatView.frame = frame;
    _floatView.alpha = 0;
    [self.view addSubview:_floatView];
    
    _loginBtn.layer.cornerRadius = 4.0;
    _loginBtn.layer.masksToBounds = YES;
    [_loginBtn setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_icon"] forState:UIControlStateNormal];
    [_loginBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_icon_hover"] forState:UIControlStateHighlighted];
    _loginBtn.titleLabel.font = SKIN_FONT_FROMNAME(18);
    
    _registerBtn.layer.cornerRadius = 4.0;
    _registerBtn.layer.masksToBounds = YES;
    [_registerBtn setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [_registerBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_icon"] forState:UIControlStateNormal];
    [_registerBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_icon_hover"] forState:UIControlStateHighlighted];
    _registerBtn.titleLabel.font = SKIN_FONT_FROMNAME(18);
    
    _visitorBtn.layer.cornerRadius = 4.0;
    _visitorBtn.layer.masksToBounds = YES;
    [_visitorBtn setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [_visitorBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_icon"] forState:UIControlStateNormal];
    [_visitorBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_icon_hover"] forState:UIControlStateHighlighted];
    _visitorBtn.titleLabel.font = SKIN_FONT_FROMNAME(18);
    
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        _logoImage.alpha = 1;
        _floatView.alpha = 1;
        CGRect frame = _floatView.frame;
        frame.origin.y = (SCREEN_HEIGHT == 480?self.view.frame.size.height:SCREEN_HEIGHT) - frame.size.height;
        _floatView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack{
//    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:3.0f initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        CGAffineTransform scaleTransform = CGAffineTransformMakeTranslation(0, -self.view.frame.size.height);
//        self.navigationController.view.transform = scaleTransform;
//    } completion:^(BOOL finished)
//     {
//         
//     }];
    
//    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

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
    
    if (_showBackButton) {
        [self goBack];
        return;
    }
    [WYEngine shareInstance].firstLogin = NO;
    [[WYEngine shareInstance] visitorLogin];
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate signIn];
}


@end
