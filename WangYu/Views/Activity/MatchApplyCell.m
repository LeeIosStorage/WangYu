//
//  MatchApplyCell.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchApplyCell.h"

@implementation MatchApplyCell

- (void)awakeFromNib {
    // Initialization code
    
    self.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.titleLabel.font = SKIN_FONT_FROMNAME(14);
    
    self.textField.textColor = UIColorToRGB(0x666666);
    self.textField.font = SKIN_FONT_FROMNAME(14);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setbottomLineWithType:(int)type{
    //1 为全长，0为短线
    if (type == 1) {
        CGRect frame = CGRectMake(0, self.frame.size.height - 1, SCREEN_WIDTH, 1);
        _sepline.frame = frame;
    }else if (type == 0){
        CGRect frame = CGRectMake(12, self.frame.size.height - 1, SCREEN_WIDTH - 12, 1);
        _sepline.frame = frame;
    }
}

@end
