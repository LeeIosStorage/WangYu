//
//  NetbarTabCell.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarTabCell.h"
#import "UIImageView+WebCache.h"
#import "WYCommonUtils.h"

@interface NetbarTabCell()

@property (nonatomic, weak) UIFont *font1;
@property (nonatomic, weak) UIFont *font2;

@end

@implementation NetbarTabCell

- (void)awakeFromNib {
    // Initialization code
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.font1 = SKIN_FONT_FROMNAME(15);
        self.font2 = SKIN_FONT_FROMNAME(12);
        dispatch_async(dispatch_get_main_queue(),^{
            self.netbarTitle.font = self.font1;
            self.netbarAddress.font = self.font2;
            self.netbarDistance.font = self.font2;
            self.netbarTime.font = self.font2;
        });
    });
    self.netbarTitle.textColor = SKIN_TEXT_COLOR1;
    self.netbarAddress.textColor = SKIN_TEXT_COLOR2;
    self.netbarTime.textColor = SKIN_TEXT_COLOR2;
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
    _netbarPrice.text = [NSString stringWithFormat:@"%@",netbarInfo.price];
    
    CGFloat priceLabelWidth = [WYCommonUtils widthWithText:_netbarPrice.text font:_netbarPrice.font lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = _netbarPrice.frame;
    frame.size.width = priceLabelWidth;
    _netbarPrice.frame = frame;
    
    frame = _netbarTime.frame;
    frame.origin.x = _netbarPrice.frame.size.width + _netbarPrice.frame.origin.x;
    _netbarTime.frame = frame;
    _netbarTime.text = [NSString stringWithFormat:@"/小时"];
    
    if (netbarInfo.distance.length > 0) {
        _mapImage.hidden = NO;
        _netbarDistance.hidden = NO;
        _mapButton.hidden = NO;
        
        _netbarDistance.text = [NSString stringWithFormat:@"%@m",netbarInfo.distance];
        NSArray *array = [netbarInfo.distance componentsSeparatedByString:@"."];
        if ([array[0] intValue] == 0) {
            _netbarDistance.text = [NSString stringWithFormat:@"%dm" ,[[array[1] substringToIndex:3] intValue]];
        }else {
            NSString *strTemp = array[0];
            if (strTemp.length == 1) {
                _netbarDistance.text = [NSString stringWithFormat:@"%@.%@km" ,array[0],[array[1] substringToIndex:2]];
            }else if (strTemp.length == 2) {
                _netbarDistance.text = [NSString stringWithFormat:@"%@.%@km" ,array[0],[array[1] substringToIndex:1]];
            }else {
                _netbarDistance.text = [NSString stringWithFormat:@"%@km" ,array[0]];
            }
        }
    }else {
        _netbarDistance.text = @"未知位置";
        _mapImage.hidden = YES;
        _netbarDistance.hidden = YES;
        _mapButton.hidden = YES;
    }
    
    CGFloat distanceWidth = .0;
    distanceWidth = [WYCommonUtils widthWithText:_netbarDistance.text font:_netbarDistance.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = _netbarDistance.frame;
    frame.size.width = distanceWidth;
    frame.origin.x = SCREEN_WIDTH - 12 - distanceWidth;
    _netbarDistance.frame = frame;
    
    frame = _mapImage.frame;
    frame.origin.x = SCREEN_WIDTH - 12 - distanceWidth - 7 - _mapImage.frame.size.width;
    _mapImage.frame = frame;
    
    frame = _bookImage.frame;
    if (netbarInfo.isOrder) {
        _bookImage.hidden = NO;
    }else {
        _bookImage.hidden = YES;
    }
    
    CGFloat interval = 0.;
    
    if (netbarInfo.isPay) {
        _payImage.hidden = NO;
        frame = _payImage.frame;
        interval = netbarInfo.isOrder?(CGRectGetWidth(_bookImage.frame) + CGRectGetWidth(_payImage.frame) + 7):CGRectGetWidth(_bookImage.frame);
        frame.origin.x = SCREEN_WIDTH - 12 - interval;
        _payImage.frame = frame;
    }else {
        _payImage.hidden = YES;
    }
    if (netbarInfo.isRecommend) {
        _recommendImage.hidden = NO;
        frame = _recommendImage.frame;
        interval = (netbarInfo.isOrder?(CGRectGetWidth(_bookImage.frame) + CGRectGetWidth(_recommendImage.frame) + 7):CGRectGetWidth(_recommendImage.frame)) + (netbarInfo.isPay?(CGRectGetWidth(_payImage.frame) + 7):0);
        frame.origin.x = SCREEN_WIDTH - 12 - interval;
        _recommendImage.frame = frame;
    }else {
        _recommendImage.hidden = YES;
    }
    
    _netbarAddress.lineHeightMultiple = 0.8;
    _netbarAddress.text = netbarInfo.address;
}

- (IBAction)mapAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(netbarTabCellMapClickWithCell:)]) {
        [self.delegate netbarTabCellMapClickWithCell:self];
    }
}

@end
