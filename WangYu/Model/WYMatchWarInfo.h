//
//  WYMatchWarInfo.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYUserInfo.h"

//约战Model
@interface WYMatchWarInfo : NSObject

@property (nonatomic, strong) NSString *mId;                //约战id
@property (nonatomic, strong) NSString *title;              //约战标题
@property (nonatomic, strong) NSDate *startTime;            //开始时间
@property (nonatomic, strong) NSString *spoils;             //介绍
@property (nonatomic, strong) NSString *rule;               //胜负规则
@property (nonatomic, strong) NSString *remark;             //联系方式
@property (nonatomic, assign) int way;                      //方式：1-线上;2-线下;
@property (nonatomic, assign) int applyCount;               //报名人数
@property (nonatomic, assign) int peopleNum;                //约战最大人数
@property (nonatomic, assign) int commentsCount;            //评论数
@property (nonatomic, assign) int isStart;                  //约战是否开始 1已开始 0未开始
@property (nonatomic, assign) int userStatus;               //-1 未登录状态 1发起者 2已报名 3未报名
@property (nonatomic, strong) NSString *itemServer;         //项目服务器
@property (nonatomic, strong) NSString *itemName;           //约战项目名称
@property (nonatomic, strong) NSString *itemPicUrl;         //约战项目图片
@property (nonatomic, readonly) NSURL* itemPicURL;          //约战项目图片地址
@property (nonatomic, strong) NSString* bgAvatar;           //背景图
@property (nonatomic, readonly) NSURL* bgAvatarUrl;         //背景图地址

@property (nonatomic, strong) WYUserInfo *userInfo;

@property (nonatomic, strong) NSString *netbarId;
@property (nonatomic, strong) NSString *netbarName;

@property (nonatomic, strong) NSMutableArray* applys;      //加入人
@property (nonatomic, readonly) NSMutableArray* comments;    //评论

@property(nonatomic, strong) NSDictionary* matchWarInfoByJsonDic;

@end
