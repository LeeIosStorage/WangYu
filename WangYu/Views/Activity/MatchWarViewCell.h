//
//  MatchWarViewCell.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYMatchWarInfo.h"

@interface MatchWarViewCell : UITableViewCell

@property (strong, nonatomic) WYMatchWarInfo *matchWarInfo;

@property (strong, nonatomic) IBOutlet UILabel *matchWarTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchWarTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchWarWayLabel;
@property (strong, nonatomic) IBOutlet UILabel *matchWarSpoilsLabel;
@property (strong, nonatomic) IBOutlet UIImageView *gameImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *matchWarHotIocnImgView;
@property (strong, nonatomic) IBOutlet UILabel *applyCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalCountLabel;

@end
