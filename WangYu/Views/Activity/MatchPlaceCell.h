//
//  MatchPlaceCell.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYMatchInfo.h"

@protocol MatchPlaceCellDelegate;
@interface MatchPlaceCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIButton *applyButton;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *placeLabel;
@property (strong, nonatomic) IBOutlet UILabel *roundLabel;

@property (strong, nonatomic) WYMatchInfo *matchInfo;

@property (nonatomic, weak) id<MatchPlaceCellDelegate> delegate;

@end

@protocol MatchPlaceCellDelegate <NSObject>

@optional
- (void)matchPlaceCellClickWithCell:(id)cell;

@end
