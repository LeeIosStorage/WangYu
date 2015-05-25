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
- (IBAction)netbarAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(reserveOrderViewCellNetbarClickWithCell:)]) {
        [self.delegate reserveOrderViewCellNetbarClickWithCell:self];
    }
}

- (IBAction)cancelOrderAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(reserveOrderViewCellCancelClickWithCell:)]) {
        [self.delegate reserveOrderViewCellCancelClickWithCell:self];
    }
}

- (IBAction)payAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(reserveOrderViewCellPayClickWithCell:)]) {
        [self.delegate reserveOrderViewCellPayClickWithCell:self];
    }
}

-(void)setOrderInfo:(WYOrderInfo *)orderInfo{
    _orderInfo = orderInfo;
    
    _orderTimeLabel.text = [WYUIUtils dateDiscriptionFromNowBk:orderInfo.reservationDate];
    
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
    
    frame = self.openImageViewIcon.frame;
    frame.origin.x = SCREEN_WIDTH/2 - frame.size.width-5;
    self.openImageViewIcon.frame = frame;
    NSString *hoursText = [NSString stringWithFormat:@"%d小时",orderInfo.hours];
    self.openTimeLabel.text = hoursText;
    frame = self.openTimeLabel.frame;
    frame.origin.x = self.openImageViewIcon.frame.origin.x + self.openImageViewIcon.frame.size.width + 5;
    self.openTimeLabel.frame = frame;
    
    NSString *seatText = [NSString stringWithFormat:@"%d个座位",orderInfo.seating];
    self.seatLabel.text = seatText;
    width = [WYCommonUtils widthWithText:seatText font:self.seatLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.seatImageViewIcon.frame;
    frame.origin.x = SCREEN_WIDTH - width - 12 - 5 - frame.size.width;
    self.seatImageViewIcon.frame = frame;
    
    
    int state = 1;
    NSString *stateLabelText = @"";
    NSString *introLabelText = @"";
    int isValid = orderInfo.isValid;
    if (isValid == 0) {
        stateLabelText = @"已取消";
        introLabelText = @"您已取消该预订";
    }else if (isValid == 1){
        stateLabelText = @"待处理";
        introLabelText = @"您已提交订单，请等待网吧处理";
        state = 2;
    }else if (isValid == 2){
        stateLabelText = @"支付成功";
    }
    int isReceive = orderInfo.isReceive;
    if (isReceive == 1) {
        stateLabelText = @"已接单";
        if (orderInfo.price == 0) {
            introLabelText = @"网吧已接单，可放心前往上网";
            state = 2;
        }else{
            introLabelText = @"网吧已接单，请先支付定金";
            state = 4;
            [self.payOrderButton setTitle:@"支付定金" forState:0];
        }
    }else if (isReceive == 0){
        stateLabelText = @"待处理";
        introLabelText = @"您已提交订单，请等待网吧处理";
        state = 2;
    }else if (isReceive == -1){
        stateLabelText = @"已拒单";
        introLabelText = @"网吧已拒单，原因：";
    }
    int status = orderInfo.status;
    if (status == -1) {
        stateLabelText = @"支付失败";
        introLabelText = @"定金支付失败";
        state = 4;
        [self.payOrderButton setTitle:@"继续支付" forState:0];
    }else if (status == 1){
        stateLabelText = @"已支付";
        introLabelText = @"您已支付成功，请到网吧退还押金";
    }
    if([orderInfo.amount isEqualToString:@"0"])
        state = 2;
    self.stateLabel.text = stateLabelText;
    self.introLabel.text = introLabelText;
    
    self.cancelOrderButton.hidden = YES;
    self.payOrderButton.hidden = YES;
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
