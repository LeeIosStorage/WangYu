//
//  InviteMemberViewController.h
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol InviteMemberViewDelegate;

@interface InviteMemberViewController : WYSuperViewController

@property (nonatomic, strong) NSString *teamId;
@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, assign) id<InviteMemberViewDelegate> delegate;

@end

@protocol InviteMemberViewDelegate <NSObject>

@optional
- (void)refreshMatchMember;

@end
