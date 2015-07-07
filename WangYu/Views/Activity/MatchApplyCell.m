//
//  MatchApplyCell.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchApplyCell.h"

@interface MatchApplyCell()<UITextFieldDelegate>

@end

@implementation MatchApplyCell

- (void)awakeFromNib {
    // Initialization code
    
    self.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.titleLabel.font = SKIN_FONT_FROMNAME(14);
    
    self.textField.textColor = UIColorToRGB(0x666666);
    self.textField.font = SKIN_FONT_FROMNAME(14);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputFieldDidEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setbottomLineWithType:(int)type{
    //1 为全长，0为短线
    if (type == 1) {
        CGRect frame = CGRectMake(0, self.frame.size.height - 1, SCREEN_WIDTH, 1);
        _sepline.frame = frame;
    }else if (type == 0){
        CGRect frame = CGRectMake(12, self.frame.size.height - 1, SCREEN_WIDTH - 12, 1);
        _sepline.frame = frame;
    }
}

//设置获取焦点
-(void) setIsFirstResponder:(BOOL)isFirstResponder
{
    if (isFirstResponder) {
        [_textField becomeFirstResponder];
    }else{
        [_textField resignFirstResponder];
    }
}

-(BOOL)isFirstResponder
{
    return _textField.isFirstResponder;
}

//加delegate ios7 对联想的不会进入delegate
-(void) inputFieldDidChanged:(NSNotification *) noti
{
    UITextField *textField = noti.object;
    if (![textField isEqual:_textField]) {
        return;
    }
    
    NSLog(@"noti = %@", noti);
    NSString *text = textField.text;
    if (_delegate) {
        [_delegate textDidChanged:self cellContent:text];
    }
}

- (void) inputFieldDidEditing:(NSNotification *) noti{
    UITextField *textField = noti.object;
    if (![textField isEqual:_textField]) {
        return;
    }
    if (_delegate) {
        [_delegate textDidEditing:self];
    }
}

#pragma mark -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (![textField isEqual:_textField]) {
        return YES;
    }
    [textField resignFirstResponder];
    return YES;
}

-(void)dealloc
{
    NSLog(@"MatchApplyCell dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
