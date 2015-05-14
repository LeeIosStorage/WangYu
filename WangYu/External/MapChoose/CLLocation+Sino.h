//
//  CLLocation+Sino.h
//  Xiaoer
//
//  Created by KID on 15/1/20.
//
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (Sino)
- (CLLocation*)locationMarsFromEarth;

- (CLLocation*)locationBearPawFromMars;
- (CLLocation*)locationMarsFromBearPaw;
@end
