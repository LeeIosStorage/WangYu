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

@end
