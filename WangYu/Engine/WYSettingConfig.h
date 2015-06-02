//
//  WYSettingConfig.h
//  WangYu
//
//  Created by KID on 15/4/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYSettingConfig : NSObject<NSCoding>

//系统相机闪光灯状态
@property (nonatomic, assign) int systemCameraFlashStatus;

+(WYSettingConfig *)staticInstance;

+ (void)logout;
- (void)login;

-(void)saveSettingCfg;
-(void)setUserCfg:(NSDictionary*)dict;

+(void)saveEnterVersion;
+(BOOL)isFirstEnterVersion;

+(void)saveEnterUsr;

-(int)getMessageCount;
-(void)addMessageNum:(int)count;

@end
