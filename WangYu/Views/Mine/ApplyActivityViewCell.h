//
//  ApplyActivityViewCell.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYActivityInfo.h"
#import "TTTAttributedLabel.h"

@interface ApplyActivityViewCell : UITableViewCell

@property (strong, nonatomic) WYActivityInfo *activityInfo;

@property (strong, nonatomic) IBOutlet UIImageView *activityImageView;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *activityTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *activityIntroLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

@end
