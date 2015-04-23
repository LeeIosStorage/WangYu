//
//  WYSettingConfig.m
//  WangYu
//
//  Created by KID on 15/4/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSettingConfig.h"
#import "WYEngine.h"
#import "PathHelper.h"

static int s_isFirstEnterVersion = -1;

@implementation WYSettingConfig

static WYSettingConfig *s_instance = nil;

+(WYSettingConfig *)staticInstance
{
    @synchronized(s_instance){
        if (!s_instance) {
            s_instance = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getConfigStoredPath]];
            if(!s_instance)
                s_instance = [[WYSettingConfig alloc] init];
            
        }
        return s_instance;
    }
}

-(id)init
{
    if (self = [super init]) {
        //默认自动
        _systemCameraFlashStatus = UIImagePickerControllerCameraFlashModeAuto;
        
    }
    return self;
}

+ (void)logout {
    s_instance = nil;
}

-(void)login{
    //.....
}

//设置系统闪光灯状态

-(void)setSystemCameraFlashStatus:(int)systemCameraFlashStatus
{
    if (systemCameraFlashStatus < UIImagePickerControllerCameraFlashModeOff) {
        systemCameraFlashStatus = UIImagePickerControllerCameraFlashModeOff;
    }
    
    if (systemCameraFlashStatus > UIImagePickerControllerCameraFlashModeOn) {
        systemCameraFlashStatus = UIImagePickerControllerCameraFlashModeOn;
    }
    _systemCameraFlashStatus = systemCameraFlashStatus;
    [self saveSettingCfg];
}

+ (NSString*) getConfigStoredPath{
    return [[[WYEngine shareInstance] getCurrentAccoutDocDirectory] stringByAppendingPathComponent:@"WYSettingConfig"];
}

-(void)saveSettingCfg
{
    [NSKeyedArchiver archiveRootObject:self toFile:[WYSettingConfig getConfigStoredPath]];
}

-(void)setUserCfg:(NSDictionary *)dict
{
    //..
    [self saveSettingCfg];
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    //...
    _systemCameraFlashStatus = [aDecoder decodeInt32ForKey:@"systemCameraFlashStatus"];
    
    NSDictionary *dict = [WYEngine shareInstance].userInfo.userInfoByJsonDic;
    if (dict) {
        [self setUserCfg:dict];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
    
    return self;
}

-(void)handleUserInfoChanged:(id)info
{
    NSDictionary *dict = [WYEngine shareInstance].userInfo.userInfoByJsonDic;
    if (dict) {
        [self setUserCfg:dict];
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    //...
    [aCoder encodeInt32:_systemCameraFlashStatus forKey:@"systemCameraFlashStatus"];
    
}

+(NSString *)getTagPath{
    NSString *tpath = [[PathHelper documentDirectoryPathWithName:nil] stringByAppendingPathComponent:@"version.rc"];
    
    return tpath;
}

+(NSString *)getSkipSavePath{
    NSString *spath = [[PathHelper documentDirectoryPathWithName:nil] stringByAppendingPathComponent:@"skip.rc"];
    
    return spath;
}

+(void)saveEnterUsr{
    NSMutableDictionary *sd = [NSMutableDictionary dictionaryWithContentsOfFile:[self getSkipSavePath]];
    if (!sd) {
        sd = [NSMutableDictionary dictionary];
    }
    if ([WYEngine shareInstance].uid) {
        [sd setObject:@"1" forKey:[WYEngine shareInstance].uid];
    }
    //[sd setObject:@"1" forKey:[WYEngine shareInstance].uid];
    [sd writeToFile:[self getSkipSavePath] atomically:YES];
}

+(void)saveEnterVersion{
    NSString *localVserion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSMutableDictionary *td = [NSMutableDictionary dictionaryWithContentsOfFile:[self getTagPath]];
    if (!td) {
        td = [NSMutableDictionary dictionary];
    }
    [td removeAllObjects];
    [td setObject:@"1" forKey:localVserion];
    [td writeToFile:[self getTagPath] atomically:YES];
    s_isFirstEnterVersion = NO;
}

+(BOOL)isFirstEnterVersion{
    if (s_isFirstEnterVersion == -1) {
        NSString *localVserion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
        NSMutableDictionary *td = [NSMutableDictionary dictionaryWithContentsOfFile:[self getTagPath]];
        
        id value = [td objectForKey:localVserion];
        if (!value) {
            s_isFirstEnterVersion = YES;
        } else {
            s_isFirstEnterVersion = NO;
        }
        
    }
    return s_isFirstEnterVersion;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
