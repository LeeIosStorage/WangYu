//
//  FeedBackViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/10.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "FeedBackViewController.h"
#import "WYAlertView.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"

@interface FeedBackViewController ()
{
    int _remainTextNum;
    int _maxTextLength;
    int _maxPhoneTextLength;
}

@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UITextView *inputTextView;
@property (strong, nonatomic) IBOutlet UILabel *remainNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeHolderLabel;

@property (strong, nonatomic) IBOutlet UIView *phoneInputView;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UILabel *phonePlaceHolderLabel;

@property (nonatomic, assign) BOOL bViewDisappear;

@end

@implementation FeedBackViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.inputView.layer setMasksToBounds:YES];
    [self.inputView.layer setCornerRadius:4.0];
    [self.inputView.layer setBorderWidth:0.5]; //边框宽度
    [self.inputView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
    self.placeHolderLabel.font = SKIN_FONT_FROMNAME(14);
    self.placeHolderLabel.textColor = UIColorToRGB(0xc7c7c7);
    
    self.remainNumLabel.font = SKIN_FONT_FROMNAME(12);
    self.remainNumLabel.textColor = UIColorToRGB(0xc7c7c7);
    
    self.inputTextView.font = SKIN_FONT_FROMNAME(14);
    self.inputTextView.textColor = SKIN_TEXT_COLOR1;
    self.placeHolderLabel.text = @"请输入您的意见";
    
    [self.phoneInputView.layer setMasksToBounds:YES];
    [self.phoneInputView.layer setCornerRadius:4.0];
    [self.phoneInputView.layer setBorderWidth:0.5]; //边框宽度
    [self.phoneInputView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
    self.phonePlaceHolderLabel.font = SKIN_FONT_FROMNAME(14);
    self.phonePlaceHolderLabel.textColor = UIColorToRGB(0xc7c7c7);
    self.phonePlaceHolderLabel.text = @"填写你的手机或邮箱";
    
    self.inputTextField.font = SKIN_FONT_FROMNAME(14);
    self.inputTextField.textColor = SKIN_TEXT_COLOR1;
    
    _maxPhoneTextLength = 40;
    _maxTextLength = 200;
    _remainTextNum = _maxTextLength;
    
    [self updateRemainNumLabel];
    [self updatePlaceHolderLabel];
    
    CGSize contentSize = self.mainScrollView.contentSize;
    self.mainScrollView.contentSize = CGSizeMake(contentSize.width, self.phoneInputView.frame.origin.y + self.phoneInputView.frame.size.height+12);
    
    [self.inputTextView becomeFirstResponder];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [self.view addGestureRecognizer:gestureRecongnizer];
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self.inputTextView resignFirstResponder];
    [self.inputTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews
{
    [self setTitle:@"意见反馈"];
    [self setRightButtonWithTitle:@"提交" selector:@selector(submitAction:)];
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
-(void)submitAction:(id)sender{
    
    _inputTextView.text = [[_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (_inputTextView.text.length == 0) {
        WYAlertView *alert = [[WYAlertView alloc] initWithTitle:nil message:@"请输入您的宝贵意见" cancelButtonTitle:@"好的"];
        [alert show];
        return;
    }
    
    [self.inputTextView resignFirstResponder];
    [self.inputTextField resignFirstResponder];
    
    [WYProgressHUD AlertLoading:@"意见提交中..." At:self.view];
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] feedBackMessageWithUid:[WYEngine shareInstance].uid content:_inputTextView.text contact:_inputTextField.text tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertLoadDone];
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"感谢您的反馈，我们会尽快处理" cancelButtonTitle:@"确定" cancelBlock:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [alertView show];
        
    }tag:tag];
    
}


- (void)updatePlaceHolderLabel{
    if (_inputTextView.text.length > 0) {
        _placeHolderLabel.hidden = YES;
    }else{
        _placeHolderLabel.hidden = NO;
    }
    if (_inputTextField.text.length > 0) {
        _phonePlaceHolderLabel.hidden = YES;
    }else{
        _phonePlaceHolderLabel.hidden = NO;
    }
}

- (void)updateRemainNumLabel{
    int existTextNum = [WYCommonUtils getHanziTextNum:_inputTextView.text];
    _remainTextNum = _maxTextLength - existTextNum;
    _remainNumLabel.text = [[NSNumber numberWithInt:_remainTextNum] description];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [self updatePlaceHolderLabel];
    if (text.length == 0) {
        return YES;
    }
    int newLength = [WYCommonUtils getHanziTextNum:[textView.text stringByAppendingString:text]];
    if(newLength >= _maxTextLength && textView.markedTextRange == nil) {
        _remainTextNum = 0;
        _inputTextView.text = [WYCommonUtils getHanziTextWithText:[textView.text stringByReplacingCharactersInRange:range withString:text] maxLength:_maxTextLength];
        [self updatePlaceHolderLabel];
        [self updateRemainNumLabel];
        return NO;
    }
    
    //bug fix输入表情后，连续输入回车后，光标在textview下边，输入文字后，光标也未上升一行，导致输入文字看不到
    [textView scrollRangeToVisible:range];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updatePlaceHolderLabel];
    if (textView.markedTextRange != nil) {
        return;
    }
    
    if ([WYCommonUtils getHanziTextNum:textView.text] > _maxTextLength && textView.markedTextRange == nil) {
        textView.text = [WYCommonUtils getHanziTextWithText:textView.text maxLength:_maxTextLength];
    }
    [self updateRemainNumLabel];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self updatePlaceHolderLabel];
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    if (!string.length && range.length > 0) {
        return YES;
    }
    //    NSString *oldString = [textField.text copy];
    //    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    
    int newLength = [WYCommonUtils getHanziTextNum:[textField.text stringByAppendingString:string]];
    if(newLength >= _maxPhoneTextLength && textField.markedTextRange == nil) {
        _inputTextField.text = [WYCommonUtils getHanziTextWithText:[textField.text stringByReplacingCharactersInRange:range withString:string] maxLength:_maxPhoneTextLength];
        [self updatePlaceHolderLabel];
        return NO;
    }
    return YES;
}
- (void)checkTextChaneg:(NSNotification *)notif
{
    [self updatePlaceHolderLabel];
    if (_inputTextField.markedTextRange != nil) {
        return;
    }
    
    if ([WYCommonUtils getHanziTextNum:_inputTextField.text] > _maxPhoneTextLength && _inputTextField.markedTextRange == nil) {
        _inputTextField.text = [WYCommonUtils getHanziTextWithText:_inputTextField.text maxLength:_maxPhoneTextLength];
    }
}

#pragma mark - KeyboardNotification
-(void) keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    CGRect scrollViewFrame = self.mainScrollView.frame;
    scrollViewFrame.size.height = keyboardBounds.origin.y;
    self.mainScrollView.frame = scrollViewFrame;
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    
    CGRect scrollViewFrame = self.mainScrollView.frame;
    scrollViewFrame.size.height = self.view.frame.size.height - scrollViewFrame.origin.y;
    self.mainScrollView.frame = scrollViewFrame;
    
    // commit animations
    [UIView commitAnimations];
}

@end
