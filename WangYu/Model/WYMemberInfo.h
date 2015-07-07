//
//  WYMemberInfo.h
//  WangYu
//
//  Created by XuLei on 15/7/7.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYMemberInfo : NSObject

@property (nonatomic, strong) NSString *memberId;                  //战队成员id
@property (nonatomic, strong) NSString *telephone;                 //电话
@property (nonatomic, assign) BOOL isCompleted;                    //是否完善资料
@property (nonatomic, strong) NSString *nickName;                  //昵称
@property (nonatomic, strong) NSString *icon;                      //头像
@property (nonatomic, readonly) NSURL* smallAvatarUrl;             //头像地址

@property (nonatomic, strong) NSDictionary* memberInfoByJsonDic;   //资讯字典

@end
