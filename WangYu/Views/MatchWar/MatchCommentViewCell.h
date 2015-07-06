//
//  MatchCommentViewCell.h
//  WangYu
//
//  Created by Leejun on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYMatchCommentInfo.h"

@interface MatchCommentViewCell : UITableViewCell

@property (nonatomic, strong) WYMatchCommentInfo *commentInfo;

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *contentLabel;

+ (float)heightForCommentInfo:(WYMatchCommentInfo *)commentInfo;

@end
