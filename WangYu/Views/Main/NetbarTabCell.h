//
//  NetbarTabCell.h
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYNetbarInfo.h"

@interface NetbarTabCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (strong, nonatomic) IBOutlet UILabel *netbarTitle;
@property (strong, nonatomic) IBOutlet UILabel *netbarAddress;
@property (strong, nonatomic) IBOutlet UILabel *netbarPrice;
@property (strong, nonatomic) IBOutlet UILabel *netbarTime;
@property (strong, nonatomic) IBOutlet UIImageView *recommendImage;
@property (strong, nonatomic) IBOutlet UIImageView *payImage;
@property (strong, nonatomic) IBOutlet UIImageView *bookImage;

@property (strong, nonatomic) IBOutlet UILabel *netbarDistance;

@property (strong, nonatomic) WYNetbarInfo *netbarInfo;

@end
