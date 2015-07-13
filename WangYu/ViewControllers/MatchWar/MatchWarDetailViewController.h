//
//  MatchWarDetailViewController.h
//  WangYu
//
//  Created by Leejun on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYMatchWarInfo.h"

@protocol MatchWarDetailViewControllerDelegate;

@interface MatchWarDetailViewController : WYSuperViewController

@property (nonatomic, assign) id<MatchWarDetailViewControllerDelegate>delegate;
@property (nonatomic, strong) WYMatchWarInfo *matchWarInfo;

@end

@protocol MatchWarDetailViewControllerDelegate <NSObject>
@optional
- (void)matchWarDetailViewControllerWith:(MatchWarDetailViewController*)viewController withMatchWarInfo:(WYMatchWarInfo*)matchWarInfo applyCountAdd:(BOOL)add;

@end
