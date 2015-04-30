//
//  NetbarTabCell.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarTabCell.h"
#import "UIImageView+WebCache.h"

@implementation NetbarTabCell

- (void)awakeFromNib {
    // Initialization code
    self.netbarTitle.font = SKIN_FONT(15);
    self.netbarAddress.font = SKIN_FONT(12);
    self.netbarPrice.font = SKIN_FONT(12);
    self.netbarDistance.font = SKIN_FONT(12);
    [self.netbarImage sd_setImageWithURL:@"xxx" placeholderImage:[UIImage imageNamed:@"netbar_default_img"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
