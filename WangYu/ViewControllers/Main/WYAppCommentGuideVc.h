//
//  WYAppCommentGuideVc.h
//  WangYu
//
//  Created by XuLei on 15/7/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol WYAppCommentGuideVcDelegate;

@interface WYAppCommentGuideVc : WYSuperViewController

@property (nonatomic, weak) id<WYAppCommentGuideVcDelegate> delegate;

@end

@protocol WYAppCommentGuideVcDelegate <NSObject>

- (void)cancelAppCommentGuideVc:(WYAppCommentGuideVc *)vc;

@end
