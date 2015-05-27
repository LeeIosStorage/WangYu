//
//  MatchDetailCell.m
//  WangYu
//
//  Created by 许 磊 on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchDetailCell.h"

@implementation MatchDetailCell

- (void)awakeFromNib {
    // Initialization code
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
        CGRect frame = CGRectMake(12, self.frame.size.height - 1, SCREEN_WIDTH - 24, 1);
        _sepline.frame = frame;
    }
}

@end
