//
//  ReserveOrderViewCell.m
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ReserveOrderViewCell.h"
#import "WYCommonUtils.h"

@implementation ReserveOrderViewCell

- (void)awakeFromNib {
    // Initialization code
    self.netbarNameLabel.font = SKIN_FONT_FROMNAME(15);
    self.stateLabel.font = SKIN_FONT_FROMNAME(13);
    self.orderTimeLabel.font = SKIN_FONT_FROMNAME(12);
    self.openTimeLabel.font = SKIN_FONT_FROMNAME(12);
    self.seatLabel.font = SKIN_FONT_FROMNAME(12);
    self.introLabel.font = SKIN_FONT_FROMNAME(12);
    self.cancelOrderButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.payOrderButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    
    [self.cancelOrderButton.layer setMasksToBounds:YES];
    [self.cancelOrderButton.layer setCornerRadius:4.0];
    [self.cancelOrderButton.layer setBorderWidth:0.5]; //边框宽度
    [self.cancelOrderButton.layer setBorderColor:UIColorRGB(51, 51, 51).CGColor];//边框颜色
    
    [self.payOrderButton.layer setMasksToBounds:YES];
    [self.payOrderButton.layer setCornerRadius:4.0];
    [self.payOrderButton.layer setBorderWidth:0.5]; //边框宽度
    [self.payOrderButton.layer setBorderColor:UIColorRGB(240, 63, 63).CGColor];//边框颜色
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOrderInfo:(NSDictionary *)orderInfo{
    
    NSString *netbarName = self.netbarNameLabel.text;
    float width = [WYCommonUtils widthWithText:netbarName font:self.netbarNameLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    if (width > (SCREEN_WIDTH - 135)) {
        width = (SCREEN_WIDTH - 135);
    }
    CGRect frame = self.netbarNameLabel.frame;
    frame.size.width = width;
    self.netbarNameLabel.frame = frame;
    
    frame = self.indicatorImageView.frame;
    frame.origin.x = self.netbarNameLabel.frame.origin.x + self.netbarNameLabel.frame.size.width + 6;
    self.indicatorImageView.frame = frame;
    
    NSString *seatText = self.seatLabel.text;
    width = [WYCommonUtils widthWithText:seatText font:self.seatLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.seatImageViewIcon.frame;
    frame.origin.x = SCREEN_WIDTH - width - 12 - 5 - frame.size.width;
    self.seatImageViewIcon.frame = frame;
    
    self.cancelOrderButton.hidden = YES;
    self.payOrderButton.hidden = YES;
    int state = 4;
    if (state == 1) {
        self.cancelOrderButton.hidden = YES;
        self.payOrderButton.hidden = YES;
    }else if (state == 2){
        self.cancelOrderButton.hidden = NO;
        self.payOrderButton.hidden = YES;
        CGRect buttonFrame = self.cancelOrderButton.frame;
        buttonFrame.origin.x = SCREEN_WIDTH - buttonFrame.size.width - 12;
        self.cancelOrderButton.frame = buttonFrame;
        
    }else if (state == 3){
        self.cancelOrderButton.hidden = YES;
        self.payOrderButton.hidden = NO;
        CGRect buttonFrame = self.payOrderButton.frame;
        buttonFrame.origin.x = SCREEN_WIDTH - buttonFrame.size.width - 12;
        self.payOrderButton.frame = buttonFrame;
        
    }else if (state == 4){
        self.cancelOrderButton.hidden = NO;
        self.payOrderButton.hidden = NO;
        CGRect buttonFrame = self.payOrderButton.frame;
        buttonFrame.origin.x = SCREEN_WIDTH - buttonFrame.size.width - 12;
        self.payOrderButton.frame = buttonFrame;
        buttonFrame = self.cancelOrderButton.frame;
        buttonFrame.origin.x = self.payOrderButton.frame.origin.x - buttonFrame.size.width - 12;
        self.cancelOrderButton.frame = buttonFrame;
        
    }
    
    frame = self.introLabel.frame;
    if (self.cancelOrderButton.hidden && self.payOrderButton.hidden) {
        frame.size.width = SCREEN_WIDTH-12*2;
    }else if (!self.cancelOrderButton.hidden && !self.payOrderButton.hidden){
        frame.size.width = SCREEN_WIDTH-12*4-self.cancelOrderButton.frame.size.width*2;
    }else{
        frame.size.width = SCREEN_WIDTH-12*3-self.cancelOrderButton.frame.size.width;
    }
    self.introLabel.frame = frame;
    
}

@end
