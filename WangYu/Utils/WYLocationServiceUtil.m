//
//  WYLocationServiceUtil.m
//  WangYu
//
//  Created by KID on 15/5/14.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYLocationServiceUtil.h"
#import "WYUIUtils.h"
#import "CLLocation+Sino.h"
#import "PathHelper.h"

@interface WYLocationServiceUtil() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *manager;
@property (nonatomic, strong) CLGeocoder *mRgeo;
@property (nonatomic, strong) NSMutableArray    *callbackArray;
@property (nonatomic, strong) NSMutableArray    *sucessCallbackArray;

//经纬反编码
@property (nonatomic, strong) NSMutableArray    *reverseSucessCallbackArray;

@end

@implementation WYLocationServiceUtil

+(WYLocationServiceUtil *) shareInstance
{
    static WYLocationServiceUtil *_shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[WYLocationServiceUtil alloc] init];
    });
    
    return _shareInstance;
}

- (id)init
{
    if (self = [super init]) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        _callbackArray = [[NSMutableArray alloc] init];
        _sucessCallbackArray = [NSMutableArray array];
        _reverseSucessCallbackArray = [NSMutableArray array];
    }
    return self;
}

//简单判断用户定位服务是否开启
+(BOOL) isLocationServiceOpen
{
    BOOL isLocation = [CLLocationManager locationServicesEnabled];//确定用户的位置服务启用
    if (!isLocation || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)//位置服务是在设置中禁用
    {
        return NO;
    }
    
    return YES;
}

+(CLLocationCoordinate2D)convertNewCoordinateWith:(CLLocationCoordinate2D)location{
    CLLocation *clLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    CLLocation *marsLocation = [clLocation locationMarsFromEarth];
    CLLocationCoordinate2D coordinate = [marsLocation coordinate];
    return coordinate;
}

//获取用户位置信息
-(void) getUserCurrentLocation:(LocationBlock) block location:(LocationSucessBlock) locationSucess;
{
    BOOL isDeviceOpen = [CLLocationManager locationServicesEnabled];
    if (!isDeviceOpen) {
        NSString *errorString = [WYUIUtils documentOfLocationDenied];//@"设备的定位未打开";
        if (block) {
            block(errorString);
        }
        [self notifyAllCallBack:errorString];
    }else{
        //定位服务出错callback，主要是为了区别用户把定位服务打开着，但是设备在启动定位时出错的情况
        if (block) {
            [_callbackArray addObject:[block copy]];
        }
        
        //获取位置成功的callback
        if (locationSucess) {
            [_sucessCallbackArray addObject:[locationSucess copy]];
        }
        
        if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_manager requestWhenInUseAuthorization];
        }
        if ([_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_manager requestAlwaysAuthorization];
        }
        [_manager startUpdatingLocation];
    }
}


//关闭
-(void) stopUpdatingUserLocation
{
    if (_manager ) {
        [_manager stopUpdatingLocation];
    }
}

//callback
-(void) notifyAllCallBack:(NSString *) errorString
{
    if (!_callbackArray.count) {
        return;
    }
    
    for (id block in _callbackArray) {
        ((LocationBlock)block)(errorString);
    }
    
    [_callbackArray removeAllObjects];
    [_sucessCallbackArray removeAllObjects];
}

//get location finished callback
-(void) notifyAllSucessCallBack:(CLLocation *) location
{
    if (!_sucessCallbackArray.count) {
        return;
    }
    
    for (id block in _sucessCallbackArray) {
        ((LocationSucessBlock)block)(location);
    }
    
    [_sucessCallbackArray removeAllObjects];
    [_callbackArray removeAllObjects];
    
}


-(void)placemarkReverseGeoLocation:(CLLocation *)location placemark:(ReverseGeoLocationSucessBlock)placemarkSucess
{
    if (_mRgeo) {
        [_mRgeo cancelGeocode];
        [self setMRgeo:nil];
    }
    
    if (placemarkSucess) {
        [_reverseSucessCallbackArray addObject:[placemarkSucess copy]];
    }
    
    _mRgeo = [[CLGeocoder alloc] init];
    __weak WYLocationServiceUtil *weakSelf = self;
    [_mRgeo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count && !error) {
            WYLog(@"didFindPlacemark: placemarks.count = %d, %@", (int)placemarks.count, placemarks);
        }else {
            WYLog(@"did not FindPlacemark, error = %@",error);
//            [WYProgressHUD AlertError:@"位置获取失败" At:weakSelf.view];
            return;
        }
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        WYLog(@"didFindPlacemark des: %@", placemark.description);
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (!weakSelf.reverseSucessCallbackArray.count) {
                return;
            }
            for (id block in weakSelf.reverseSucessCallbackArray) {
                ((ReverseGeoLocationSucessBlock)block)(placemark);
            }
            [weakSelf.reverseSucessCallbackArray removeAllObjects];
        });
    }];
}

- (NSString *)getStorePath{
    NSString *filePath = [PathHelper documentDirectoryPathWithName:@"location"];
    return filePath;
}
- (void)saveLastCLLocation:(CLLocation *)location{
    
    CLLocationCoordinate2D location2D = [location coordinate];
    NSMutableDictionary *locationDic = [NSMutableDictionary dictionaryWithCapacity:2];
    if (location2D.longitude) {
        [locationDic setObject:[NSNumber numberWithDouble:location2D.longitude] forKey:@"longitude"];
    }
    if (location2D.latitude) {
        [locationDic setObject:[NSNumber numberWithDouble:location2D.latitude] forKey:@"latitude"];
    }
    NSString* path = [[self getStorePath] stringByAppendingPathComponent:@"location.xml"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [locationDic writeToFile:path atomically:YES];
    });
}

+(CLLocationCoordinate2D)getLastRecordLocation{
    NSString* path = [[PathHelper documentDirectoryPathWithName:@"location"] stringByAppendingPathComponent:@"location.xml"];
    NSDictionary* locationDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    CLLocationCoordinate2D location;
    location.latitude = [[locationDic objectForKey:@"latitude"] doubleValue];
    location.longitude = [[locationDic objectForKey:@"longitude"] doubleValue];
    return location;
}

#pragma mark -- CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
    NSString *errorString;
    [manager stopUpdatingLocation];
    NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            //Access denied by user
            errorString = [WYUIUtils documentOfLocationDenied];//@"用户把程序定位关了";
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"启动定位服务失败";
            //Do something else...
            break;
        default:
            break;
    }
    
    [self notifyAllCallBack:errorString];
}

//6.0以后的回调
//获取到位置后，转成火星坐标，在地图上显示
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    if (locations.count) {
        //把标准坐标转成火星坐标返回
        CLLocation *marsLocation = [[locations objectAtIndex:0] locationMarsFromEarth];
        WYLog(@"mars location = %@", marsLocation);
        [self saveLastCLLocation:marsLocation];
        [self notifyAllSucessCallBack:marsLocation];
    }else{
        [self notifyAllCallBack:@"未获取到有效位置"];
    }
    
}

@end
