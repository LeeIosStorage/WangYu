//
//  WYUserGuideConfig.m
//  WangYu
//
//  Created by 许 磊 on 15/6/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYUserGuideConfig.h"
#import "WYEngine.h"

static WYUserGuideConfig *s_userGuideConfigInstance = nil;

@interface WYUserGuideConfig() {
    NSMutableDictionary *_guideConfigDic;
}

@end

@implementation WYUserGuideConfig

+ (WYUserGuideConfig *)shareInstance {
    @synchronized(self) {
        if (s_userGuideConfigInstance == nil) {
            s_userGuideConfigInstance = [[WYUserGuideConfig alloc] init];
        }
    }
    return s_userGuideConfigInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _guideConfigDic = [NSMutableDictionary dictionaryWithContentsOfFile:[[[WYEngine shareInstance] getCurrentAccoutDocDirectory] stringByAppendingPathComponent:@"userGuideConfig"]];
        if (_guideConfigDic == nil) {
            _guideConfigDic = [[NSMutableDictionary alloc] init];
        }
    }
    
    return self;
}

- (void)saveToPersistence {
    [_guideConfigDic writeToFile:[[[WYEngine shareInstance] getCurrentAccoutDocDirectory] stringByAppendingPathComponent:@"userGuideConfig"] atomically:YES];
}

+ (void)logout {
    s_userGuideConfigInstance = nil;
}

- (BOOL)newPeopleGuideShowForVcType:(NSString *)vcType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *vcTypeValve = [userDefaults objectForKey:vcType];
    if ([vcTypeValve isEqualToString:@"YES"]) {
        return NO;
    }else {
        return YES;
    }
}

- (void)setNewGuideShowYES:(NSString *)vcType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"YES" forKey:vcType];
}

@end
