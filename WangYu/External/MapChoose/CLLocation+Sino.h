//
//  CLLocation+Sino.h
//  Xiaoer
//
//  Created by KID on 15/1/20.
//
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Sino)
- (CLLocation*)locationMarsFromEarth;//标准坐标转成火星坐标

- (CLLocation*)locationBearPawFromMars;//GCJ-02(火星坐标)坐标转换成 BD-09(百度坐标)坐标
- (CLLocation*)locationMarsFromBearPaw;//BD-09(百度坐标)坐标转换成 GCJ-02(火星坐标)坐标
@end
