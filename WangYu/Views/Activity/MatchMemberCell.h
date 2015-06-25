//
//  MatchMemberCell.h
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYUserInfo.h"

@interface MatchMemberCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *phoneLable;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) WYUserInfo *userInfo;

@end
