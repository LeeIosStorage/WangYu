//
//  PublishMatchWarViewController.h
//  WangYu
//
//  Created by Leejun on 15/6/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYMatchWarInfo.h"

@protocol PublishMatchWarViewControllerDelegate;

@interface PublishMatchWarViewController : WYSuperViewController

@property (nonatomic, assign) id<PublishMatchWarViewControllerDelegate>delegate;
@end

@protocol PublishMatchWarViewControllerDelegate <NSObject>
@optional
- (void)publishMatchWarViewControllerWith:(PublishMatchWarViewController*)viewController withMatchWarInfo:(WYMatchWarInfo*)matchWarInfo;
@end
