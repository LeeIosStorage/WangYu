//
//  PayOrderViewCell.m
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PayOrderViewCell.h"
#import "WYCommonUtils.h"

@implementation PayOrderViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.netbarNameLabel.font = SKIN_FONT_FROMNAME(15);
    self.stateLabel.font = SKIN_FONT_FROMNAME(13);
    self.orderTimeLabel.font = SKIN_FONT_FROMNAME(12);
    self.privilegeYuanLabel.font = SKIN_FONT_FROMNAME(12);
    self.redPacketLabel.font = SKIN_FONT_FROMNAME(9);
    self.cancelOrderButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.payOrderButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    
    [self.redPacketLabel.layer setMasksToBounds:YES];
    [self.redPacketLabel.layer setCornerRadius:2.0];
    [self.redPacketLabel.layer setBorderWidth:0.5]; //边框宽度
    [self.redPacketLabel.layer setBorderColor:UIColorRGB(254, 148, 11).CGColor];//边框颜色
    
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

- (IBAction)netbarAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(payOrderViewCellNetbarClickWithCell:)]) {
        [self.delegate payOrderViewCellNetbarClickWithCell:self];
    }
}

- (IBAction)cancelOrderAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(payOrderViewCellCancelClickWithCell:)]) {
        [self.delegate payOrderViewCellCancelClickWithCell:self];
    }
}

- (IBAction)payAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(payOrderViewCellPayClickWithCell:)]) {
        [self.delegate payOrderViewCellPayClickWithCell:self];
    }
}

-(void)setOrderInfo:(WYOrderInfo *)orderInfo{
    _orderInfo = orderInfo;
    
    _orderTimeLabel.text = [WYUIUtils dateDiscriptionFromNowBk:orderInfo.createDate];
    
    NSString *netbarName = orderInfo.netbarName;
    self.netbarNameLabel.text = netbarName;
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
    
    NSString *priceText = [NSString stringWithFormat:@"￥%@",orderInfo.amount];
    self.priceLabel.text = priceText;
    width = [WYCommonUtils widthWithText:priceText font:self.priceLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.priceLabel.frame;
    frame.size.width = width;
    self.priceLabel.frame = frame;
    
    self.privilegeYuanLabel.hidden = YES;
    if (orderInfo.scoreAmount > 0) {
        self.privilegeYuanLabel.hidden = NO;
        NSString *privilegeYuanText = [NSString stringWithFormat:@"%d元",orderInfo.scoreAmount];
        self.privilegeYuanLabel.text = privilegeYuanText;
        width = [WYCommonUtils widthWithText:privilegeYuanText font:self.privilegeYuanLabel.font lineBreakMode:NSLineBreakByWordWrapping];
        frame = self.privilegeYuanLabel.frame;
        frame.origin.x = self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width + 7;
        frame.size.width = width;
        self.privilegeYuanLabel.frame = frame;
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:privilegeYuanText];
        [attrString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, privilegeYuanText.length)];
        self.privilegeYuanLabel.attributedText = attrString;
    }
    
    self.redPacketLabel.hidden = YES;
    if (orderInfo.redbagAmount > 0) {
        self.redPacketLabel.hidden = NO;
        NSString *redPacketText = [NSString stringWithFormat:@"使用%@元红包",[NSNumber numberWithDouble:orderInfo.redbagAmount]];
        self.redPacketLabel.text = redPacketText;
        width = [WYCommonUtils widthWithText:redPacketText font:self.redPacketLabel.font lineBreakMode:NSLineBreakByWordWrapping];
        frame = self.redPacketLabel.frame;
        frame.origin.x = self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width + 7;
        frame.size.width = width+10;
        self.redPacketLabel.frame = frame;
    }
    
    self.cancelOrderButton.hidden = YES;
    self.payOrderButton.hidden = YES;
    self.stateLabel.text = @"支付成功";
    self.stateLabel.textColor = UIColorToRGB(0xf03f3f);
    self.stateLabel.hidden = NO;
    int status = orderInfo.status;
    if (status > 1) {
        status = 1;
    }
    if (orderInfo.isValid == 0) {
        self.stateLabel.text = @"已删除";
        status = 2;//订单已删除
    }
    if (status == 0) {
        self.cancelOrderButton.hidden = NO;
        self.payOrderButton.hidden = NO;
        
        self.stateLabel.text = @"未支付";
        CGRect buttonFrame = self.payOrderButton.frame;
        buttonFrame.origin.x = SCREEN_WIDTH - buttonFrame.size.width - 12;
        self.payOrderButton.frame = buttonFrame;
        buttonFrame = self.cancelOrderButton.frame;
        buttonFrame.origin.x = self.payOrderButton.frame.origin.x - buttonFrame.size.width - 12;
        self.cancelOrderButton.frame = buttonFrame;

    }else if (status == 1){
        //有删除没支付
        self.cancelOrderButton.hidden = NO;
        self.payOrderButton.hidden = YES;
        CGRect buttonFrame = self.cancelOrderButton.frame;
        buttonFrame.origin.x = SCREEN_WIDTH - buttonFrame.size.width - 12;
        self.cancelOrderButton.frame = buttonFrame;
        
    }else if (status == -1){
        //有删除有支付
        self.cancelOrderButton.hidden = NO;
        self.payOrderButton.hidden = NO;
        self.stateLabel.textColor = SKIN_TEXT_COLOR1;
        self.stateLabel.text = @"支付失败";
        
        CGRect buttonFrame = self.payOrderButton.frame;
        buttonFrame.origin.x = SCREEN_WIDTH - buttonFrame.size.width - 12;
        self.payOrderButton.frame = buttonFrame;
        buttonFrame = self.cancelOrderButton.frame;
        buttonFrame.origin.x = self.payOrderButton.frame.origin.x - buttonFrame.size.width - 12;
        self.cancelOrderButton.frame = buttonFrame;
        
    }else if (status ==2){
        //没删除没支付
        self.cancelOrderButton.hidden = YES;
        self.payOrderButton.hidden = YES;
    }else{
        self.stateLabel.hidden = YES;
    }
    
    frame = self.orderTimeLabel.frame;
    if (self.cancelOrderButton.hidden && self.payOrderButton.hidden) {
        frame.size.width = SCREEN_WIDTH-12*2;
    }else if (!self.cancelOrderButton.hidden && !self.payOrderButton.hidden){
        frame.size.width = SCREEN_WIDTH-12*4-self.cancelOrderButton.frame.size.width*2;
    }else{
        frame.size.width = SCREEN_WIDTH-12*3-self.cancelOrderButton.frame.size.width;
    }
    self.orderTimeLabel.frame = frame;
    
}

@end
