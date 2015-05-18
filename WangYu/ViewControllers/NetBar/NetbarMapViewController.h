//
//  NetbarMapViewController.h
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface NetbarMapViewController : WYSuperViewController

@property (nonatomic, assign) CLLocationCoordinate2D location;//附近网吧

@property (strong, nonatomic) NSString* netbarName;//网吧名称
@property (strong, nonatomic) NSString* showPlaceTitle;//地址信息
-(void)setShowLocation:(double)lat longitute:(double)log;//显示具体某个位置

@end
