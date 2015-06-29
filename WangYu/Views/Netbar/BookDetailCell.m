//
//  BookDetailCell.m
//  WangYu
//
//  Created by XuLei on 15/6/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "BookDetailCell.h"

@implementation BookDetailCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.font = SKIN_FONT_FROMNAME(12);
    self.titleLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.contentLabel.font = SKIN_FONT_FROMNAME(12);
    self.contentLabel.textColor = SKIN_TEXT_COLOR4;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
