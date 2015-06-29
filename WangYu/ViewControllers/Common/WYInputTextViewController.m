//
//  WYInputTextViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYInputTextViewController.h"
#import "WYAlertView.h"

@interface WYInputTextViewController ()<UITextViewDelegate>{
    int  _remainTextNum;
}
@property (strong, nonatomic) IBOutlet UITextView *inputTextView;
@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UILabel *remainNumLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeHolderLabel;

@end

@implementation WYInputTextViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
    _inputTextView.keyboardType = _keyboardType;
    
    if (_titleText != nil) {
        [self setTitle:_titleText];
    }
    self.placeHolderLabel.text = _placeHolder;
    
    [self.titleNavBarRightBtn setTitle:@"确认" forState:0];
    
    if (_maxTextLength == 0) {
        _maxTextLength = 40;
    }
    
    _remainTextNum = _maxTextLength;
    if (_oldText) {
        _inputTextView.text = _oldText;
    }
    if (!_maxTextViewHight) {
        _maxTextViewHight = 120;
    }
    
    CGRect viewRect = _inputView.frame;
    viewRect.size.height = _maxTextViewHight;
    _inputView.frame = viewRect;
    
    CGRect textViewRect = _inputTextView.frame;
    textViewRect.size.height = _maxTextViewHight;
    _inputTextView.frame = textViewRect;
    
    [self updateRemainNumLabel];
    [self updatePlaceHolderLabel];
    
    [self.inputTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews
{
    //title
    [self setRightButtonWithTitle:@"确认" selector:@selector(confirmAction:)];
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
    if (_inputTextView.text.length > 0) {
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

- (void)setTitleText:(NSString *)titleText{
    _titleText = titleText;
    [self setTitle:titleText];
}
- (void)confirmAction:(id)sender {
    int existTextNum = [WYCommonUtils getHanziTextNum:_inputTextView.text];
    if (existTextNum < _minTextLength) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"温馨提示！" message:[NSString stringWithFormat:@"不能少于%d个字",_minTextLength] cancelButtonTitle:@"知道了"];
        
        [alertView show];
        return;
    }
    
    _inputTextView.text = [[_inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    if (self.delegate) {
        [self.delegate inputTextViewControllerWithText:_inputTextView.text];
    }
    [self backAction:nil];
}

@end
