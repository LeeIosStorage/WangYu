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
@property(nonatomic, strong) NSString* avatar;
@property(nonatomic, strong) NSDate* createDate;
@property(nonatomic, strong) NSDate* updateDate;
@property(nonatomic, assign) int score;
@property(nonatomic, assign) int valid;

@property(nonatomic, strong) NSString* account;
@property(nonatomic, strong) NSString* password;

@property(nonatomic, strong) NSDictionary* userInfoByJsonDic;
@property(nonatomic, strong) NSString* jsonString;

@end
