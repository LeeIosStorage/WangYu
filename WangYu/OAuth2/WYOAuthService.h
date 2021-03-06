//
//  WYAuthService.h
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYService.h"

@class WYOAuthService;
@protocol WYAuthServiceDelegate<NSObject>

@required

- (void)OAuthClient:(WYOAuthService *)client didAcquireSuccessDictionary:(NSDictionary *)dic;
- (void)OAuthClient:(WYOAuthService *)client didFailWithError:(NSError *)error;

@end

@interface WYOAuthService : NSObject

@property (nonatomic, assign) id<WYAuthServiceDelegate> delegate;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *authorizationURL;
@property (nonatomic, strong) NSString *callbackURL;
@property (nonatomic, strong) NSString *authorizationCode;

+ (id)sharedInstance;

- (void)validateAuthorizationCode;

- (void)validateUsername:(NSString *)username password:(NSString *)password;

- (NSError *)validateRefresh;

- (void)validateUsername:(NSString *)username
                password:(NSString *)password
                callback:(WYBasicBlock)block;

- (void)validateAuthorizationCodeWithCallback:(WYBasicBlock)block;

- (void)logout;

@end
