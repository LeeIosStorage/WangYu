//
//  WYHttpRequest.m
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYHttpRequest.h"
#import "WYQuery.h"

@implementation WYHttpRequest

NSUInteger const kDefaultTimeoutSeconds = 30;
NSString * const WYHTTPRequestErrorDomain = @"WYHTTPRequestErrorDomain";
NSString * const WYOAuthErrorDomain = @"WYOAuthErrorDomain";
NSString * const WYErrorDomain = @"WYErrorDomain";

+ (WYHttpRequest *)requestWithURL:(NSURL *)URL {
    WYHttpRequest *req = [[WYHttpRequest alloc] initWithURL:URL];
    req.useCookiePersistence = NO;
    //[req setValidatesSecureCertificate:NO];
    [req setAllowCompressedResponse:YES];
    [req setTimeOutSeconds:kDefaultTimeoutSeconds];
    return req;
}

+ (WYHttpRequest *)requestWithURL:(NSURL *)URL target:(id<WYHttpRequestDelegate>)delegate {
    WYHttpRequest *req = [[self class] requestWithURL:URL];
    [req setDelegate:delegate];
    [req setDidFinishSelector:@selector(requestFinished:)];
    [req setDidFailSelector:@selector(requestFailed:)];
    return req;
}

+ (WYHttpRequest *)requestWithQuery:(WYQuery *)query target:(id<WYHttpRequestDelegate>)delegate {
    WYHttpRequest *req = [[self class] requestWithURL:[query requestURL] target:delegate];
    return req;
}

+ (WYHttpRequest *)requestWithURL:(NSURL *)URL completionBlock:(WYBasicBlock)completionHandler {
    WYHttpRequest *req = [[self class] requestWithURL:URL];
    [req setCompletionBlock:completionHandler];
    [req setFailedBlock:completionHandler];
    return req;
}

+ (WYHttpRequest *)requestWithQuery:(WYQuery *)query completionBlock:(WYBasicBlock)completionHandler {
    WYHttpRequest *req = [[self class] requestWithURL:[query requestURL] completionBlock:completionHandler];
    return req;
}

+ (NSError *)adapterError:(NSError *)asiError {
    NSError *wyError;
    switch ([asiError code]) {
        case ASIConnectionFailureErrorType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYConnectionFailureErrorType
                                          userInfo:asiError.userInfo];
            break;
        case ASIRequestTimedOutErrorType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYRequestTimedOutErrorType
                                          userInfo:asiError.userInfo];
            break;
        case WYAuthenticationErrorType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYAuthenticationErrorType
                                          userInfo:asiError.userInfo];
            break;
        case WYRequestCancelledErrorType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYRequestCancelledErrorType
                                          userInfo:asiError.userInfo];
            break;
        case WYUnableToCreateRequestErrorType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYUnableToCreateRequestErrorType
                                          userInfo:asiError.userInfo];
            break;
        case WYInternalErrorWhileBuildingRequestType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYInternalErrorWhileBuildingRequestType
                                          userInfo:asiError.userInfo];
            break;
        case WYInternalErrorWhileApplyingCredentialsType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYInternalErrorWhileApplyingCredentialsType
                                          userInfo:asiError.userInfo];
            break;
        case WYFileManagementError:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYFileManagementError
                                          userInfo:asiError.userInfo];
            break;
        case WYTooMuchRedirectionErrorType:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYTooMuchRedirectionErrorType
                                          userInfo:asiError.userInfo];
            break;
        case WYUnhandledExceptionError:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYUnhandledExceptionError
                                          userInfo:asiError.userInfo];
            break;
        case WYCompressionError:
            wyError = [NSError errorWithDomain:WYHTTPRequestErrorDomain
                                              code:WYCompressionError
                                          userInfo:asiError.userInfo];
            break;
        default:
            wyError = asiError;
            break;
    }
    return wyError;
}

- (NSError *)wangyuError {
    NSError *asiError = [super error];
    if (asiError) {
        return [[self class] adapterError:asiError];
    }
    
    int statusCode = [self responseStatusCode];
    if (statusCode == 200 || statusCode == 201 || statusCode == 202) {
        return nil;
    }else if (statusCode == 400) {
        NSString *response = [self responseString];
        NSData* jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        NSInteger code = 0;
        if (dic) {
            code = [[dic objectForKey:@"code"] integerValue];
        }
        if (dic) {
            NSError *oauthError = [NSError errorWithDomain:WYOAuthErrorDomain code:code userInfo:dic];
            return oauthError;
        }
    }
    NSError *otherError = [NSError errorWithDomain:WYErrorDomain code:error.code userInfo:nil];
    return otherError;
}

- (void)appendPostString:(NSString *)string {
    [super appendPostData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
