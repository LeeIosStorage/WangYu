//
//  MatchTeamsCell.h
//  WangYu
//
//  Created by XuLei on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYTeamInfo.h"

@protocol MatchTeamsCellDelegate;

@interface MatchTeamsCell : UITableViewCell

@property (assign, nonatomic) id<MatchTeamsCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *teamNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *teamLeaderLabel;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UILabel *applyCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalCountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *hotImageView;

@property (strong, nonatomic) WYTeamInfo *teamInfo;

@end

@protocol MatchTeamsCellDelegate <NSObject>

@optional
- (void)MatchTeamsCellJoinClickWithCell:(id)cell;

@end
