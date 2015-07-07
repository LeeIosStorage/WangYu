//
//  GameListViewCell.h
//  WangYu
//
//  Created by Leejun on 15/7/7.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYGameInfo.h"

@interface GameListViewCell : UITableViewCell

@property (nonatomic, strong) WYGameInfo *gameInfo;

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *introLabel;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;

@end
