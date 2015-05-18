//
//  MapChooseViewController.h
//  Xiaoer
//
//  Created by KID on 15/1/20.
//
//

#import "WYSuperViewController.h"
#import  <MapKit/MapKit.h>

@protocol MapLocationSelected <NSObject>
@optional
//新解析接口中的解析地址为空,所以要把解析的原始坐标回传
-(void)didSelectMapLocationAt:(CLPlacemark *)place location:(CLLocationCoordinate2D) location;
@end

@interface MapChooseViewController : WYSuperViewController <MKMapViewDelegate>

@property (nonatomic, assign) BOOL bShowCurrent;
@property (nonatomic, assign) id<MapLocationSelected>selectDelegater;
@property (strong, nonatomic) IBOutlet UIView *mapContainerView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIImageView *floatingPin;
@property (strong, nonatomic) NSString* showPlaceTitle;
- (IBAction)sendPosition:(id)sender;


-(void)showCurrentLocation:(BOOL)bshow;
-(void)setCurrentLocation:(double)lat longitute:(double)log;

@end
