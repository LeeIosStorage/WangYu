//
//  WYInputViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/25.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYInputViewController.h"
#import "WYAlertView.h"
#import "NSString+Value.h"

@interface WYInputViewController ()<UITextViewDelegate,UITextFieldDelegate>{
    int  _remainTextNum;
}
@property (strong, nonatomic) IBOutlet UITextView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputTextField;
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UIImageView *inputBgImageView;
@property (strong, nonatomic) IBOutlet UILabel *remainNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeHolderLabel;

@end

@implementation WYInputViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [self.inputView.layer setMasksToBounds:YES];
    [self.inputView.layer setCornerRadius:4.0];
    [self.inputView.layer setBorderWidth:0.5]; //边框宽度
    [self.inputView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
    self.placeHolderLabel.font = SKIN_FONT_FROMNAME(14);
    self.placeHolderLabel.textColor = SKIN_TEXT_COLOR2;
    
//    self.inputTextView.font = SKIN_FONT_FROMNAME(14);
//    self.inputTextView.textColor = SKIN_TEXT_COLOR1;
//    _inputTextView.keyboardType = _keyboardType;
    
    self.inputTextField.font = SKIN_FONT_FROMNAME(14);
    self.inputTextField.textColor = SKIN_TEXT_COLOR1;
    _inputTextField.keyboardType = _keyboardType;
    
    //    _inputBgImageView.image = [[UIImage imageNamed:@"verify_commit_bg"] stretchableImageWithLeftCapWidth:124 topCapHeight:20];
    
    if (_titleText != nil) {
        [self setTitle:_titleText];
        self.placeHolderLabel.text = [NSString stringWithFormat:@"输入%@",_titleText];
        if ([_toolRightType isEqualToString:@"wy_Server"]) {
            self.placeHolderLabel.text = @"请输入正确服务器";
        }
    }
    
    if ([_toolRightType isEqualToString:@"wy_Server"]) {
        [self.titleNavBarRightBtn setTitle:@"下一步" forState:0];
    }else{
        [self.titleNavBarRightBtn setTitle:@"提交" forState:0];
    }
    
    if (_maxTextLength == 0) {
        _maxTextLength = 20;
    }
    
    _remainTextNum = _maxTextLength;
    if (_oldText) {
//        _inputTextView.text = _oldText;
        _inputTextField.text = _oldText;
    }
    if (!_maxTextViewHight) {
        _maxTextViewHight = 39.0f;
    }
    
    CGRect viewRect = _inputView.frame;
    viewRect.size.height = _maxTextViewHight;
    _inputView.frame = viewRect;
    
//    CGRect textViewRect = _inputTextView.frame;
//    textViewRect.size.height = _maxTextViewHight-10;
//    _inputTextView.frame = textViewRect;
    
    [self updateRemainNumLabel];
    [self updatePlaceHolderLabel];
    
//    [self.inputTextView becomeFirstResponder];
    [self.inputTextField becomeFirstResponder];
    
}
-(void)initNormalTitleNavBarSubviews
{
    //title
    [self setRightButtonWithTitle:@"提交" selector:@selector(confirmAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)updatePlaceHolderLabel{
    if (_inputTextField.text.length > 0) {
        _placeHolderLabel.hidden = YES;
    }else{
        _placeHolderLabel.hidden = NO;
    }
}

- (void)updateRemainNumLabel{
    int existTextNum = [WYCommonUtils getHanziTextNum:_inputTextView.text];
    _remainTextNum = _maxTextLength - existTextNum;
    _remainNumLabel.text = [[NSNumber numberWithInt:_remainTextNum] description];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    [self updatePlaceHolderLabel];
    if (text.length == 0) {
        return YES;
    }
    int newLength = [WYCommonUtils getHanziTextNum:[textView.text stringByAppendingString:text]];
    if(newLength >= _maxTextLength && textView.markedTextRange == nil) {
        _remainTextNum = 0;
        _inputTextView.text = [WYCommonUtils getHanziTextWithText:[textView.text stringByReplacingCharactersInRange:range withString:text] maxLength:_maxTextLength];
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

- (void)setTitleText:(NSString *)titleText{
    _titleText = titleText;
    [self setTitle:titleText];
}
- (void)confirmAction:(id)sender {
    if ([_toolRightType isEqualToString:@"wy_IDCard"]) {
        if (![_inputTextField.text validateIdentityCard]) {
            WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"请输入正确的身份证号"] cancelButtonTitle:@"好的"];
            
            [alertView show];
            return;
        }
    }else if ([_toolRightType isEqualToString:@"wy_Server"]){
        [self selectGameServer];
        return;
    }else{
        int existTextNum = [WYCommonUtils getHanziTextNum:_inputTextField.text];
        if (existTextNum < _minTextLength) {
            WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"温馨提示！" message:[NSString stringWithFormat:@"不能少于%d个字",_minTextLength] cancelButtonTitle:@"知道了"];
            
            [alertView show];
            return;
        }
    }
    
    _inputTextField.text = [[_inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewControllerWithText:)]) {
        [self.delegate inputViewControllerWithText:_inputTextField.text];
    }
    [self backAction:nil];
}

-(void)selectGameServer{
    _inputTextField.text = [[_inputTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    if (_inputTextField.text.length == 0) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"请输入正确的服务器" cancelButtonTitle:@"好的"];
        [alertView show];
        return;
    }
    
    NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:_gameDic];
    if (_inputTextField.text) {
        [tmpDic setObject:_inputTextField.text forKey:@"game_server"];
    }
//    [self.navigationController popViewControllerAnimated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewControllerWithGameDic:)]) {
        [self.delegate inputViewControllerWithGameDic:tmpDic];
    }
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
    if(newLength >= _maxTextLength && textField.markedTextRange == nil) {
        _inputTextField.text = [WYCommonUtils getHanziTextWithText:[textField.text stringByReplacingCharactersInRange:range withString:string] maxLength:_maxTextLength];
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
    
    if ([WYCommonUtils getHanziTextNum:_inputTextField.text] > _maxTextLength && _inputTextField.markedTextRange == nil) {
        _inputTextField.text = [WYCommonUtils getHanziTextWithText:_inputTextField.text maxLength:_maxTextLength];
    }
}

@end
