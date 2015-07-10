//
//  MatchPlaceViewController.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol MatchPlaceViewDelegate;

@interface MatchPlaceViewController : WYSuperViewController

@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, assign) id<MatchPlaceViewDelegate> delegate;

@end

@protocol MatchPlaceViewDelegate <NSObject>

@optional
- (void)refreshMatchDetailInfo;

@end
