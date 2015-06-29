//
//  ContactWayViewController.h
//  WangYu
//
//  Created by Leejun on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

#define contact_YY @"YY"
#define contact_WX @"WX"
#define contact_QQ @"QQ"

@protocol ContactWayViewControllerDelegate;

@interface ContactWayViewController : WYSuperViewController

@property (nonatomic, assign) id <ContactWayViewControllerDelegate>delegate;
@property (nonatomic, strong) NSDictionary *contactDic;

@end

@protocol ContactWayViewControllerDelegate <NSObject>
@optional
-(void)contactWayViewControllerWithContactDic:(NSDictionary *)contactDic;
@end