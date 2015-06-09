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

- (void) setLineImageViewWithType:(int)type{
    CGRect frame = self.topLineImage.frame;
    frame.size.width = SCREEN_WIDTH;
    self.topLineImage.frame = frame;
    if (type == -1) {
        self.topLineImage.hidden = NO;
        self.bottomLineImage.hidden = NO;
    }else if (type == 0){
        //第一行
        self.topLineImage.hidden = NO;
        self.bottomLineImage.hidden = YES;
    }else if (type == 1){
        //中间线
        self.topLineImage.hidden = NO;
        self.bottomLineImage.hidden = YES;
        frame = self.topLineImage.frame;
        frame.origin.x = 12;
        frame.size.width = SCREEN_WIDTH-12;
        self.topLineImage.frame = frame;
    }else if (type == 2){
        //最后一行
        self.topLineImage.hidden = NO;
        self.bottomLineImage.hidden = NO;
        frame = self.topLineImage.frame;
        frame.origin.x = 12;
        frame.size.width = SCREEN_WIDTH-12;
        self.topLineImage.frame = frame;
    }
}

@end
