//
//  GameCollectViewCell.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYGameInfo.h"
#import "TTTAttributedLabel.h"

@interface GameCollectViewCell : UITableViewCell

@property (strong, nonatomic) WYGameInfo *gameInfo;

@property (strong, nonatomic) IBOutlet UIImageView *gameImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameTitleLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *gameIntroLabel;

@end
