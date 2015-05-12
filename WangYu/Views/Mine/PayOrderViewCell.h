//
//  PayOrderViewCell.h
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayOrderViewCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *orderInfo;

@property (strong, nonatomic) IBOutlet UILabel *netbarNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *privilegeYuanLabel;
@property (strong, nonatomic) IBOutlet UILabel *redPacketLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *payOrderButton;

@end
