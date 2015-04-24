//
//  WYQuery.h
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYQuery : NSObject

@property (nonatomic, copy) NSString *subPath;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, copy) NSString *apiBaseUrlString;

- (id)initWithSubPath:(NSString *)aSubPath parameters:(NSDictionary *)theParameters;

- (NSString *)requestURLString;

- (NSURL *)requestURL;

@end
