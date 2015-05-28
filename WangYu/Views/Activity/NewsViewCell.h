//
//  NewsViewCell.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYNewsInfo.h"

@interface NewsViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *newsImageView;
@property (strong, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *newsBriefLabel;
@property (strong, nonatomic) IBOutlet UILabel *featureLabel;
@property (strong, nonatomic) WYNewsInfo *newsInfo;

@end
