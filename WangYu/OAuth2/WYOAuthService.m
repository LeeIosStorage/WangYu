//
//  WYAuthService.m
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYOAuthService.h"
#import "ASIFormDataRequest.h"
#import "WYOAuth2.h"
#import "WYOAuthStore.h"

@interface WYOAuthService () <ASIHTTPRequestDelegate>

@end

@implementation WYOAuthService

static WYOAuthService *myInstance = nil;

+ (WYOAuthService *)sharedInstance {
    @synchronized(self) {
        if (myInstance == nil) {
            myInstance = [[WYOAuthService alloc] init];
        }
    }
    return myInstance;
}

- (ASIFormDataRequest *) formRequest {
    NSURL *URL = [NSURL URLWithString:self.authorizationURL];
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:URL];
    [req setRequestMethod:@"POST"];
    [req setValidatesSecureCertificate:NO];
    [req setAllowCompressedResponse:YES]; // YES is the default
    [req setTimeOutSeconds:kDefaultTimeoutSeconds];
    
    [req setPostValue:self.clientId forKey:kClientIdKey];
    [req setPostValue:self.clientSecret forKey:kClientSecretKey];
    [req setPostValue:self.callbackURL forKey:kRedirectURIKey];
    
    return req;
}

- (void)validateAuthorizationCode {
    ASIFormDataRequest *req = [self formRequest];
    [req setDelegate:self];
    [req setPostValue:@"authorization_code" forKey:kGrantTypeKey];
    [req setPostValue:self.authorizationCode forKey:kOAuth2ResponseTypeCode];
    [req startAsynchronous];
}

- (void)validateUsername:(NSString *)username password:(NSString *)password {
    ASIFormDataRequest *req = [self formRequest];
    [req setDelegate:self];
    
    [req setPostValue:kGrantTypePassword forKey:kGrantTypeKey];
    [req setPostValue:username forKey:kUsernameKey];
    [req setPostValue:password forKey:kPasswordKey];
    
    [req startAsynchronous];
}

- (NSError *)validateRefresh {
    ASIFormDataRequest *req = [self formRequest];
    [req setPostValue:kGrantTypeRefreshToken forKey:kGrantTypeKey];
    
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    NSString *refreshToken = store.refreshToken;
    [req setPostValue:refreshToken forKey:kOAuth2ResponseTypeToken];
    [req startSynchronous];
    
    NSError *error = [req error];
    if (!error) {
        NSString* responseStr = [req responseString];
        NSData* jsonData = [responseStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        WYOAuthStore *store = [WYOAuthStore sharedInstance];
        [store updateWithSuccessDictionary:dic];
    }
    
    return error;
}

- (void)requestFailed:(ASIHTTPRequest *)req {
    NSError *error = nil;
    
    NSError *asiError = [req error];
    if (asiError) {
        error = [WYHttpRequest adapterError:asiError];
    }
    
    int statusCode = [req responseStatusCode];
    if (statusCode >= 400 && statusCode <= 403) {
        NSString *response = [req responseString];
        NSData* jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        if (dic) {
            NSInteger code = [[dic objectForKey:@"code"] integerValue];
            error = [NSError errorWithDomain:WYOAuthErrorDomain code:code userInfo:dic];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(OAuthClient:didFailWithError:)]) {
        [self.delegate OAuthClient:self didFailWithError:error];
    }
    
}

- (void)requestFinished:(ASIHTTPRequest *)req {
    NSError *error = nil;
    
    NSError *asiError = [req error];
    if (asiError) {
        error = [WYHttpRequest adapterError:asiError];
    }
    
    int statusCode = [req responseStatusCode];
    if (statusCode >= 400 && statusCode <= 403) {
        NSString *response = [req responseString];
        NSData* jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        if (dic) {
            NSInteger code = [[dic objectForKey:@"code"] integerValue];
            error = [NSError errorWithDomain:WYOAuthErrorDomain code:code userInfo:dic];
        }
    }
    
    if (error) {
        if ([self.delegate respondsToSelector:@selector(OAuthClient:didFailWithError:)]) {
            [self.delegate OAuthClient:self didFailWithError:error];
            return;
        }
    }
    
    NSString *response = [req responseString];
    NSLog(@"login success:%@", response);
    NSData* jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    [store updateWithSuccessDictionary:dic];
    
    if ([self.delegate respondsToSelector:@selector(OAuthClient:didAcquireSuccessDictionary:)]) {
        [self.delegate OAuthClient:self didAcquireSuccessDictionary:dic];
    }
}

- (void)validateUsername:(NSString *)username password:(NSString *)password callback:(WYBasicBlock)block {
    ASIFormDataRequest *req = [self formRequest];
    
    [req setDelegate:self];
    
    [req setPostValue:@"password" forKey:kGrantTypeKey];
    [req setPostValue:username forKey:kUsernameKey];
    [req setPostValue:password forKey:kPasswordKey];
    [req setCompletionBlock:block];
    [req setFailedBlock:block];
    
    [req startAsynchronous];
}

- (void)validateAuthorizationCodeWithCallback:(WYBasicBlock)block {
    ASIFormDataRequest *req = [self formRequest];
    [req setDelegate:self];
    [req setPostValue:@"authorization_code" forKey:kGrantTypeKey];
    [req setPostValue:self.authorizationCode forKey:kOAuth2ResponseTypeCode];
    
    [req setCompletionBlock:block];
    [req setFailedBlock:block];
    
    [req startAsynchronous];
}

- (void)logout {
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    [store clear];
}


@end
