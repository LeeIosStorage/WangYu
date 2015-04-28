//
//  WYService.h
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYHttpRequest.h"

@interface WYService : NSObject

@property (nonatomic, copy) NSString *apiBaseUrlString;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *clientSecret;

+ (WYService *)sharedInstance;

- (BOOL)isValid;

- (void)addRequest:(WYHttpRequest *)request;

- (WYHttpRequest *)get:(WYQuery *)query callback:(WYReqBlock)block;

- (WYHttpRequest *)post:(WYQuery *)query
               postBody:(NSString *)body
               callback:(WYReqBlock)block;

- (WYHttpRequest *)post:(WYQuery *)query
              photoData:(NSData *)photoData
            description:(NSString *)description
               callback:(WYReqBlock)block
 uploadProgressDelegate:(id<ASIProgressDelegate>)progressDelegate;

// v2 api post image
- (WYHttpRequest *)post2:(WYQuery *)query
               photoData:(NSData *)photoData
             description:(NSString *)description
                callback:(WYReqBlock)block
  uploadProgressDelegate:(id<ASIProgressDelegate>)progressDelegate;

- (WYHttpRequest *)put:(WYQuery *)query
               postBody:(NSString *)body
               callback:(WYReqBlock)block;

- (WYHttpRequest *)delete:(WYQuery *)query callback:(WYReqBlock)block;

- (WYHttpRequest *)get:(WYQuery *)query delegate:(id<WYHttpRequestDelegate>)delegate;

- (WYHttpRequest *)post:(WYQuery *)query postBody:(NSString *)body delegate:(id<WYHttpRequestDelegate>)delegate;

- (WYHttpRequest *)delete:(WYQuery *)query delegate:(id<WYHttpRequestDelegate>)delegate;

@end
