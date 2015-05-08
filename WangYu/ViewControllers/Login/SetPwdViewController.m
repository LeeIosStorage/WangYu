//
//  SetPwdViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SetPwdViewController.h"
#import "WYProgressHUD.h"
#import "WYEngine.h"
#import "AppDelegate.h"

@interface SetPwdViewController ()

@property (strong, nonatomic) IBOutlet UITextField *setPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *comfirmTextField;
@property (strong, nonatomic) IBOutlet UIButton *comfimAction;

- (IBAction)confirmAction:(id)sender;

@end

@implementation SetPwdViewController

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
    [self textFieldResignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.setPwdTextField becomeFirstResponder];
}

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
    [self setTitle:@"设置密码"];
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
    
    self.setPwdTextField.font = SKIN_FONT(15);
    self.comfirmTextField.font = SKIN_FONT(15);
    self.comfimAction.titleLabel.font = SKIN_FONT(18);
    
    self.comfimAction.backgroundColor = SKIN_COLOR;
    self.comfimAction.layer.cornerRadius = 4;
    self.comfimAction.layer.masksToBounds = YES;
    [self loginButtonEnabled];
}

- (BOOL)loginButtonEnabled{
    if ([[_setPwdTextField text] length] >= 6 && [_comfirmTextField text].length >= 6) {
        _comfimAction.enabled = YES;
        [_comfimAction setBackgroundColor:SKIN_COLOR];
        return YES;
    }
    _comfimAction.enabled = NO;
    [_comfimAction setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    return NO;
}

- (void)checkTextChaneg:(NSNotification *)notif
{
    [self loginButtonEnabled];
}

- (void)textFieldResignFirstResponder{
    [self.setPwdTextField resignFirstResponder];
    [self.setPwdTextField resignFirstResponder];
}

#pragma mark - IBAction
- (IBAction)confirmAction:(id)sender{
    
    _setPwdTextField.text = [_setPwdTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if  (self.setPwdTextField.text.length == 0)
    {
        [self.setPwdTextField becomeFirstResponder];
        [WYProgressHUD AlertError:@"请输入密码"];
        return;
    }
    _comfirmTextField.text = [_comfirmTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if  (self.comfirmTextField.text.length == 0)
    {
        [self.comfirmTextField becomeFirstResponder];
        [WYProgressHUD AlertError:@"请验证密码"];
        return;
    }
    
    if  (self.setPwdTextField.text.length <= 5)
    {
        [self.setPwdTextField becomeFirstResponder];
        [WYProgressHUD AlertError:@"密码需要6位以上"];
        return;
    }
    [self textFieldResignFirstResponder];
    __weak SetPwdViewController *weakSelf = self;
    if ([self.setPwdTextField.text isEqualToString:self.comfirmTextField.text]) {
        int tag = [[WYEngine shareInstance] getConnectTag];
        if (weakSelf.registerName.length != 0) {
            [WYProgressHUD AlertLoading:@"注册中，请稍等" At:weakSelf.view];
            [[WYEngine shareInstance] registerWithPhone:weakSelf.registerName password:weakSelf.setPwdTextField.text invitationCode:weakSelf.invitationCode tag:tag];
            [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
                NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
                if (!jsonRet || errorMsg) {
                    if (!errorMsg.length) {
                        errorMsg = @"网络错误，请稍后重试";
                    }
                    [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                    return;
                }
                [WYProgressHUD AlertSuccess:@"注册成功" At:weakSelf.view];
                NSDictionary *dic = [jsonRet objectForKey:@"object"];
                if (!_userInfo) {
                    _userInfo = [[WYUserInfo alloc] init];
                }
                [_userInfo setUserInfoByJsonDic:dic];
                [weakSelf perfectInformation];
            }tag:tag];
        }else{
            [WYProgressHUD AlertLoading:@"正在重置密码" At:weakSelf.view];
            [[WYEngine shareInstance] resetPassword:self.setPwdTextField.text withPhone:_userInfo.telephone tag:tag];
            [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
                //                [WYProgressHUD AlertLoadDone];
                NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
                if (!jsonRet || errorMsg) {
                    if (!errorMsg.length) {
                        errorMsg = @"获取失败";
                    }
                    [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                    return;
                }
                [WYProgressHUD AlertSuccess:@"重置密码成功" At:weakSelf.view];
                NSDictionary *dic = [jsonRet objectForKey:@"object"];
                if (!_userInfo) {
                    _userInfo = [[WYUserInfo alloc] init];
                }
                [_userInfo setUserInfoByJsonDic:dic];
                [weakSelf perfectInformation];
                
            }tag:tag];
        }
    }else{
        [self.comfirmTextField becomeFirstResponder];
        [WYProgressHUD AlertError:@"两次密码不一致" At:weakSelf.view];
    }
    
}

-(void)loginFinished{
    
    if (_isCanBack) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate signIn];
    }
}

-(void)perfectInformation{
    [WYEngine shareInstance].uid = _userInfo.uid;
    [WYEngine shareInstance].account = _userInfo.account;
    [WYEngine shareInstance].userPassword = self.setPwdTextField.text;
    [[WYEngine shareInstance] saveAccount];
    [[WYEngine shareInstance] setUserInfo:_userInfo];
    [[WYEngine shareInstance] refreshUserInfo];
    
    [self performSelector:@selector(loginFinished) withObject:nil afterDelay:1.0];
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
    
    if (textField == _setPwdTextField) {
        if (newString.length > 15 && textField.text.length >= 15) {
            return NO;
        }
    }else if (textField == _comfirmTextField){
        if (newString.length > 15 && textField.text.length >= 15) {
            return NO;
        }
    }
    return YES;
}

@end
