//
//  LeagueViewCell.m
//  WangYu
//
//  Created by KID on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ActivityViewCell.h"
#import "UIImageView+WebCache.h"

@implementation ActivityViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setActivityInfo:(WYActivityInfo *)activityInfo{
    _activityInfo = activityInfo;
    if (![activityInfo.activityImageUrl isEqual:[NSNull null]]) {
        [_activityImage sd_setImageWithURL:activityInfo.smallImageURL placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
    }else{
        [_activityImage sd_setImageWithURL:nil];
        [_activityImage setImage:[UIImage imageNamed:@"activity_load_icon"]];
    }
    _activityImage.layer.cornerRadius = 4.0;
    _activityImage.layer.masksToBounds = YES;
    
    _nameLabel.text = _activityInfo.title;
    NSString *timeStr = activityInfo.startTime;
    if (timeStr.length > 10) {
        timeStr = [timeStr substringToIndex:10];
    }else {
        timeStr = @"暂无时间";
    }
    _timeLabel.text = [NSString stringWithFormat:@"开赛时间：%@",timeStr];
    if (_activityInfo.status == 1) {
        _stateLabel.text = @"报名进行中";
        [_stateImage setImage:[UIImage imageNamed:@"activity_league_start_icon"]];
    }else if (_activityInfo.status == 2) {
        _stateLabel.text = @"报名未开始";
        [_stateImage setImage:[UIImage imageNamed:@"activity_league_start_icon"]];
    }else if (_activityInfo.status == 3) {
        _stateLabel.text = @"报名已截止";
        [_stateImage setImage:[UIImage imageNamed:@"activity_league_end_icon"]];
    }else if (_activityInfo.status == 4) {
        _stateLabel.text = @"赛事已结束";
        [_stateImage setImage:[UIImage imageNamed:@"activity_league_end_icon"]];
    }
}

@end
