//
//  RedPacketViewCell.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedPacketInfo.h"

@interface RedPacketViewCell : UITableViewCell

@property (strong, nonatomic) RedPacketInfo *redPacketInfo;
@property (assign, nonatomic) BOOL isPast;//已过期

@property (strong, nonatomic) IBOutlet UIImageView *redPacketBgImgView;
@property (strong, nonatomic) IBOutlet UILabel *redPagMoney;
@property (strong, nonatomic) IBOutlet UILabel *redPagIntroLabel;
@property (strong, nonatomic) IBOutlet UILabel *redPagValidTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *redPagStaleLabel;

@end
