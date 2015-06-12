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

@interface WYSettingConfig (){
    
    NSMutableArray* _listeners;
    
    NSTimer *_waitRetrieveTimer;
    int _waitRetrieveSecond;
    
    NSTimer *_waitRegisterTimer;
    int _waitRegisterSecond;
    
}
@end

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
- (void)addListener:(id<WYSettingConfigListener>)listener{
    [_listeners addObject:listener];
}
- (void)removeListener:(id<WYSettingConfigListener>)listener{
    [_listeners removeObject:listener];
}

-(id)init
{
    if (self = [super init]) {
        //默认自动
        _systemCameraFlashStatus = UIImagePickerControllerCameraFlashModeAuto;
//        [self login];
        
    }
    return self;
}

- (void)logout {
    s_instance = nil;
    [_listeners removeAllObjects];
    if (_waitRetrieveTimer) {
        [_waitRetrieveTimer invalidate];
        _waitRetrieveTimer = nil;
    }
    if (_waitRegisterTimer) {
        [_waitRegisterTimer invalidate];
        _waitRegisterTimer = nil;
    }
}

-(void)login{
    //.....
    _listeners = [[NSMutableArray alloc] init];
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
    _mineMessageUnreadEvent = [aDecoder decodeBoolForKey:@"mineMessageUnreadEvent"];
    _weekRedBagMessageUnreadEvent = [aDecoder decodeBoolForKey:@"weekRedBagMessageUnreadEvent"];
    
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
    [aCoder encodeBool:_mineMessageUnreadEvent forKey:@"mineMessageUnreadEvent"];
    [aCoder encodeBool:_weekRedBagMessageUnreadEvent forKey:@"weekRedBagMessageUnreadEvent"];
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


- (void)setMineMessageUnreadEvent:(BOOL)mineMessageUnreadEvent{
    if (_mineMessageUnreadEvent == mineMessageUnreadEvent) {
        return;
    }
    _mineMessageUnreadEvent = mineMessageUnreadEvent;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:WY_MINEMESSAGE_UNREAD_EVENT_NOTIFICATION object:nil]];
    [self saveSettingCfg];
}

- (void)setWeekRedBagMessageUnreadEvent:(BOOL)weekRedBagMessageUnreadEvent{
    if (_weekRedBagMessageUnreadEvent == weekRedBagMessageUnreadEvent) {
        return;
    }
    _weekRedBagMessageUnreadEvent = weekRedBagMessageUnreadEvent;
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:WY_WEEKREDBAG_UNREAD_EVENT_NOTIFICATION object:nil]];
    [self saveSettingCfg];
}

//关联用户的
- (NSString *)getAccoutStorePath{
    NSString *filePath = [[WYEngine shareInstance] getCurrentAccoutDocDirectory];
    return filePath;
}
//无关用户
- (NSString *)getStorePath{
    NSString *filePath = [PathHelper documentDirectoryPathWithName:@"message"];
    return filePath;
}
-(NSString *)getMessagePath{
    return [[self getAccoutStorePath] stringByAppendingPathComponent:@"message.xml"];
}
-(int)getMessageCount{
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self getMessagePath]];
    return [messageDic intValueForKey:@"last_message"];
}

-(void)addMessageNum:(int)count{
    
    NSMutableDictionary *messageDic = [NSMutableDictionary dictionaryWithContentsOfFile:[self getMessagePath]];
    if (!messageDic) {
        messageDic = [NSMutableDictionary dictionary];
    }
//    int lastNum = [[messageDic objectForKey:@"last_message"] intValue];
//    lastNum += count;
    NSString *messageNum = [NSString stringWithFormat:@"%d",count];
    
    [messageDic removeAllObjects];
    [messageDic setObject:messageNum forKey:@"last_message"];
    [messageDic writeToFile:[self getMessagePath] atomically:YES];
}
-(void)removeMessageNum{
    NSString* path = [self getMessagePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addRetrieveTimer{
    if(_waitRetrieveTimer){
        [_waitRetrieveTimer invalidate];
        _waitRetrieveTimer = nil;
    }
    
    _waitRetrieveTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitRetrieveTimerInterval:) userInfo:nil repeats:YES];
    _waitRetrieveSecond = 60;
    [self waitRetrieveTimerInterval:_waitRetrieveTimer];
}
-(void)removeRetrieveTimer{
    if(_waitRetrieveTimer){
        [_waitRetrieveTimer invalidate];
        _waitRetrieveTimer = nil;
    }
}
-(int)getRetrieveSecond{
    int second = _waitRetrieveSecond;
    if (second <= 0) {
        second = 0;
    }
    return second;
}
- (void)waitRetrieveTimerInterval:(NSTimer *)aTimer{
    WYLog(@"a Timer with WYSettingConfig waitRetrieveTimerInterval = %d",_waitRetrieveSecond);
    if (_waitRetrieveSecond <= 0) {
        [aTimer invalidate];
        _waitRetrieveTimer = nil;
    }
    _waitRetrieveSecond--;
    
    //通知lisnteners
    NSArray* listeners = [_listeners copy];
    for (id<WYSettingConfigListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(waitRetrieveTimer:waitSecond:)]) {
            [listener waitRetrieveTimer:aTimer waitSecond:_waitRetrieveSecond];
        }
    }
}

-(void)addRegisterTimer{
    if(_waitRegisterTimer){
        [_waitRegisterTimer invalidate];
        _waitRegisterTimer = nil;
    }
    
    _waitRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(waitRegisterTimerInterval:) userInfo:nil repeats:YES];
    _waitRegisterSecond = 60;
    [self waitRegisterTimerInterval:_waitRegisterTimer];
}
-(void)removeRegisterTimer{
    if(_waitRegisterTimer){
        [_waitRegisterTimer invalidate];
        _waitRegisterTimer = nil;
    }
}
-(int)getRegisterSecond{
    int second = _waitRegisterSecond;
    if (second <= 0) {
        second = 0;
    }
    return second;
}
- (void)waitRegisterTimerInterval:(NSTimer *)aTimer{
    WYLog(@"a Timer with WYSettingConfig waitRegisterTimerInterval = %d",_waitRegisterSecond);
    if (_waitRegisterSecond <= 0) {
        [aTimer invalidate];
        _waitRegisterTimer = nil;
    }
    _waitRegisterSecond--;
    
    //通知lisnteners
    NSArray* listeners = [_listeners copy];
    for (id<WYSettingConfigListener> listener in listeners) {
        if ([listener respondsToSelector:@selector(waitRegisterTimer:waitSecond:)]) {
            [listener waitRegisterTimer:aTimer waitSecond:_waitRegisterSecond];
        }
    }
}

@end
