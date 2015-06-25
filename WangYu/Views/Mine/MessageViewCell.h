//
//  MessageViewCell.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYMessageInfo.h"

typedef enum MessageType_{
    SYS_NOTIFY,            //系统: 系统消息 0
    SYS_REDBAG,            //系统: 红包消息 1
    SYS_MEMBER,            //系统: 会员消息 2
    ORDER_RESERVE,         //订单类: 预定消息 3
    ORDER_PAY,             //订单类: 支付消息 4
    ACTIVITY_MATCH,        //活动类: 赛事消息 5
    ACTIVITY_FIGHT         //活动类: 约战消息 6
}MessageType;

@interface MessageViewCell : UITableViewCell

@property (strong, nonatomic) WYMessageInfo *messageInfo;

@property (strong, nonatomic) IBOutlet UIImageView *messageAvatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@end
