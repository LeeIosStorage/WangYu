//
//  NetbarDetailCell.m
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarDetailCell.h"

@implementation NetbarDetailCell

- (void)awakeFromNib {
    // Initialization code
    
    self.teamLabel.font = SKIN_FONT(12);
    self.teamLabel.textColor = SKIN_TEXT_COLOR1;
    
    self.dateLabel.font = SKIN_FONT(12);
    self.dateLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.joinNumLabel.font = SKIN_FONT(12);
    self.joinNumLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.nameLabel.font = SKIN_FONT(12);
    self.nameLabel.textColor = SKIN_TEXT_COLOR1;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
