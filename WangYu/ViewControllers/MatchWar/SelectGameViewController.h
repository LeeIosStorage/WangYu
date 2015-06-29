//
//  SelectGameViewController.h
//  WangYu
//
//  Created by Leejun on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol SelectGameViewControllerDelegate;

@interface SelectGameViewController : WYSuperViewController

@property(nonatomic, assign)id<SelectGameViewControllerDelegate> delegate;

@end

@protocol SelectGameViewControllerDelegate <NSObject>
- (void)selectGameViewControllerWithGameDic:(NSDictionary*)gameDic;

@end