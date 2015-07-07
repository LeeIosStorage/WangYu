//
//  WYTeamInfo.h
//  WangYu
//
//  Created by XuLei on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYTeamInfo : NSObject

@property (nonatomic, strong) NSString *teamId;             
@property (nonatomic, strong) NSString *teamName;              //队名
@property (nonatomic, assign) int applyNum;                    //报名人数
@property (nonatomic, assign) int totalNum;                    //约战最大人数
@property (nonatomic, strong) NSString *teamLeader;            //队长
@property (nonatomic, assign) BOOL isJoin;                     //是否参加
@property (nonatomic, assign) BOOL isLeader;
@property (nonatomic, strong) NSString *activityId;            //当前队伍所在赛事
@property (nonatomic, assign) int round;                       //当前队伍所在赛事场次
@property (nonatomic, strong) NSString *title;                 //所在赛事title


@property (nonatomic, strong) NSDictionary* teamInfoByJsonDic; //资讯字典

@end
