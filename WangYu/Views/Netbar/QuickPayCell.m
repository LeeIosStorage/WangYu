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

}

- (void) setbottomLineWithType:(int)type{
    //1 为全长，0为短线
    if (type == 1) {
        CGRect frame = CGRectMake(0, self.frame.size.height - 1, SCREEN_WIDTH, 1);
        _sepline.frame = frame;
    }else if (type == 0){
        CGRect frame = CGRectMake(12, self.frame.size.height - 1, SCREEN_WIDTH - 24, 1);
        _sepline.frame = frame;
    }
}

@end
