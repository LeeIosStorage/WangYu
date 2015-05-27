//
//  MatchPlaceCell.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchPlaceCell.h"

@implementation MatchPlaceCell

- (void)awakeFromNib {
    // Initialization code
    [self.containerView.layer setMasksToBounds:YES];
    [self.containerView.layer setCornerRadius:4.0];
    [self.containerView.layer setBorderWidth:0.5]; //边框宽度
    [self.containerView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
