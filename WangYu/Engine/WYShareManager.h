//
//  WYShareManager.h
//  WangYu
//
//  Created by KID on 15/5/19.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "TencentOpenAPI/QQApiInterface.h"

typedef void(^WYWeiboShareResultBlock)(WBSendMessageToWeiboResponse *response);

@interface WYShareManager : NSObject <WXApiDelegate,WeiboSDKDelegate,QQApiInterfaceDelegate>

@property(nonatomic, strong) WBSendMessageToWeiboResponse* shareResponse;
+ (WYShareManager*)shareInstance;

//分享到微信
- (BOOL)shareToWXWithScene:(int)scene title:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image;
//分享到微博
- (void)shareToWb:(WYWeiboShareResultBlock)result title:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image VC:(id)VC;
//分享到QQ
- (void)shareToQQTitle:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image;

@end
