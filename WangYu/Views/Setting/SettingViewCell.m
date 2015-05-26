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

@end
