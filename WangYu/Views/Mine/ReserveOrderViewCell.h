//
//  ReserveOrderViewCell.h
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReserveOrderViewCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *orderInfo;

@property (strong, nonatomic) IBOutlet UILabel *netbarNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *openImageViewIcon;
@property (strong, nonatomic) IBOutlet UILabel *openTimeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *seatImageViewIcon;
@property (strong, nonatomic) IBOutlet UILabel *seatLabel;
@property (strong, nonatomic) IBOutlet UILabel *introLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *payOrderButton;
@end
