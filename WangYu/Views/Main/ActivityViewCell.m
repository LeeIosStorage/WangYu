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
        [_activityImage sd_setImageWithURL:activityInfo.smallImageURL placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }else{
        [_activityImage sd_setImageWithURL:nil];
        [_activityImage setImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }
    
    _nameLabel.text = _activityInfo.title;
    _timeLabel.text = _activityInfo.startTime;
}


@end
