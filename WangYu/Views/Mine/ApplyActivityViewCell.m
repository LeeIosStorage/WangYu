//
//  ApplyActivityViewCell.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ApplyActivityViewCell.h"
#import "UIImageView+WebCache.h"
#import "WYCommonUtils.h"

@implementation ApplyActivityViewCell

- (void)awakeFromNib {
    // Initialization code
    self.activityImageView.layer.masksToBounds = YES;
    self.activityImageView.layer.cornerRadius = 4;
    self.activityImageView.clipsToBounds = YES;
    self.activityImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.activityTitleLabel.textColor = SKIN_TEXT_COLOR1;
    self.activityTitleLabel.font = SKIN_FONT_FROMNAME(15);
    self.activityIntroLabel.textColor = SKIN_TEXT_COLOR2;
    self.activityIntroLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.statusLabel.font = SKIN_FONT_FROMNAME(11);
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.layer.masksToBounds = YES;
    self.statusLabel.layer.cornerRadius = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setActivityInfo:(WYActivityInfo *)activityInfo{
    _activityInfo = activityInfo;
    [self.activityImageView sd_setImageWithURL:activityInfo.smallImageURL placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    self.activityTitleLabel.lineHeightMultiple = 0.7;
    self.activityTitleLabel.text = activityInfo.title;
    
    NSArray *timeArray = [activityInfo.startTime componentsSeparatedByString:@" "];
    if (timeArray.count > 0) {
        self.activityIntroLabel.text = [NSString stringWithFormat:@"开赛时间：%@",[timeArray objectAtIndex:0]];
    }
    
    CGRect frame = self.activityTitleLabel.frame;
    CGSize textSize = [WYCommonUtils sizeWithText:activityInfo.title font:self.activityTitleLabel.font width:SCREEN_WIDTH-111];
    frame.origin.y = 8;
    frame.size.height = textSize.height + 10;
    self.activityTitleLabel.frame = frame;
    
    int status = _activityInfo.status;
    self.statusLabel.hidden = NO;
    self.statusLabel.backgroundColor = UIColorToRGB(0xadadad);
    if (status == 1) {
        _statusLabel.text = @"进行中";
        self.statusLabel.backgroundColor = UIColorToRGB(0xf03f3f);
    }else if (status == 2) {
        _statusLabel.text = @"未开始";
    }else if (status == 3) {
        _statusLabel.text = @"已截止";
    }else if (status == 4) {
        _statusLabel.text = @"已结束";
    }else{
        self.statusLabel.hidden = YES;
    }
    
}

@end
