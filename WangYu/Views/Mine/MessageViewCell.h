//
//  MessageViewCell.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYMessageInfo.h"

@interface MessageViewCell : UITableViewCell

@property (strong, nonatomic) WYMessageInfo *messageInfo;

@property (strong, nonatomic) IBOutlet UIImageView *messageAvatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *badgeImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@end
