//
//  QuickPayCell.m
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "QuickPayCell.h"

@implementation QuickPayCell

- (void)awakeFromNib {
    // Initialization code
    
    self.payLabel.font = SKIN_FONT(12);
    self.payLabel.textColor = SKIN_TEXT_COLOR1;
    
    self.payImage.layer.cornerRadius = 2.0;
    self.payImage.layer.masksToBounds = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
