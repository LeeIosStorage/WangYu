//
//  RetrievePwdViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RetrievePwdViewController.h"
#import "SetPwdViewController.h"
#import "NSString+Value.h"
#import "WYProgressHUD.h"
#import "WYEngine.h"

@interface RetrievePwdViewController ()
{
    int _waitSmsSecond;
    NSTimer *_waitTimer;
}
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;
@property (strong, nonatomic) IBOutlet UIButton *getCodeButton;
@property (strong, nonatomic) IBOutlet UIButton *resetPasswordButton;

- (IBAction)getCodeAction:(id)sender;
- (IBAction)fresetPasswordAction:(id)sender;

@end

@implementation RetrievePwdViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_waitTimer) {
        [_waitTimer invalidate];
        _waitTimer = nil;
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    //    [self TextFieldResignFirstResponder];
    if (_waitTimer) {
        [_waitTimer invalidate];
        _waitTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.phoneTextField becomeFirstResponder];
    
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
    [self loginButtonEnabled];
}

- (void)waitTimerInterval:(NSTimer *)aTimer{
    WYLog(@"a Timer waitSmsSecond = %d",_waitSmsSecond);
    if (_waitSmsSecond <= 0) {
        [aTimer invalidate];
        _waitTimer = nil;
        if ([[_phoneTextField text] isPhone]) {
            _getCodeButton.enabled = YES;
            [_getCodeButton setBackgroundColor:SKIN_COLOR];
        }
        [_getCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        return;
    }
    
    [_getCodeButton setTitle:[NSString stringWithFormat:@"%d秒",_waitSmsSecond] forState:UIControlStateNormal];
    
    _waitSmsSecond--;
    
}

- (BOOL)loginButtonEnabled{
    if ([[_phoneTextField text] isPhone]) {
        _getCodeButton.enabled = YES;
        [_getCodeButton setBackgroundColor:SKIN_COLOR];
        if (_codeTextField.text.length > 0) {
            _resetPasswordButton.enabled = YES;
            [_resetPasswordButton setBackgroundColor:SKIN_COLOR];
            return YES;
        }
        _resetPasswordButton.enabled = NO;
        [_resetPasswordButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
        return YES;
    }
    _getCodeButton.enabled = NO;
    [_getCodeButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    _resetPasswordButton.enabled = NO;
    [_resetPasswordButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    return NO;
}

- (void)checkTextChaneg:(NSNotification *)notif
{
    [self loginButtonEnabled];
}

- (void)textFieldResignFirstResponder{
    [self.phoneTextField resignFirstResponder];
    [self.codeTextField resignFirstResponder];
}

#pragma mark - IBAction
- (IBAction)getCodeAction:(id)sender{
    [self getPhoneCode];
}
- (IBAction)fresetPasswordAction:(id)sender{
    [self checkPhoneCode];
}

-(void)getPhoneCode{
    
    _phoneTextField.text = [_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_phoneTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    
    if(_waitTimer){
        [_waitTimer invalidate];
        _waitTimer = nil;
    }
    
    _waitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitTimerInterval:) userInfo:nil repeats:YES];
    _waitSmsSecond = 60;
    _getCodeButton.enabled = NO;
    [_getCodeButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    [self waitTimerInterval:_waitTimer];
    
    [self textFieldResignFirstResponder];
    [WYProgressHUD AlertLoading:@"正在验证手机号" At:self.view];
    __weak RetrievePwdViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getCodeWithPhone:_phoneTextField.text type:nil tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败!";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            _waitSmsSecond = 0;
            [weakSelf waitTimerInterval:_waitTimer];
            return;
        }
        
        [WYProgressHUD AlertSuccess:@"验证码发送成功." At:weakSelf.view];
        
    }tag:tag];
    
}

-(void)checkPhoneCode{
    
    _phoneTextField.text = [_phoneTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_phoneTextField.text.length == 0) {
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
    __weak RetrievePwdViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] checkCodeWithPhone:_phoneTextField.text code:verifyAndemailTextFieldText codeType:nil tag:tag];
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
