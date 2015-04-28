//
//  WYAuthStore.m
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYOAuthStore.h"
#import "WYOAuth2.h"
#import "JSONKit.h"

@implementation WYOAuthStore

static NSString *kUserDefaultsAccessTokenKey = @"wangyu_userdefaults_access_token";
static NSString *kUserDefaultsRefreshTokenKey = @"wangyu_userdefaults_refresh_token";
static NSString *kUserDefaultsExpiresInKey = @"wangyu_userdefaults_expires_in";
static NSString *kUserDefaultsUserIdKey = @"wangyu_userdefaults_user_id";

#pragma mark - Singleton

static WYOAuthStore *myInstance = nil;

+ (WYOAuthStore *)sharedInstance {
    @synchronized(self) {
        if (myInstance == nil) {
            myInstance = [[WYOAuthStore alloc] init];
        }
    }
    return myInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self updateWithUserDefaults];
    }
    return self;
}

- (void)updateWithSuccessDictionary:(NSDictionary *)dic {
    self.accessToken = [dic objectForKey:kAccessTokenKey];
    self.refreshToken = [dic objectForKey:kRefreshTokenKey];
    
    NSUInteger expiresSecond = [[dic objectForKey:kExpiresInKey] integerValue];
    self.expiresIn = [[NSDate date] dateByAddingTimeInterval:expiresSecond];
    self.userId = [[dic objectForKey:kWangYuUserIdKey] intValue];
    [self save];
}

- (BOOL)hasExpired {
    NSDate *now = [NSDate date];
    NSDate *thirtyMinutesBeforeExpires = [self.expiresIn dateByAddingTimeInterval:-1800];
    if ([now compare:thirtyMinutesBeforeExpires] == NSOrderedAscending) {
        return NO;
    }
    return YES;
}

// refresh token one day before token is expired.
- (BOOL)shouldRefreshToken{
    NSDate *now = [NSDate date];
    NSDate *oneDayBeforeExpires = [self.expiresIn dateByAddingTimeInterval:-86400];
    if ([now compare:oneDayBeforeExpires] == NSOrderedAscending) {
        return NO;
    }
    return YES;
}

- (void)save {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.accessToken forKey:kUserDefaultsAccessTokenKey];
    [userDefaults setObject:self.refreshToken forKey:kUserDefaultsRefreshTokenKey];
    [userDefaults setObject:self.expiresIn forKey:kUserDefaultsExpiresInKey];
    [userDefaults setInteger:self.userId forKey:kUserDefaultsUserIdKey];
    [userDefaults synchronize];
}

- (void)clear {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kUserDefaultsAccessTokenKey];
    [userDefaults removeObjectForKey:kUserDefaultsRefreshTokenKey];
    [userDefaults removeObjectForKey:kUserDefaultsExpiresInKey];
    [userDefaults removeObjectForKey:kUserDefaultsUserIdKey];
    [userDefaults synchronize];
}

- (void)updateWithUserDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults stringForKey:kUserDefaultsAccessTokenKey];
    self.refreshToken = [userDefaults stringForKey:kUserDefaultsRefreshTokenKey];
    self.expiresIn = [userDefaults objectForKey:kUserDefaultsExpiresInKey];
    self.userId = [[userDefaults objectForKey:kUserDefaultsUserIdKey] intValue];
}

- (NSString *)accessToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [userDefaults stringForKey:kUserDefaultsAccessTokenKey];
    return self.accessToken;
}

- (NSString *)refreshToken {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.refreshToken = [userDefaults stringForKey:kUserDefaultsRefreshTokenKey];
    return self.refreshToken;
}

- (NSDate *)expiresIn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.expiresIn = [userDefaults objectForKey:kUserDefaultsExpiresInKey];
    return self.expiresIn;
}

- (int)userId {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.userId = [[userDefaults objectForKey:kUserDefaultsUserIdKey] intValue];
    return self.userId;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@\r\ntoken = %@\r\nexpiry = %@",[super description], self.accessToken, self.expiresIn];
}

- (void)dealloc {
    _accessToken = nil;
    _refreshToken = nil;
    _expiresIn = nil;
}

@end
