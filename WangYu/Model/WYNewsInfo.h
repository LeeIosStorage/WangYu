//
//  WYNewsInfo.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYNewsInfo : NSObject

@property (nonatomic, strong) NSString *nid;                //资讯id
@property (nonatomic, strong) NSString *title;              //资讯标题
@property (nonatomic, strong) NSString *brief;              //资讯简介
@property (nonatomic, strong) NSString *originalImageUrl;   //资讯原图
@property (nonatomic, strong) NSString *middleImageUrl;     //资讯中图
@property (nonatomic, strong) NSString *thumbImageUrl;      //资讯小图

@property (nonatomic, assign) BOOL isSubject;               //是否为专题
@property (nonatomic, readonly) NSURL *thumbImageURL;       //资讯小图地址
@property (nonatomic, readonly) NSURL *middleImageURL;      //资讯中图地址
@property (nonatomic, readonly) NSURL *originalImageURL;    //资讯原图地址
@property (nonatomic, strong) NSString *cover;              //hot图片
@property (nonatomic, readonly) NSURL *hotImageURL;         //hot图片网址

@property (nonatomic, strong) NSDictionary* newsInfoByJsonDic; //资讯字典

@end
