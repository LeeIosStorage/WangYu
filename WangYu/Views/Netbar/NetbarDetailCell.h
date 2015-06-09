//
//  NetbarDetailCell.h
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYMatchWarInfo.h"

@interface NetbarDetailCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *applyCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *matchWarHotIocnImgView;

@property (strong, nonatomic) WYMatchWarInfo *matchWarInfo;

@end
