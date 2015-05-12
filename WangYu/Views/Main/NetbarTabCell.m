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
    [self.netbarImage sd_setImageWithURL:@"xxx" placeholderImage:[UIImage imageNamed:@"netbar_default_img"]];
    self.netbarImage.layer.cornerRadius = 4.0;
    self.netbarImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
