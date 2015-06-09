//
//  SettingViewCell.m
//  Xiaoer
//
//  Created by KID on 15/2/5.
//
//

#import "SettingViewCell.h"

@implementation SettingViewCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.rightLabel.font = SKIN_FONT_FROMNAME(12);
    self.rightLabel.textColor = SKIN_TEXT_COLOR2;
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
