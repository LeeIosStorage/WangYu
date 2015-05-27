//
//  MatchDetailCell.h
//  WangYu
//
//  Created by 许 磊 on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchDetailCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *indicatorImage;
@property (nonatomic, strong) IBOutlet UIImageView *sepline;
@property (nonatomic, strong) IBOutlet UIImageView *topline;

- (void) setbottomLineWithType:(int)type;

@end
