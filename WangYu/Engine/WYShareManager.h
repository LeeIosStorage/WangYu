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

typedef void(^WYWeiboShareResultBlock)(WBSendMessageToWeiboResponse *response);

@interface WYShareManager : NSObject <WXApiDelegate,WeiboSDKDelegate>

@property(nonatomic, strong) WBSendMessageToWeiboResponse* shareResponse;
+ (WYShareManager*)shareInstance;


+ (BOOL)shareToWXWithScene:(int)scene title:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image;

- (void)shareToWb:(WYWeiboShareResultBlock)result title:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image;

@end
