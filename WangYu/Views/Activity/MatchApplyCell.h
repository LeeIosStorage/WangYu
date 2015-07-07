//
//  MatchApplyCell.h
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchApplyCellDelegate <NSObject>

@required
-(void) textDidChanged:(id) cell cellContent:(NSString *)content;
-(void) textDidEditing:(id) cell;

@end

@interface MatchApplyCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIImageView *rightImageView;
@property (nonatomic, strong) IBOutlet UIImageView *topline;
@property (nonatomic, strong) IBOutlet UIImageView *sepline;
@property (nonatomic, weak) id<MatchApplyCellDelegate> delegate;
//是否获取着焦点
@property (nonatomic, assign) BOOL isFirstResponder;

- (void) setbottomLineWithType:(int)type;

@end
