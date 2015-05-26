//
//  WYActivityInfo.h
//  WangYu
//
//  Created by KID on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYActivityInfo : NSObject

@property (nonatomic, strong) NSString *aId;                //活动id
@property (nonatomic, strong) NSString *activityImageUrl;   //赛事图片url
@property (nonatomic, strong) NSString *title;              //赛事标题
@property (nonatomic, strong) NSString *startTime;          //活动开始时间
@property (nonatomic, strong) NSString *endTime;            //活动结束时间
@property (nonatomic, strong) NSString *itemPicUrl;         //赛事项目图片
@property (nonatomic, strong) NSString *itemName;           //赛事项目名称
@property (nonatomic, assign) int status;                   //赛事状态
@property(nonatomic, readonly) NSURL* smallImageURL;        //图片网络地址
@property(nonatomic, readonly) NSURL* itemPicURL;           //图片网络地址

@property(nonatomic, strong) NSDictionary* activityInfoByJsonDic;     //活动字典

@end
