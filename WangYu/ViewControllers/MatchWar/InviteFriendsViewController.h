//
//  InviteFriendsViewController.h
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

typedef void(^SendInviteFriendsCallBack)(NSArray *array);

@interface InviteFriendsViewController : WYSuperViewController

@property (nonatomic, strong) SendInviteFriendsCallBack sendInviteFriendsCallBack;
@property (nonatomic, strong) NSMutableArray *slePbUserInfos;

@end
