//
//  WYService.m
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYService.h"
#import "WYOAuthService.h"
#import "WYOAuthStore.h"
#import "ASINetworkQueue.h"
#import "WYQuery.h"
#import "NSData+Base64.h"

//暂时定下
NSString * const kTokenUrl = @"https://www.wangyu.com/service/auth2/token";
NSUInteger const kDefaultMaxConcurrentOperationCount = 4;

@interface WYService()

@property (nonatomic, strong) ASINetworkQueue *queue;

- (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount;

@end

@implementation WYService

- (id)init {
    self = [super init];
    if (self) {
        //...
    }
    return self;
}

#pragma mark - Singleton

static WYService *myInstance = nil;

+ (WYService *)sharedInstance {
    @synchronized(self) {
        if (myInstance == nil) {
            myInstance = [[WYService alloc] init];
        }
    }
    return myInstance;
}

- (NSError *)executeRefreshToken {
    WYOAuthService *service = [WYOAuthService sharedInstance];
    service.authorizationURL = kTokenUrl;
    service.clientId = self.clientId;
    service.clientSecret = self.clientSecret;
    return [service validateRefresh];
}

- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [dict setObject:val forKey:key];
    }
    return dict;
}

- (void)sign:(WYHttpRequest *)request{
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    if (store.accessToken && ![store hasExpired]) {
        NSString *authValue = [NSString stringWithFormat:@"%@ %@", @"Bearer", store.accessToken];
        [request addRequestHeader:@"Authorization" value:authValue];
    }else {
        NSString *clientId = self.clientId;
        if (!clientId) {
            return;
        }
        NSURL *url = [request url];
        NSString *urlString = [url absoluteString];
        NSString *query = [url query];
        if (query) {
            NSDictionary *parameters = [self parseQueryString:query];
            NSArray *keys = [parameters allKeys];
            if ([keys count] == 0) {
                urlString = [urlString stringByAppendingFormat:@"?%@=%@", @"apikey", clientId];
            }
            else {
                urlString = [urlString stringByAppendingFormat:@"&%@=%@", @"apikey", clientId];
            }
        } else {
            urlString = [urlString stringByAppendingFormat:@"?%@=%@", @"apikey", clientId];
        }
        
        NSString *afterUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        request.url = [NSURL URLWithString:afterUrl];
    }
}

- (void)addRequest:(WYHttpRequest *)request {
    if (![self queue]) {
        [self setQueue:[[ASINetworkQueue alloc] init]];
        self.queue.maxConcurrentOperationCount = kDefaultMaxConcurrentOperationCount;
    }
    
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    if (store.userId != 0 && store.refreshToken && [store shouldRefreshToken]) {
        [self executeRefreshToken];
    }
    [self sign:request];
    
    [[self queue] addOperation:request];
    [[self queue] go];
}

- (void)setMaxConcurrentOperationCount:(NSUInteger)maxCount {
    self.queue.maxConcurrentOperationCount = maxCount;
}

- (BOOL)isValid {
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    if (store.accessToken) {
        //..
        return ![store hasExpired];
    }
    return NO;
}

- (WYHttpRequest *)get:(WYQuery *)query callback:(WYReqBlock)block {
    query.apiBaseUrlString = self.apiBaseUrlString;
    __block WYHttpRequest * req = [WYHttpRequest requestWithQuery:query completionBlock:^{
        if (block != NULL) {
            block(req);
        }
    }];
    [req setRequestMethod:@"GET"];
    [self addRequest:req];
    return req;
}

- (WYHttpRequest *)post:(WYQuery *)query postBody:(NSString *)body callback:(WYReqBlock)block {
    query.apiBaseUrlString = self.apiBaseUrlString;
    __block WYHttpRequest * req = [WYHttpRequest requestWithQuery:query completionBlock:^{
        if (block != NULL) {
            block(req);
        }
    }];
    [req setRequestMethod:@"POST"];
    [req addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
//    if (body && [body length] > 0) {
//        NSError *error = nil;
//        GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:body error:&error] autorelease];
//        if (!error && element) {
//            // if body is XML, Content-Type must be application/atom+xml
//            [req addRequestHeader:@"Content-Type" value:@"application/atom+xml"];
//        }
//        
//        NSData *objectData = [body dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *length = [NSString stringWithFormat:@"%d", [objectData length]];
//        [req appendPostData:objectData];
//        [req addRequestHeader:@"Content-Length" value:length];
//    }
//    else {
//        [req addRequestHeader:@"Content-Length" value:@"0"];
//    }
    [req setResponseEncoding:NSUTF8StringEncoding];
    [self addRequest:req];
    return req;
}

- (WYHttpRequest *)post:(WYQuery *)query
               photoData:(NSData *)photoData
             description:(NSString *)description
                callback:(WYReqBlock)block
  uploadProgressDelegate:(id<ASIProgressDelegate>)progressDelegate {
    
    query.apiBaseUrlString = self.apiBaseUrlString;
    __block WYHttpRequest * req = [WYHttpRequest requestWithQuery:query completionBlock:^{
        if (block != NULL) {
            block(req);
        }
    }];
    
    
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    NSData *boundaryData   = [[NSString stringWithFormat:@"--%@\n", boundary]
                              dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *finalBoundaryData = [[NSString stringWithFormat:@"\n--%@--", boundary]
                                 dataUsingEncoding:NSUTF8StringEncoding];
    
    [req setRequestMethod:@"POST"];
    [req setResponseEncoding:NSUTF8StringEncoding];
    [req setUploadProgressDelegate:progressDelegate];
    
    [req addRequestHeader:@"Content-Type"
                    value:[NSString stringWithFormat:@"multipart/related; boundary=\"%@\"", boundary]];
    [req addRequestHeader:@"MIME-version" value:@"1.0"];
    
    // Content XML
    [req appendPostData:boundaryData];
    [req appendPostData:[@"Content-Type: application/atom+xml\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
//    GDataEntryBase *emptyEntry = [[[GDataEntryBase alloc] init] autorelease];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:kAtomNamespace, kAtomNamespacePrefix, kDoubanNamespace, kDoubanNamespacePrefix, nil];
//    [emptyEntry addNamespaces:dic];
//    [emptyEntry addExtensionDeclarations];
//    
//    GDataEntryContent *content = [GDataEntryContent contentWithString:description];
//    [emptyEntry setContent:content];
//    NSData *descData = [[emptyEntry XMLDocument] XMLData];
//    [req appendPostData:descData];
    [req appendPostData:boundaryData];
    
    // Image base64 binary
    [req appendPostData:[@"Content-Type: image/jpeg\n\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *encodingStr = [photoData base64EncodedString];
    NSData *data = [encodingStr dataUsingEncoding:NSUTF8StringEncoding];
    [req appendPostData:data];
    [req appendPostData:finalBoundaryData];
    
    // request length
    NSData *postData = [req postBody];
    [req addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", (NSInteger)[postData length]]];
    
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    if (store.userId != 0 && store.refreshToken && [store shouldRefreshToken]) {
        [self executeRefreshToken];
    }
    
    [self sign:req];
    [req startAsynchronous];
    return req;  
}

- (WYHttpRequest *)post2:(WYQuery *)query
                photoData:(NSData *)photoData
              description:(NSString *)description
                 callback:(WYReqBlock)block
   uploadProgressDelegate:(id<ASIProgressDelegate>)progressDelegate {
    
    query.apiBaseUrlString = self.apiBaseUrlString;
    __block WYHttpRequest * req = [WYHttpRequest requestWithQuery:query completionBlock:^{
        if (block != NULL) {
            block(req);
        }
    }];
    
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    // We don't bother to check if post data contains the boundary, since it's pretty unlikely that it does.
    CFUUIDRef uuid = CFUUIDCreate(nil);
    NSString *uuidString = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuid));
    CFRelease(uuid);
    NSString *stringBoundary = [NSString stringWithFormat:@"0xKhTmLbOuNdArY-%@",uuidString];
    NSString *endItemBoundary = [NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary];
    
    [req setRequestMethod:@"POST"];
    [req setResponseEncoding:NSUTF8StringEncoding];
    [req setUploadProgressDelegate:progressDelegate];
    
    [req addRequestHeader:@"Content-Type" value:[NSString stringWithFormat:@"multipart/form-data; charset=%@; boundary=%@", charset, stringBoundary]];
    
    [req appendPostString:[NSString stringWithFormat:@"--%@\r\n",stringBoundary]];
    
    // Adds post data
    [req appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"desc"]];
    [req appendPostString:description];
    [req appendPostString:endItemBoundary];
    
    // Adds Post file
    [req appendPostString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"image", @"image.jpeg"]];
    [req appendPostString:[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"image/jpeg"]];
    [req appendPostData:photoData];
    
    [req appendPostString:[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary]];
    
    // request length
    NSData *postData = [req postBody];
    [req addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%ld", (NSInteger)[postData length]]];
    
    WYOAuthStore *store = [WYOAuthStore sharedInstance];
    if (store.userId != 0 && store.refreshToken && [store shouldRefreshToken]) {
        [self executeRefreshToken];
    }
    
    [self sign:req];
    [req startAsynchronous];
    return req;
}

- (WYHttpRequest *)put:(WYQuery *)query postBody:(NSString *)body callback:(WYReqBlock)block {
    query.apiBaseUrlString = self.apiBaseUrlString;
    __block WYHttpRequest * req = [WYHttpRequest requestWithQuery:query completionBlock:^{
        if (block != NULL) {
            block(req);
        }
    }];
    
    [req setRequestMethod:@"PUT"];
    [req addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    
//    if (body && [body length] > 0) {
//        
//        NSError *error = nil;
//        GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:body error:&error] autorelease];
//        if (!error && element) {
//            // if body is XML, Content-Type must be application/atom+xml
//            [req addRequestHeader:@"Content-Type" value:@"application/atom+xml"];
//        }
//        
//        NSData *objectData = [body dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *length = [NSString stringWithFormat:@"%d", [objectData length]];
//        [req appendPostData:objectData];
//        [req addRequestHeader:@"Content-Length" value:length];
//    }
//    else {
//        [req addRequestHeader:@"Content-Length" value:@"0"];
//    }
    
    [req setResponseEncoding:NSUTF8StringEncoding];
    [self addRequest:req];
    return req;
}

- (WYHttpRequest *)delete:(WYQuery *)query callback:(WYReqBlock)block {
    
    query.apiBaseUrlString = self.apiBaseUrlString;
    
    __block WYHttpRequest * req = [WYHttpRequest requestWithQuery:query completionBlock:^{
        if (block != NULL) {
            block(req);
        }
    }];
    
    [req setRequestMethod:@"DELETE"];
    [req addRequestHeader:@"Content-Type" value:@"application/atom+xml"];
    [req addRequestHeader:@"Content-Length" value:@"0"];
    [self addRequest:req];
    return req;
}

- (WYHttpRequest *)get:(WYQuery *)query delegate:(id<WYHttpRequestDelegate>)delegate {
    query.apiBaseUrlString = self.apiBaseUrlString;
    WYHttpRequest * req = [WYHttpRequest requestWithQuery:query target:delegate];
    
    [req setRequestMethod:@"GET"];
    [self addRequest:req];
    return req;
}

- (WYHttpRequest *)post:(WYQuery *)query postBody:(NSString *)body delegate:(id<WYHttpRequestDelegate>)delegate {
    query.apiBaseUrlString = self.apiBaseUrlString;
    WYHttpRequest * req = [WYHttpRequest requestWithQuery:query target:delegate];
    
    [req setRequestMethod:@"POST"];
    [req addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=UTF-8"];
    
//    if (body && [body length] > 0) {
//        
//        NSError *error = nil;
//        GDataXMLElement *element = [[[GDataXMLElement alloc] initWithXMLString:body error:&error] autorelease];
//        if (!error && element) {
//            // if body is XML, Content-Type must be application/atom+xml
//            [req addRequestHeader:@"Content-Type" value:@"application/atom+xml"];
//        }
//        
//        NSData *objectData = [body dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *length = [NSString stringWithFormat:@"%d", [objectData length]];
//        [req appendPostData:objectData];
//        [req addRequestHeader:@"Content-Length" value:length];
//    }
//    else {
//        [req addRequestHeader:@"Content-Length" value:@"0"];
//    }
    
    [req setResponseEncoding:NSUTF8StringEncoding];
    [self addRequest:req];
    return req;
}


- (WYHttpRequest *)delete:(WYQuery *)query delegate:(id<WYHttpRequestDelegate>)delegate {
    query.apiBaseUrlString = self.apiBaseUrlString;
    
    WYHttpRequest * req = [WYHttpRequest requestWithQuery:query target:delegate];
    [req setRequestMethod:@"DELETE"];
    [req addRequestHeader:@"Content-Type" value:@"application/atom+xml"];
    [req addRequestHeader:@"Content-Length" value:@"0"];      
    [self addRequest:req];
    return req;
}

- (void)dealloc {
    _queue = nil;
    _apiBaseUrlString = nil;
    _clientId = nil;
    _clientSecret = nil;
}

@end
