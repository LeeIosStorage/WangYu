//
//  quickBookCell.m
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "QuickBookCell.h"

@implementation QuickBookCell

- (void)awakeFromNib {
    // Initialization code
    
    self.titleName.font = SKIN_FONT(14);
    self.titleName.textColor = SKIN_TEXT_COLOR1;
    
    self.rightLabel.font = SKIN_FONT(12);
    self.rightLabel.textColor = SKIN_TEXT_COLOR3;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
