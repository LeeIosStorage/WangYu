//
//  NetbarTabCell.h
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYNetbarInfo.h"

@protocol NetbarTabCellDelegate;
@interface NetbarTabCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (strong, nonatomic) IBOutlet UILabel *netbarTitle;
@property (strong, nonatomic) IBOutlet UILabel *netbarAddress;
@property (strong, nonatomic) IBOutlet UILabel *netbarPrice;
@property (strong, nonatomic) IBOutlet UILabel *netbarTime;
@property (strong, nonatomic) IBOutlet UIImageView *recommendImage;
@property (strong, nonatomic) IBOutlet UIImageView *payImage;
@property (strong, nonatomic) IBOutlet UIImageView *bookImage;
@property (strong, nonatomic) IBOutlet UIImageView *mapImage;

@property (strong, nonatomic) IBOutlet UILabel *netbarDistance;

@property(nonatomic, assign) id<NetbarTabCellDelegate> delegate;

@property (assign, nonatomic) BOOL isSearchCell;
@property (strong, nonatomic) WYNetbarInfo *netbarInfo;
- (IBAction)mapAction:(id)sender;

@end

@protocol NetbarTabCellDelegate <NSObject>
@optional
- (void)netbarTabCellMapClickWithCell:(id)cell;

@end

