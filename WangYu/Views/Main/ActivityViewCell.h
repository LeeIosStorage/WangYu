//
//  LeagueViewCell.h
//  WangYu
//
//  Created by KID on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYActivityInfo.h"

@interface ActivityViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *activityImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stateImage;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;

@property (strong, nonatomic) WYActivityInfo *activityInfo;

@end
