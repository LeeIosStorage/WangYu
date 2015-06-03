//
//  RedPacketViewController.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "RedPacketInfo.h"

typedef void(^SendRedPacketCallBack)(NSArray *array);

@interface RedPacketViewController : WYSuperViewController

@property (nonatomic, strong) SendRedPacketCallBack sendRedPacketCallBack;

@property (nonatomic, assign) BOOL bChooseRed;

@property (nonatomic, strong) NSMutableArray *packetInfos;

@end
