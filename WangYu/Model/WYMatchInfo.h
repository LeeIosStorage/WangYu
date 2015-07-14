//
//  WYMatchInfo.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYMatchInfo : NSObject

//@property (nonatomic, strong) NSString *mid;              //比赛id
@property (nonatomic, strong) NSString *startTime;          //比赛开始时间
@property (nonatomic, strong) NSString *endTime;            //比赛结束时间
@property (nonatomic, assign) int round;                    //比赛轮次
@property (nonatomic, strong) NSString *areas;              //比赛地点
@property (nonatomic, strong) NSMutableArray* netbars;      //比赛网吧
@property (nonatomic, assign) int isApply;                  //当前时间是否在报名中(0:未开始1:进行中2:已截止)
@property (nonatomic, assign) int hasApply;                 //报名该场次比赛状态

@property(nonatomic, strong) NSDictionary* matchInfoByJsonDic;     //比赛字典

@end
