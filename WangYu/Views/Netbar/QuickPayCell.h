//
//  QuickPayCell.h
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuickPayCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *payImage;
@property (strong, nonatomic) IBOutlet UILabel *payLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;

@property (nonatomic, strong) IBOutlet UIImageView *sepline;
@property (nonatomic, strong) IBOutlet UIImageView *topline;

@property (assign, nonatomic) BOOL isChecked;

- (void) setbottomLineWithType:(int)type;

@end
