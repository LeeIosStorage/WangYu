//
//  MessageDetailsViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MessageDetailsViewController.h"
#import "TTTAttributedLabel.h"

@interface MessageDetailsViewController ()

@property (strong, nonatomic) IBOutlet UILabel *msgTitleLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *msgDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *msgTimeLabel;

@end

@implementation MessageDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshShowUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"消息详情"];
//    if (_messageInfo.title.length > 0) {
//        [self setTitle:_messageInfo.title];
//    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshShowUI{
    self.msgTitleLabel.textColor = SKIN_TEXT_COLOR1;
    self.msgTitleLabel.font = SKIN_FONT_FROMNAME(15);
//    self.msgDescriptionLabel.textColor = SKIN_TEXT_COLOR2;
//    self.msgDescriptionLabel.font = SKIN_FONT_FROMNAME(12);
    self.msgTimeLabel.textColor = SKIN_TEXT_COLOR2;
    self.msgTimeLabel.font = SKIN_FONT_FROMNAME(11);
    
    self.msgTitleLabel.text = _messageInfo.title;
    self.msgTimeLabel.text = [WYUIUtils dateDiscriptionFromNowBk:_messageInfo.createDate];
//    self.msgTimeLabel.text = @"2015-06-15 09:15";
    
//    self.msgDescriptionLabel.lineHeightMultiple = 1.3;
    NSString *content = _messageInfo.content;
//    content = @"消息消息升级了消息消息升级了消息消息升级了消息消息升级了消息消息升级了消息消息升级了消息消息升级了消息";
    self.msgDescriptionLabel.text = content;
    
    CGSize textSize = [WYCommonUtils sizeWithText:content font:self.msgDescriptionLabel.font width:SCREEN_WIDTH-24];
    CGRect frame = self.msgDescriptionLabel.frame;
    frame.size.height = textSize.height;
    self.msgDescriptionLabel.frame = frame;
    
    frame = self.msgTimeLabel.frame;
    frame.origin.y = self.msgDescriptionLabel.frame.origin.y + self.msgDescriptionLabel.frame.size.height + 8;
    self.msgTimeLabel.frame = frame;
    
}

@end
