//
//  WYHttpRequest.h
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

extern NSUInteger const kDefaultTimeoutSeconds;
extern NSString * const WYHTTPRequestErrorDomain;
extern NSString * const WYOAuthErrorDomain;
extern NSString * const WYErrorDomain;

@class WYHttpRequest;
@class WYQuery;
@protocol WYHttpRequestDelegate <NSObject>

@required
- (void)requestFinished:(WYHttpRequest *)request;
- (void)requestFailed:(WYHttpRequest *)request;

@end

typedef enum _WYNetworkErrorType {
    WYConnectionFailureErrorType = 1,
    WYRequestTimedOutErrorType = 2,
    WYAuthenticationErrorType = 3,
    WYRequestCancelledErrorType = 4,
    WYUnableToCreateRequestErrorType = 5,
    WYInternalErrorWhileBuildingRequestType  = 6,
    WYInternalErrorWhileApplyingCredentialsType  = 7,
    WYFileManagementError = 8,
    WYTooMuchRedirectionErrorType = 9,
    WYUnhandledExceptionError = 10,
    WYCompressionError = 11
} WYNetworkErrorType;


typedef void (^WYBasicBlock)(void);
typedef void (^WYReqBlock)(WYHttpRequest *);
typedef void (^WYSizeBlock)(long long size);

@interface WYHttpRequest : ASIHTTPRequest

+ (WYHttpRequest *)requestWithURL:(NSURL *)URL;

+ (WYHttpRequest *)requestWithURL:(NSURL *)URL target:(id<WYHttpRequestDelegate>)delegate;

+ (WYHttpRequest *)requestWithQuery:(WYQuery *)query target:(id<WYHttpRequestDelegate>)delegate;

+ (WYHttpRequest *)requestWithURL:(NSURL *)URL
                   completionBlock:(WYBasicBlock)completionHandler;

+ (WYHttpRequest *)requestWithQuery:(WYQuery *)query
                     completionBlock:(WYBasicBlock)completionHandler;

+ (NSError *)adapterError:(NSError *)asiError;

- (NSError *)wangyuError;

- (void)appendPostString:(NSString *)string;

@end
