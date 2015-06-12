//
//  RegisterViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RegisterViewController.h"
#import "WYAlertView.h"
#import "WYProgressHUD.h"
#import "WYEngine.h"
#import "NSString+Value.h"
#import "SetPwdViewController.h"
#import "WYLinkerHandler.h"
#import "WYSettingConfig.h"

@interface RegisterViewController ()<WYSettingConfigListener>
{
    NSString *_invitationCodeText;
    
    int _waitSmsSecond;
//    NSTimer *_waitTimer;
}
@property (nonatomic, strong) IBOutlet UIView *registerContainerView;
@property (nonatomic, strong) IBOutlet UILabel *phoneTipLabel;
@property (nonatomic, strong) IBOutlet UILabel *codeTipLabel;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *getCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *agreeIconButton;
@property (strong, nonatomic) IBOutlet UIButton *protocolButton;

@property (nonatomic, strong) IBOutlet UIView *invitationCodeView;
@property (nonatomic, strong) IBOutlet UIView *redPacketLeftView;
@property (nonatomic, strong) IBOutlet UILabel *symbolIconLabel;
@property (nonatomic, strong) IBOutlet UILabel *moneyLabel;
@property (nonatomic, strong) IBOutlet UIView *redPacketRightView;
@property (nonatomic, strong) IBOutlet UILabel *redPacketTipLabel;
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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    if (_waitTimer) {
//        [_waitTimer invalidate];
//        _waitTimer = nil;
//    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
    [[WYSettingConfig staticInstance] addListener:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[WYSettingConfig staticInstance] removeListener:self];
    
    //    [self TextFieldResignFirstResponder];
//    if (_waitTimer) {
//        [_waitTimer invalidate];
//        _waitTimer = nil;
//    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_vcType == VcType_Invitation_Code) {
        [self.invitationCodeTextField becomeFirstResponder];
    }else if (_vcType == VcType_Register){
        [self.phoneTextField becomeFirstResponder];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    self.phoneTextField.text = [[WYEngine shareInstance] getMemoryLoginedAccout];
    self.view.backgroundColor = [UIColor whiteColor];
    _invitationCodeText = nil;
    self.agreeIconButton.selected = YES;
    _waitSmsSecond = [[WYSettingConfig staticInstance] getRegisterSecond];
    [self refreshUIControl];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self.view addGestureRecognizer:gestureRecongnizer];
    
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self textFieldResignFirstResponder];
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

//- (void)waitTimerInterval:(NSTimer *)aTimer{
//    WYLog(@"a Timer waitSmsSecond = %d",_waitSmsSecond);
//    if (_waitSmsSecond <= 0) {
//        [aTimer invalidate];
//        _waitTimer = nil;
//        if ([[_phoneTextField text] isPhone]) {
//            _getCodeButton.enabled = YES;
//            [_getCodeButton setBackgroundColor:SKIN_COLOR];
//        }
//        [_getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//        return;
//    }
//    
//    [_getCodeButton setTitle:[NSString stringWithFormat:@"%d秒",_waitSmsSecond] forState:UIControlStateNormal];
//    
//    _waitSmsSecond--;
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (void)officialRegisterAction:(id)sender{
    
    self.titleNavBarRightBtn.enabled = NO;
    [self skipInvitationCode:YES];
    
//    __weak RegisterViewController *weakSelf = self;
//    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"确定跳过使用邀请码吗？" cancelButtonTitle:@"取消" cancelBlock:^{
//        
//    } okButtonTitle:@"确定" okBlock:^{
//        
//    }];
//    [alertView show];
}
- (IBAction)getCodeAction:(id)sender{
    [self getPhoneCode];
}
- (IBAction)registerAction:(id)sender{
    if (!self.agreeIconButton.selected) {
        [WYUIUtils showAlertWithMsg:@"请先阅读网娱大师客户端协议"];
        return;
    }
    [self checkPhoneCode];
}
- (IBAction)protocolAction:(id)sender{
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/agreement", [WYEngine shareInstance].baseUrl] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)agreeAction:(id)sender{
    self.agreeIconButton.selected = !self.agreeIconButton.selected;
}


- (IBAction)invitationAffirmAction:(id)sender{
    [self checkInvitationCode];
}

- (IBAction)helpAction:(id)sender{
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/redbag/web/help", [WYEngine shareInstance].baseUrl] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - custom
-(void)refreshUIControl{
    
    self.phoneTextField.font = SKIN_FONT_FROMNAME(15);
    self.codeTextField.font = SKIN_FONT_FROMNAME(15);
    self.getCodeButton.titleLabel.font = SKIN_FONT_FROMNAME(16);
    self.registerButton.titleLabel.font = SKIN_FONT_FROMNAME(18);
    self.protocolButton.titleLabel.font = SKIN_FONT_FROMNAME(12);
    self.invitationCodeTextField.font = SKIN_FONT_FROMNAME(15);
    self.invitationAffirmButton.titleLabel.font = SKIN_FONT_FROMNAME(18);
    self.redPacketHelpButton.titleLabel.font = SKIN_FONT_FROMNAME(12);
    self.phoneTipLabel.font = SKIN_FONT_FROMNAME(16);
    self.codeTipLabel.font = SKIN_FONT_FROMNAME(14);
//    self.symbolIconLabel.font = SKIN_FONT(33);
//    self.moneyLabel.font = SKIN_FONT(66);
    self.redPacketTipLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.getCodeButton.backgroundColor = SKIN_COLOR;
    self.getCodeButton.layer.cornerRadius = 4;
    self.getCodeButton.layer.masksToBounds = YES;
    
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
        self.redPacketTipLabel.text = @"注册成功即可获得10元上网红包";
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
    [self loginButtonEnabled];
}

- (void)skipInvitationCode:(BOOL)animation{
    if (animation) {
        [self textFieldResignFirstResponder];
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
            /*
            [UIView animateWithDuration:1.0 animations:^{
                CGRect frame = self.invitationCodeView.frame;
                frame.origin.y = self.registerContainerView.frame.origin.y + self.registerContainerView.frame.size.height + 20;
                self.invitationCodeView.frame = frame;
                
            } completion:^(BOOL finished) {
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
            }];
             */
        }];
    }else{
        self.invitationCodeView.hidden = YES;
        [self.invitationCodeView removeFromSuperview];
        self.vcType = VcType_Register;
    }
}

- (BOOL)loginButtonEnabled{
    if ([[_phoneTextField text] isPhone]) {
        if (_waitSmsSecond <= 0) {
            _getCodeButton.enabled = YES;
            [_getCodeButton setBackgroundColor:SKIN_COLOR];
        }else{
            _getCodeButton.enabled = NO;
            [_getCodeButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
        }
        if (_codeTextField.text.length >= 6) {
            _registerButton.enabled = YES;
            [_registerButton setBackgroundColor:SKIN_COLOR];
            return YES;
        }
        _registerButton.enabled = NO;
        [_registerButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
        return YES;
    }
    _getCodeButton.enabled = NO;
    [_getCodeButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    _registerButton.enabled = NO;
    [_registerButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    return NO;
}

- (void)checkTextChaneg:(NSNotification *)notif
{
    [self loginButtonEnabled];
}

- (void)textFieldResignFirstResponder{
    [self.invitationCodeTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.codeTextField resignFirstResponder];
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

-(void)checkInvitationCode{
    
    _invitationCodeTextField.text = [_invitationCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_invitationCodeTextField.text.length == 0) {
        [self officialRegisterAction:nil];
        return;
    }
    [self textFieldResignFirstResponder];
    [WYProgressHUD AlertLoading:@"正在验证邀请码" At:self.view];
    __weak RegisterViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] checkInvitationCodeWithCode:_invitationCodeTextField.text tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"验证成功." At:weakSelf.view];
        _invitationCodeText = weakSelf.invitationCodeTextField.text;
        
        weakSelf.titleNavBarRightBtn.enabled = NO;
        [weakSelf skipInvitationCode:YES];
        
    }tag:tag];
    
}

-(void)getPhoneCode{
    
    _phoneTextField.text = [_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_phoneTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    
//    if(_waitTimer){
//        [_waitTimer invalidate];
//        _waitTimer = nil;
//    }
//    
//    _waitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitTimerInterval:) userInfo:nil repeats:YES];
//    _waitSmsSecond = 60;
//    [self waitTimerInterval:_waitTimer];
    
    [[WYSettingConfig staticInstance] addRegisterTimer];
    _getCodeButton.enabled = NO;
    [_getCodeButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    
    [self textFieldResignFirstResponder];
    [WYProgressHUD AlertLoading:@"正在验证手机号" At:self.view];
    __weak RegisterViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getCodeWithPhone:_phoneTextField.text type:@"1" tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败!";
            }
            [[WYSettingConfig staticInstance] removeRegisterTimer];
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            _waitSmsSecond = 0;
            [weakSelf waitRegisterTimer:nil waitSecond:_waitSmsSecond];
            return;
        }
        
        [WYProgressHUD AlertSuccess:@"验证码发送成功." At:weakSelf.view];
        
    }tag:tag];
    
}

#pragma mark - WYSettingConfigListener
- (void)waitRegisterTimer:(NSTimer *)aTimer waitSecond:(int)waitSecond{
    _waitSmsSecond = waitSecond;
    WYLog(@"waitRegisterTimer waitSecond = %d",_waitSmsSecond);
    if (_waitSmsSecond <= 0) {
        if ([[_phoneTextField text] isPhone]) {
            _getCodeButton.enabled = YES;
            [_getCodeButton setBackgroundColor:SKIN_COLOR];
        }
        [_getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        return;
    }
    
    [_getCodeButton setTitle:[NSString stringWithFormat:@"%d秒",_waitSmsSecond] forState:UIControlStateNormal];
    [_getCodeButton setTitle:[NSString stringWithFormat:@"%d秒",_waitSmsSecond] forState:UIControlStateDisabled];
}

-(void)checkPhoneCode{
    
    NSString *phoneTextFieldText = [_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (phoneTextFieldText.length == 0) {
        [WYProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    NSString *verifyAndemailTextFieldText = [_codeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (verifyAndemailTextFieldText.length == 0) {
        [WYProgressHUD lightAlert:@"请输入验证码"];
        return;
    }
    [self textFieldResignFirstResponder];
    [WYProgressHUD AlertLoading:@"正在验证,请稍等" At:self.view];
    __weak RegisterViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] checkCodeWithPhone:phoneTextFieldText code:verifyAndemailTextFieldText codeType:@"1" tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [WYProgressHUD AlertLoadDone];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYUIUtils showAlertWithMsg:errorMsg];
            return;
        }
        SetPwdViewController *spVc = [[SetPwdViewController alloc] init];
        spVc.isCanBack = _isCanBack;
        spVc.registerName = phoneTextFieldText;
        spVc.invitationCode = _invitationCodeText;
        [weakSelf.navigationController pushViewController:spVc animated:YES];
        
    }tag:tag];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    if (!string.length && range.length > 0) {
        return YES;
    }
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == _phoneTextField && textField.markedTextRange == nil) {
        if (newString.length > 11 && textField.text.length >= 11) {
            return NO;
        }
    }
    return YES;
}

@end
