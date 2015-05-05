//
//  RegisterViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RegisterViewController.h"
#import "WYAlertView.h"

@interface RegisterViewController ()

@property (nonatomic, strong) IBOutlet UIView *registerContainerView;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *getCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *agreeIconButton;
@property (strong, nonatomic) IBOutlet UIButton *protocolButton;

@property (nonatomic, strong) IBOutlet UIView *invitationCodeView;
@property (nonatomic, strong) IBOutlet UIView *redPacketLeftView;
@property (nonatomic, strong) IBOutlet UIView *redPacketRightView;
@property (strong, nonatomic) IBOutlet UITextField *invitationCodeTextField;
@property (strong, nonatomic) IBOutlet UIButton *invitationAffirmButton;
@property (strong, nonatomic) IBOutlet UIButton *redPacketHelpButton;

- (IBAction)getCodeAction:(id)sender;
- (IBAction)registerAction:(id)sender;
- (IBAction)protocolAction:(id)sender;
- (IBAction)agreeAction:(id)sender;

- (IBAction)invitationAffirmAction:(id)sender;
- (IBAction)helpAction:(id)sender;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.agreeIconButton.selected = YES;
    [self refreshUIControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"用户注册"];
    [self setBarBackgroundColor:UIColorToRGB(0xf5f5f5) showLine:YES];
    [self setRightButtonWithTitle:@"跳过" selector:@selector(officialRegisterAction:)];
    [self.titleNavBarRightBtn setTitleColor:UIColorToRGB(0x387cbc) forState:0];
}

-(void)setVcType:(VcType)vcType{
    _vcType = vcType;
    [self refreshUIControl];
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
    
    self.registerButton.backgroundColor = SKIN_COLOR;
    self.registerButton.layer.cornerRadius = 4;
    self.registerButton.layer.masksToBounds = YES;
    [self.protocolButton setTitleColor:UIColorToRGB(0x387cbc) forState:0];
    
    
    self.invitationAffirmButton.backgroundColor = SKIN_COLOR;
    self.invitationAffirmButton.layer.cornerRadius = 4;
    self.invitationAffirmButton.layer.masksToBounds = YES;
    [self.redPacketHelpButton setTitleColor:UIColorToRGB(0x387cbc) forState:0];
    
    if (_vcType == VcType_Invitation_Code) {
        self.titleNavBarRightBtn.hidden = NO;
        self.registerContainerView.hidden = YES;
        self.invitationCodeView.hidden = NO;
        [self setTitle:@"输入邀请码"];
        CGRect frame = self.invitationCodeView.frame;
        frame.origin.x = self.registerContainerView.frame.origin.x;
        frame.origin.y = 64;
        self.invitationCodeView.frame = frame;
        [self.view addSubview:self.invitationCodeView];
        
    }else if (_vcType == VcType_Register){
        self.titleNavBarRightBtn.hidden = YES;
        self.registerContainerView.hidden = NO;
        self.invitationCodeView.hidden = YES;
        [self setTitle:@"用户注册"];
    }
}

- (void)skipInvitationCode:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:1.0 animations:^{
            CGRect frame = self.redPacketLeftView.frame;
            frame.origin.x = -(self.redPacketLeftView.frame.size.width + 12);
            self.redPacketLeftView.frame = frame;
            
            frame = self.redPacketRightView.frame;
            frame.origin.x = self.view.bounds.size.width;
            self.redPacketRightView.frame = frame;
            
        } completion:^(BOOL finished){
            
            
            [self performSelector:@selector(invitationCodeRemove) withObject:nil afterDelay:0.004];
            self.vcType = VcType_Register;
            self.registerContainerView.hidden = NO;
            self.invitationCodeView.hidden = NO;
            
            
            CGRect frame = self.registerContainerView.frame;
            frame.origin.y = -self.registerContainerView.frame.size.height;
            self.registerContainerView.frame = frame;
            
            [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:20 options:UIViewAnimationOptionTransitionCurlUp animations:^{
                CGAffineTransform scaleTransform = CGAffineTransformMakeTranslation(0, self.registerContainerView.frame.size.height + 78);
                self.registerContainerView.transform = scaleTransform;
                
            } completion:^(BOOL finished)
             {
                 
             }];
            
            [UIView animateWithDuration:1.0 animations:^{
                CGRect frame = self.invitationCodeView.frame;
                frame.origin.y = self.registerContainerView.frame.origin.y + self.registerContainerView.frame.size.height + 20;
                self.invitationCodeView.frame = frame;
                
            } completion:^(BOOL finished) {
//                self.vcType = VcType_Register;
//                self.registerContainerView.hidden = NO;
//                self.invitationCodeView.hidden = NO;
//                
//                
//                CGRect frame = self.registerContainerView.frame;
//                frame.origin.y = -self.registerContainerView.frame.size.height;
//                self.registerContainerView.frame = frame;
//                
//                [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:20 options:UIViewAnimationOptionTransitionCurlUp animations:^{
//                    CGAffineTransform scaleTransform = CGAffineTransformMakeTranslation(0, self.registerContainerView.frame.size.height + 78);
//                    self.registerContainerView.transform = scaleTransform;
//                    
//                } completion:^(BOOL finished)
//                 {
//                     
//                 }];
            }];
        }];
    }else{
        self.invitationCodeView.hidden = YES;
        [self.invitationCodeView removeFromSuperview];
        self.vcType = VcType_Register;
    }
}

-(void)invitationCodeRemove{
    [UIView animateWithDuration:0.15 animations:^{
        CGRect frame = self.invitationCodeView.frame;
        frame.origin.y = 550;
        self.invitationCodeView.frame = frame;
        
    } completion:^(BOOL finished) {
        [self.invitationCodeView removeFromSuperview];
        self.vcType = VcType_Register;
    }];
}

#pragma mark - IBAction
- (void)officialRegisterAction:(id)sender{
    
    __weak RegisterViewController *weakSelf = self;
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"确定跳过使用邀请码吗？" cancelButtonTitle:@"取消" cancelBlock:^{
        
    } okButtonTitle:@"确定" okBlock:^{
        weakSelf.titleNavBarRightBtn.enabled = NO;
        [weakSelf skipInvitationCode:YES];
    }];
    [alertView show];
}
- (IBAction)getCodeAction:(id)sender{
    
}
- (IBAction)registerAction:(id)sender{
    if (!self.agreeIconButton.selected) {
        [WYUIUtils showAlertWithMsg:@"请先阅读网娱大师客户端"];
        return;
    }
}
- (IBAction)protocolAction:(id)sender{
    
}
- (IBAction)agreeAction:(id)sender{
    self.agreeIconButton.selected = !self.agreeIconButton.selected;
}


- (IBAction)invitationAffirmAction:(id)sender{
    
}

- (IBAction)helpAction:(id)sender{
    
}

@end
