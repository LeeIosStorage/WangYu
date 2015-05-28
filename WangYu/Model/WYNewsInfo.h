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
@property (nonatomic, strong) NSString *newsImageUrl;       //资讯URL
@property (nonatomic, assign) BOOL isSubject;               //是否为专题
@property (nonatomic, readonly) NSURL *smallImageURL;       //图片网络地址

@property (nonatomic, strong) NSDictionary* newsInfoByJsonDic; //资讯字典

@end
