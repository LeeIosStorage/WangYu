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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setActivityInfo:(WYActivityInfo *)activityInfo{
    _activityInfo = activityInfo;
    [self.activityImageView sd_setImageWithURL:activityInfo.smallImageURL placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    self.activityTitleLabel.text = activityInfo.title;
    self.activityIntroLabel.text = [NSString stringWithFormat:@"开赛时间：%@",activityInfo.startTime];
    
    CGRect frame = self.activityTitleLabel.frame;
    CGSize textSize = [WYCommonUtils sizeWithText:activityInfo.title font:self.activityTitleLabel.font width:SCREEN_WIDTH-117];
//    frame.size.width = textSize.width;
    frame.size.height = textSize.height;
    self.activityTitleLabel.frame = frame;
    
}

@end
