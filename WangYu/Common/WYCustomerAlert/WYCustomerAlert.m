//
//  WYCustomerAlert.m
//  WangYu
//
//  Created by XuLei on 15/7/16.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYCustomerAlert.h"

@interface WYCustomerAlert()

@property (nonatomic, strong) UIWindow *oldWindow;
@property (nonatomic, strong) UIWindow *showWindow;

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *lineImageView;
@property (strong, nonatomic) IBOutlet UITextView *noticeTextView;

- (IBAction)dismiss:(id)sender;

@end

@implementation WYCustomerAlert

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"WYCustomerAlert" owner:self options:nil] objectAtIndex:0];
    if (self) {
        [self setSimpleView];
    }
    return self;
}

- (void)setSimpleView{
    self.layer.cornerRadius = 4;
    self.lineImageView.backgroundColor = UIColorToRGB(0xadadad);
    CGRect frame = self.lineImageView.frame;
    frame.size.height = 0.5;
    self.lineImageView.frame = frame;
    
    self.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.titleLabel.font = SKIN_FONT_FROMNAME(15);
    
    self.noticeTextView.textColor = SKIN_TEXT_COLOR4;
    self.noticeTextView.font = SKIN_FONT_FROMNAME(12);
    self.noticeTextView.editable = NO;
}

- (void)show{
    self.noticeTextView.text = self.alertMessage;
    _oldWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect windowFrame = [UIScreen mainScreen].bounds;
    
    _showWindow = [[UIWindow alloc] initWithFrame:windowFrame];
    _showWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    CGRect frame = self.frame;
    frame.origin.x = (_showWindow.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = (_showWindow.bounds.size.height - frame.size.height) / 2;
    self.frame = frame;
    [_showWindow addSubview:self];
    _showWindow.windowLevel = UIWindowLevelAlert;
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
    [_showWindow addGestureRecognizer:gestureRecongnizer];
    
    [_showWindow makeKeyAndVisible];
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self dismiss:nil];
}

- (IBAction)dismiss:(id)sender {
    [self.oldWindow makeKeyAndVisible];
    [self removeFromSuperview];
    if (self.oldWindow) {
        self.oldWindow = nil;
        self.showWindow.hidden = YES;
        self.showWindow = nil;
    }
}

-(void)dealloc
{
    NSLog(@"WYCustomerAlert dealloc");
}

@end
