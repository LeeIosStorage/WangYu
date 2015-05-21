//
//  WYLocationServiceUtil.h
//  WangYu
//
//  Created by KID on 15/5/14.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class CLLocation;
typedef void(^LocationBlock)(NSString *errorString);
typedef void(^LocationSucessBlock)(CLLocation *location);

typedef void(^ReverseGeoLocationSucessBlock)(CLPlacemark *placemark);

@interface WYLocationServiceUtil : NSObject

+(WYLocationServiceUtil *) shareInstance;

//简单判断定位服务是否开启
+(BOOL) isLocationServiceOpen;

//转化为火星坐标
+(CLLocationCoordinate2D)convertNewCoordinateWith:(CLLocationCoordinate2D)location;
//获取上次地位时记录的经纬度
+(CLLocationCoordinate2D)getLastRecordLocation;

//经纬度反解码地址信息
-(void)placemarkReverseGeoLocation:(CLLocation *)location placemark:(ReverseGeoLocationSucessBlock)placemarkSucess;

//获取用户地址
-(void) getUserCurrentLocation:(LocationBlock) block location:(LocationSucessBlock) locationSucess;

@end
