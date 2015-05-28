//
//  ApplyActivityViewCell.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYActivityInfo.h"

@interface ApplyActivityViewCell : UITableViewCell

@property (strong, nonatomic) WYActivityInfo *activityInfo;

@property (strong, nonatomic) IBOutlet UIImageView *activityImageView;
@property (strong, nonatomic) IBOutlet UILabel *activityTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *activityIntroLabel;

@end
