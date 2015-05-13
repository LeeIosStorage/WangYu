//
//  NetbarTabCell.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarTabCell.h"
#import "UIImageView+WebCache.h"

@interface NetbarTabCell()

@property (nonatomic, weak) UIFont *font1;
@property (nonatomic, weak) UIFont *font2;

@end

@implementation NetbarTabCell

- (void)awakeFromNib {
    // Initialization code
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.font1 = SKIN_FONT(15);
        self.font2 = SKIN_FONT(12);
        dispatch_async(dispatch_get_main_queue(),^{
            self.netbarTitle.font = self.font1;
            self.netbarAddress.font = self.font2;
            self.netbarPrice.font = self.font2;
            self.netbarDistance.font = self.font2;
        });
    });
    self.netbarImage.layer.cornerRadius = 4.0;
    self.netbarImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNetbarInfo:(WYNetbarInfo *)netbarInfo{
    _netbarInfo = netbarInfo;
    if (![netbarInfo.smallImageUrl isEqual:[NSNull null]]) {
        [_netbarImage sd_setImageWithURL:netbarInfo.smallImageUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }else{
        [_netbarImage sd_setImageWithURL:nil];
        [_netbarImage setImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }
    
    _netbarTitle.text = netbarInfo.netbarName;
    _netbarPrice.text = netbarInfo.price;
    _netbarDistance.text = netbarInfo.distance;
    _netbarAddress.text = netbarInfo.address;
    
//    _priceLabel.text = [NSString stringWithFormat:@"￥%@",cardInfo.price];
//    _cardTitleLabel.text = cardInfo.title;
//    if (cardInfo.status == 1) {
//        [_statusBtn setTitle:@"免费领取" forState:UIControlStateNormal];
//        _statusBtn.enabled = YES;
//        [_statusBtn setBackgroundImage:[UIImage imageNamed:@"card_status_bg"] forState:UIControlStateNormal];
//    }else if (cardInfo.status == 2) {
//        [_statusBtn setTitle:@"领用完" forState:UIControlStateNormal];
//        _statusBtn.enabled = NO;
//        [_statusBtn setBackgroundImage:[UIImage imageNamed:@"card_staus_hover_bg"] forState:UIControlStateNormal];
//    }else if (cardInfo.status == 3) {
//        [_statusBtn setTitle:@"已过期" forState:UIControlStateNormal];
//        _statusBtn.enabled = NO;
//        [_statusBtn setBackgroundImage:[UIImage imageNamed:@"card_staus_hover_bg"] forState:UIControlStateNormal];
//    }else if (cardInfo.status == 4) {
//        [_statusBtn setTitle:@"已领取" forState:UIControlStateNormal];
//        _statusBtn.enabled = NO;
//        [_statusBtn setBackgroundImage:[UIImage imageNamed:@"card_staus_hover_bg"] forState:UIControlStateNormal];
//    }
//    _cardDes.text = cardInfo.des;
}

@end
