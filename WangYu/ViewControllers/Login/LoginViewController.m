//
//  LoginViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "LoginViewController.h"
#import "RetrievePwdViewController.h"
#import "RegisterViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "AppDelegate.h"
#import "NSString+Value.h"

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

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
//    [self TextFieldResignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.accountTextField becomeFirstResponder];
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

#pragma mark - custom
-(void)refreshUIControl{
    self.loginButton.backgroundColor = SKIN_COLOR;
    self.loginButton.layer.cornerRadius = 4;
    self.loginButton.layer.masksToBounds = YES;
    [self.quickRegisterButton setTitleColor:UIColorToRGB(0x387cbc) forState:0];
    [self.forgetPasswordButton setTitleColor:UIColorToRGB(0x387cbc) forState:0];
    [self loginButtonEnabled];
    
}

- (BOOL)loginButtonEnabled{
    if ([[_accountTextField text] isPhone] && ([_passwordTextField text].length >= 6 &&[_passwordTextField text].length <= 15)) {
        _loginButton.enabled = YES;
        self.loginButton.backgroundColor = SKIN_COLOR;
        return YES;
    }
    _loginButton.enabled = NO;
    self.loginButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    return NO;
}

- (void)checkTextChaneg:(NSNotification *)notif
{
    [self loginButtonEnabled];
}

- (void)textFieldResignFirstResponder{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(void)userLogin{
    
    _accountTextField.text = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_accountTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    _passwordTextField.text = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_passwordTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"请输入密码"];
        return;
    }
    [self textFieldResignFirstResponder];
    [WYProgressHUD AlertLoading:@"正在登录..." At:self.view];
    __weak LoginViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] loginWithPhone:_accountTextField.text password:_passwordTextField.text tag:tag error:nil];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"登录成功." At:weakSelf.view];
        
        NSDictionary *object = [[jsonRet dictionaryObjectForKey:@"object"] dictionaryObjectForKey:@"userInfo"];
        WYUserInfo *userInfo = [[WYUserInfo alloc] init];
        [userInfo setUserInfoByJsonDic:object];
        
        [WYEngine shareInstance].uid = userInfo.uid;
        [WYEngine shareInstance].account = _accountTextField.text;
        [WYEngine shareInstance].userPassword = _passwordTextField.text;
        [WYEngine shareInstance].token = [[jsonRet dictionaryObjectForKey:@"object"] stringObjectForKey:@"token"];
        [[WYEngine shareInstance] saveAccount];
        
        [WYEngine shareInstance].userInfo = userInfo;
        
        [weakSelf performSelector:@selector(loginFinished) withObject:nil afterDelay:1.0];
        
    }tag:tag];
    
}
-(void)loginFinished{
    
    if (_isCanBack) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate signIn];
    }
}

#pragma mark - IBAction
- (IBAction)loginAction:(id)sender {
    [self userLogin];
}

- (IBAction)quickRegisterAction:(id)sender {
    RegisterViewController *vc = [[RegisterViewController alloc] init];
    vc.isCanBack = _isCanBack;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)forgetPasswordAction:(id)sender {
    RetrievePwdViewController *vc = [[RetrievePwdViewController alloc] init];
    vc.isCanBack = _isCanBack;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    if (textField == _accountTextField && textField.markedTextRange == nil) {
        if (newString.length > 11 && textField.text.length >= 11) {
            return NO;
        }
    }else if (textField == _passwordTextField){
        if (newString.length > 15 && textField.text.length >= 15) {
            return NO;
        }
    }
    return YES;
}

@end
