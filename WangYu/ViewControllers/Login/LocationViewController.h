//
//  LocationViewController.h
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol LocationViewControllerDelegate;

@interface LocationViewController : WYSuperViewController

@property (nonatomic, assign) BOOL isShowNoticeView;

@property (nonatomic, assign) id<LocationViewControllerDelegate> delagte;

@end

@protocol LocationViewControllerDelegate <NSObject>
@optional
- (void)locationViewControllerWith:(LocationViewController*)vc selectCity:(NSDictionary *)cityDic;//areaCode,name
@end