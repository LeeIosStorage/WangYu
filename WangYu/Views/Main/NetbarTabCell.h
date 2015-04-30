//
//  NetbarTabCell.h
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetbarTabCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (strong, nonatomic) IBOutlet UILabel *netbarTitle;
@property (strong, nonatomic) IBOutlet UILabel *netbarAddress;
@property (strong, nonatomic) IBOutlet UILabel *netbarPrice;
@property (strong, nonatomic) IBOutlet UILabel *netbarDistance;

@end
