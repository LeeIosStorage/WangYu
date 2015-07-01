//
//  WYMatchWarInfo.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

//约战Model
@interface WYMatchWarInfo : NSObject

@property (nonatomic, strong) NSString *mId;                //约战id
@property (nonatomic, strong) NSString *title;              //约战标题
@property (nonatomic, strong) NSDate *startTime;            //开始时间
@property (nonatomic, strong) NSString *releaser;           //约战发布人
@property (nonatomic, strong) NSString *spoils;             //战利品
@property (nonatomic, assign) int way;                      //方式：1-线上;2-线下;
@property (nonatomic, assign) int applyCount;               //报名人数
@property (nonatomic, assign) int peopleNum;                //约战最大人数
@property (nonatomic, strong) NSString *itemServer;         //项目服务器
@property (nonatomic, strong) NSString *itemName;           //约战项目名称
@property (nonatomic, strong) NSString *itemPicUrl;         //约战项目图片
@property (nonatomic, readonly) NSURL* itemPicURL;          //图片网络地址

@property (nonatomic, strong) NSString *netbarId;
@property (nonatomic, strong) NSString *netbarName;

@property(nonatomic, strong) NSDictionary* matchWarInfoByJsonDic;

@end
