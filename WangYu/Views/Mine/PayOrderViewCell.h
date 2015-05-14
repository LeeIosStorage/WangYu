//
//  PayOrderViewCell.h
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYOrderInfo.h"

@protocol PayOrderViewCellDelegate;

@interface PayOrderViewCell : UITableViewCell

@property(nonatomic, assign) id<PayOrderViewCellDelegate> delegate;

@property (strong, nonatomic) WYOrderInfo *orderInfo;

@property (strong, nonatomic) IBOutlet UILabel *netbarNameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *indicatorImageView;
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *privilegeYuanLabel;
@property (strong, nonatomic) IBOutlet UILabel *redPacketLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelOrderButton;
@property (strong, nonatomic) IBOutlet UIButton *payOrderButton;

- (IBAction)netbarAction:(id)sender;
- (IBAction)cancelOrderAction:(id)sender;
- (IBAction)payAction:(id)sender;

@end

@protocol PayOrderViewCellDelegate <NSObject>
@optional
- (void)payOrderViewCellNetbarClickWithCell:(id)cell;
- (void)payOrderViewCellCancelClickWithCell:(id)cell;
- (void)payOrderViewCellPayClickWithCell:(id)cell;

@end