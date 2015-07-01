//
//  MatchApplyViewController.h
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYMatchInfo.h"

@interface MatchApplyViewController : WYSuperViewController

@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, strong) WYMatchInfo *matchInfo;

@end
