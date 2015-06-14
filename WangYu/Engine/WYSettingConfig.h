//
//  WYSettingConfig.h
//  WangYu
//
//  Created by KID on 15/4/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WY_MINEMESSAGE_UNREAD_EVENT_NOTIFICATION @"WY_MINEMESSAGE_UNREAD_EVENT_NOTIFICATION"
#define WY_WEEKREDBAG_UNREAD_EVENT_NOTIFICATION @"WY_WEEKREDBAG_UNREAD_EVENT_NOTIFICATION"

@protocol SettingConfigChangeD;
@interface WYSettingConfig : NSObject<NSCoding>

//系统相机闪光灯状态
@property (nonatomic, assign) int systemCameraFlashStatus;
@property (nonatomic, assign)id<SettingConfigChangeD> settingDelegater;

+(WYSettingConfig *)staticInstance;

- (void)logout;
- (void)login;

-(void)saveSettingCfg;
-(void)setUserCfg:(NSDictionary*)dict;

+(void)saveEnterVersion;
+(BOOL)isFirstEnterVersion;

+(void)saveEnterUsr;

//我的是否有新消息
@property (nonatomic, assign) BOOL mineMessageUnreadEvent;
//每周领红包消息
@property (nonatomic, assign) BOOL weekRedBagMessageUnreadEvent;

-(int)getMessageCount;
-(void)addMessageNum:(int)count;
-(void)removeMessageNum;

//找回密码验证码倒计时
-(void)addRetrieveTimer;
-(void)removeRetrieveTimer;
-(int)getRetrieveSecond;
//注册时验证码倒计时
-(void)addRegisterTimer;
-(void)removeRegisterTimer;
-(int)getRegisterSecond;

@end

@protocol SettingConfigChangeD <NSObject>
@optional
//找回密码
- (void)waitRetrieveTimer:(NSTimer *)aTimer waitSecond:(int)waitSecond;
//注册时
- (void)waitRegisterTimer:(NSTimer *)aTimer waitSecond:(int)waitSecond;
@end