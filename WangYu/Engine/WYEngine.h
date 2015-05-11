//
//  WYEngine.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYUserInfo.h"

#define WY_USERINFO_CHANGED_NOTIFICATION @"WY_USERINFO_CHANGED_NOTIFICATION"

//平台切换宏
typedef enum {
    OnlinePlatform  = 1,    //线上平台
    TestPlatform    = 2,    //测试平台
}ServerPlatform;

typedef void(^onAppServiceBlock)(NSInteger tag, NSDictionary* jsonRet, NSError* err);

@interface WYEngine : NSObject

@property (nonatomic, strong) NSString* uid;
@property (nonatomic, strong) NSString* account;
@property (nonatomic, strong) NSString* userPassword;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) WYUserInfo* userInfo;
@property (nonatomic, readonly) NSDictionary* globalDefaultConfig;

@property (nonatomic, readonly) NSString* baseUrl;
@property (nonatomic, readonly) NSString* baseImgUrl;
@property (nonatomic, assign) BOOL firstLogin;

@property (nonatomic, assign) ServerPlatform serverPlatform;
@property (nonatomic, readonly) NSString* wyInstanceDocPath;

+ (WYEngine *)shareInstance;
+ (NSDictionary*)getReponseDicByContent:(NSData*)content err:(NSError*)err;
+ (NSString*)getErrorMsgWithReponseDic:(NSDictionary*)dic;
+ (NSString*)getErrorCodeWithReponseDic:(NSDictionary*)dic;
+ (NSString*)getSuccessMsgWithReponseDic:(NSDictionary*)dic;

- (void)logout;
- (void)logout:(BOOL)removeAccout;

#pragma mark - userInfo
- (void)saveAccount;
- (NSString*)getCurrentAccoutDocDirectory;
- (NSString*)getMemoryLoginedAccout;//获取记忆登录过的Account

- (void)refreshUserInfo;
- (BOOL)hasAccoutLoggedin;

#pragma mark - Visitor
- (void)visitorLogin;
- (BOOL)needUserLogin:(NSString *)message;

#pragma mark - request
- (int)getConnectTag;
- (void)addOnAppServiceBlock:(onAppServiceBlock)block tag:(int)tag;
- (void)removeOnAppServiceBlockForTag:(int)tag;
- (void)addGetCacheTag:(int)tag;
- (onAppServiceBlock)getonAppServiceBlockByTag:(int)tag;

//异步回调
- (void)getCacheReponseDicForTag:(int)tag complete:(void(^)(NSDictionary* jsonRet))complete;
- (void)getCacheReponseDicForUrl:(NSString*)url complete:(void(^)(NSDictionary* jsonRet))complete;

//保存cache
- (void)saveCacheWithString:(NSString*)str url:(NSString*)url;
- (void)clearAllCache;
- (unsigned long long)getUrlCacheSize;

#pragma mark ------ API LIST
- (BOOL)registerWithPhone:(NSString*)phone password:(NSString*)password invitationCode:(NSString*)invitationCode tag:(int)tag;
//获取验证码
- (BOOL)getCodeWithPhone:(NSString*)phone type:(NSString*)type tag:(int)tag;
//校验验证码
- (BOOL)checkCodeWithPhone:(NSString*)phone code:(NSString*)msgcode codeType:(NSString*)type tag:(int)tag;
//重置密码
- (BOOL)resetPassword:(NSString*)password withPhone:(NSString*)phone tag:(int)tag;
//校验邀请码
- (BOOL)checkInvitationCodeWithCode:(NSString*)invitationCode tag:(int)tag;

- (BOOL)loginWithPhone:(NSString*)phone password:(NSString*)password tag:(int)tag error:(NSError **)errPtr;
- (BOOL)getUserInfoWithUid:(NSString*)uid tag:(int)tag error:(NSError **)errPtr;

#pragma mark - 网吧
- (BOOL)getReserveOrderListWithUid:(NSString *)uid tag:(int)tag;
- (BOOL)getPayOrderListWithUid:(NSString *)uid tag:(int)tag;

@end
