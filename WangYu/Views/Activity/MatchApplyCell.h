//
//  MatchApplyCell.h
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchApplyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *rightImageView;
@property (nonatomic, weak) IBOutlet UIImageView *topline;
@property (nonatomic, weak) IBOutlet UIImageView *sepline;

- (void) setbottomLineWithType:(int)type;

@end
