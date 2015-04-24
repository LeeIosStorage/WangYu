//
//  WYQuery.m
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYQuery.h"

@implementation WYQuery

- (id)initWithSubPath:(NSString *)aSubPath parameters:(NSDictionary *)theParameters {
    self = [super init];
    if (self) {
        _subPath = aSubPath;
        _parameters = theParameters;
    }
    return self;
}

- (NSString *)requestURLString {
    NSString *url = [NSString stringWithFormat:@"%@%@",_apiBaseUrlString,_subPath];
    NSString *parameterStr = [self parametersUrlString];
    if (parameterStr != nil && [parameterStr length] > 0) {
        url = [url stringByAppendingString:parameterStr];
    }
    return  [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)parametersUrlString {
    NSUInteger index = 0;
    NSString *parametersUrl = @"";
    for (id key in [self.parameters allKeys]) {
        NSString *value = [self.parameters objectForKey:key];
        if (index == 0) {
            parametersUrl = [parametersUrl stringByAppendingFormat:@"?%@=%@", key, value];
        }else {
            parametersUrl = [parametersUrl stringByAppendingFormat:@"&%@=%@", key, value];
        }
        ++index;
    }
    return parametersUrl;
}

- (NSURL *)requestURL {
    return [NSURL URLWithString:[self requestURLString]];
}

- (void)dealloc {
    _subPath= nil;
    _parameters = nil;
    _apiBaseUrlString = nil;
}

@end
