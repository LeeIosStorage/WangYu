//
//  WYAuthStore.h
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYAuthStore : NSObject

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *refreshToken;
@property (nonatomic, copy) NSDate *expiresIn;

@property (nonatomic, assign) int userId;

+ (id)sharedInstance;

- (void)updateWithSuccessDictionary:(NSDictionary *)dic;

- (BOOL)hasExpired;

// refresh token one day before token is expired.
- (BOOL)shouldRefreshToken;

- (void)save;

- (void)clear;

@end
