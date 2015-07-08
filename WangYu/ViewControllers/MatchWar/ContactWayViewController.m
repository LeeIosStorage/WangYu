//
//  ContactWayViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ContactWayViewController.h"
#import "WYProgressHUD.h"

#define Title_maxTextLength 10

@interface ContactWayViewController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *tipLabel;
@property (strong, nonatomic) IBOutlet UILabel *YYNumTipLabel;
@property (strong, nonatomic) IBOutlet UITextField *YYTextField;
@property (strong, nonatomic) IBOutlet UILabel *weixinNumTipLabel;
@property (strong, nonatomic) IBOutlet UITextField *weixinTextField;
@property (strong, nonatomic) IBOutlet UILabel *QQNumTipLabel;
@property (strong, nonatomic) IBOutlet UITextField *QQTextField;

@end

@implementation ContactWayViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.YYTextField.text = [_contactDic objectForKey:contact_YY];
    self.weixinTextField.text = [_contactDic objectForKey:contact_WX];
    self.QQTextField.text = [_contactDic objectForKey:contact_QQ];
    [self.YYTextField becomeFirstResponder];
    
    [self refreshViewUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    
    [self setTitle:@"联系方式"];
    [self setRightButtonWithTitle:@"保存" selector:@selector(confirmAction:)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshViewUI{
    self.tipLabel.font = SKIN_FONT_FROMNAME(12);
    self.tipLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.YYNumTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.YYNumTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.YYTextField.font = SKIN_FONT_FROMNAME(14);
    self.YYTextField.textColor = UIColorToRGB(0x666666);
    
    self.weixinNumTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.weixinNumTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.weixinTextField.font = SKIN_FONT_FROMNAME(14);
    self.weixinTextField.textColor = UIColorToRGB(0x666666);
    
    self.QQNumTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.QQNumTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.QQTextField.font = SKIN_FONT_FROMNAME(14);
    self.QQTextField.textColor = UIColorToRGB(0x666666);
}

-(void)confirmAction:(id)sender{
    
    if (self.YYTextField.text.length  == 0 && self.weixinTextField.text.length == 0 && self.QQTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"至少填写一个联系方式"];
        return;
    }
    
    NSMutableDictionary *tmpContactDic = [[NSMutableDictionary alloc] init];
    if (self.YYTextField.text.length > 0) {
        [tmpContactDic setObject:_YYTextField.text forKey:contact_YY];
    }
    if (self.weixinTextField.text.length > 0) {
        [tmpContactDic setObject:_weixinTextField.text forKey:contact_WX];
    }
    if (self.QQTextField.text.length > 0) {
        [tmpContactDic setObject:_QQTextField.text forKey:contact_QQ];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(contactWayViewControllerWithContactDic:)]) {
        [self.delegate contactWayViewControllerWithContactDic:tmpContactDic];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    if (!string.length && range.length > 0) {
        return YES;
    }
    
    int newLength = [WYCommonUtils getHanziTextNum:[textField.text stringByAppendingString:string]];
    if(newLength >= Title_maxTextLength && textField.markedTextRange == nil) {
        if (textField == self.YYTextField) {
            _YYTextField.text = [WYCommonUtils getHanziTextWithText:[textField.text stringByReplacingCharactersInRange:range withString:string] maxLength:Title_maxTextLength];
        }else if (textField == self.weixinTextField){
            _weixinTextField.text = [WYCommonUtils getHanziTextWithText:[textField.text stringByReplacingCharactersInRange:range withString:string] maxLength:Title_maxTextLength];
        }else if (textField == self.QQTextField){
            _QQTextField.text = [WYCommonUtils getHanziTextWithText:[textField.text stringByReplacingCharactersInRange:range withString:string] maxLength:Title_maxTextLength];
        }
        return NO;
    }
    return YES;
}
- (void)checkTextChaneg:(NSNotification *)notif
{
    UITextField *textField = (UITextField *)notif.object;
    if (textField.markedTextRange != nil) {
        return;
    }
    
    if ([WYCommonUtils getHanziTextNum:textField.text] > Title_maxTextLength && textField.markedTextRange == nil) {
        if (textField == self.YYTextField) {
            _YYTextField.text = [WYCommonUtils getHanziTextWithText:_YYTextField.text maxLength:Title_maxTextLength];
        }else if (textField == self.weixinTextField){
            _weixinTextField.text = [WYCommonUtils getHanziTextWithText:_weixinTextField.text maxLength:Title_maxTextLength];
        }else if (textField == self.QQTextField){
            _QQTextField.text = [WYCommonUtils getHanziTextWithText:_QQTextField.text maxLength:Title_maxTextLength];
        }
    }
}

@end
