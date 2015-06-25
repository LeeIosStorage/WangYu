//
//  WYUserInfo.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYUserInfo : NSObject

@property(nonatomic, strong) NSString* uid;

@property(nonatomic, strong) NSString* nickName;
@property(nonatomic, strong) NSString* telephone;
@property(nonatomic, strong) NSString* gender;//性别 0男 1女
@property(nonatomic, strong) NSString* idCard;//身份证号
@property(nonatomic, strong) NSString* realName;//真实姓名
@property(nonatomic, strong) NSString* qq;//qq号

@property(nonatomic, strong) NSString* avatar;
@property(nonatomic, strong) NSString* cityCode;
@property(nonatomic, strong) NSString* cityName;
@property(nonatomic, strong) NSDate* createDate;
@property(nonatomic, strong) NSDate* updateDate;
@property(nonatomic, assign) int score;
@property(nonatomic, assign) int valid;

@property(nonatomic, strong) NSString* account;
@property(nonatomic, strong) NSString* token;
@property(nonatomic, strong) NSString* password;

@property(nonatomic, readonly) NSURL* smallAvatarUrl;

@property(nonatomic, strong) NSDictionary* userInfoByJsonDic;
@property(nonatomic, strong) NSString* jsonString;

@end
