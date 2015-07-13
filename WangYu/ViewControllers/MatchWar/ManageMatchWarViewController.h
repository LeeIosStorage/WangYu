//
//  ManageMatchWarViewController.h
//  WangYu
//
//  Created by Leejun on 15/7/3.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYMatchWarInfo.h"

@interface ManageMatchWarViewController : WYSuperViewController

@property (nonatomic, strong) WYMatchWarInfo *matchWarInfo;
@property (nonatomic, strong) NSMutableArray *applys;

@end
