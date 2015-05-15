//
//  NetbarMapViewController.m
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarMapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WYLocationServiceUtil.h"
#import "WYAlertView.h"
#import "WYProgressHUD.h"
#import "WYEngine.h"


@interface WYMapPlaceMark : NSObject<MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, copy) NSString *addressPoiid;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end

@implementation WYMapPlaceMark

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

@end


@interface NetbarMapViewController ()<MKMapViewDelegate>

@property (strong, nonatomic) NSMutableArray *pois;
@property (nonatomic, strong) NSArray* annotations;

@property (strong, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (strong, nonatomic) UIButton* currentLocationBtn;

@end

@implementation NetbarMapViewController

-(void)dealloc{
    _mapView.delegate = nil;
    _mapView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [WYEngine shareInstance].uid = @"21";
    [WYEngine shareInstance].token = @"sZsSuV+5U9eJakz3JLmqNQ==";
    
    
    
    
    self.mapView.delegate = self;
    
    [WYProgressHUD AlertLoading:@"定位中..."];
    
    _currentLocationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    CGRect frame = CGRectMake(11, self.mapView.bounds.size.height - 51, 40, 40);
    _currentLocationBtn.frame = frame;
    
    [_currentLocationBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back_no"] forState:UIControlStateNormal];
    [_currentLocationBtn addTarget:self action:@selector(backTOCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    _currentLocationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.mapView addSubview:_currentLocationBtn];
    
    if (_location.longitude == 0 && _location.latitude == 0) {
        [self refreshLocation];
    } else {
        [self refreshData];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews
{
    [self setTitle:@"附近网吧"];
}

- (void)backAction:(id)sender{
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)refreshData{
    
    if (_location.longitude == 0 && _location.latitude == 0) {
        _location = self.mapView.userLocation.coordinate;
        if (_location.longitude == 0 && _location.latitude == 0) {
            return;
        }
    }
    
    int tag = [[WYEngine shareInstance] getConnectTag];
    
    if ((_location.longitude > -180 || _location.longitude < 180) && (_location.latitude > -90 || _location.latitude < 90)) {
        
        [[WYEngine shareInstance] searchMapNetbarWithUid:[WYEngine shareInstance].uid city:@"杭州" latitude:_location.latitude longitude:_location.longitude tag:tag];
        
        MKCoordinateRegion theRegion;
        MKCoordinateSpan theSpan;
        theSpan.latitudeDelta = 0.01f;
        theSpan.longitudeDelta = 0.01f;
        theRegion.center = _location;
        theRegion.span = theSpan;
        
        [self.mapView setRegion:theRegion animated:YES];
    }else{
        return;
    }
    
    WS(weakSelf);
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"完成" At:weakSelf.view];
        
        NSArray* pois = [jsonRet arrayObjectForKey:@"object"];
        _pois = [[NSMutableArray alloc] initWithArray:pois];
        
        
        if (self.annotations) {
            [self.mapView removeAnnotations:self.annotations];
        }
        
        NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:_pois.count];
        for (NSDictionary* dic in _pois) {
            WYMapPlaceMark* placeMark = [[WYMapPlaceMark alloc] init];
            placeMark.title = @"网吧信息";
            placeMark.subtitle = [[dic objectForKey:@"netbar_name"] description];
//            placeMark.addressPoiid = [[dic objectForKey:@"poiid"] description];
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[dic objectForKey:@"latitude"] doubleValue];
            coordinate.longitude = [[dic objectForKey:@"longitude"] doubleValue];
            placeMark.coordinate = coordinate;
            [annotations addObject:placeMark];
        }
        self.annotations = annotations;
        [self.mapView addAnnotations:annotations];
        [self.mapView selectAnnotation:[annotations objectAtIndex:0] animated:YES];
        
    } tag:tag];
}

#pragma mark - custom
-(void)backTOCurrentLocation{
    [self.currentLocationBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back"] forState:UIControlStateNormal];
    if (_currentLocation.longitude != 0 && _currentLocation.latitude != 0) {
        MKCoordinateRegion region = self.mapView.region;
        region.center = self.currentLocation;
        [self.mapView setRegion:region];
    }else{
        __weak NetbarMapViewController *weakSelf = self;
        [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString){
            
        } location:^(CLLocation *location) {
            weakSelf.currentLocation = [location coordinate];//当前经纬
            MKCoordinateRegion region = weakSelf.mapView.region;
            region.center = weakSelf.currentLocation;
            [weakSelf.mapView setRegion:region];
        }];
    }
    
}

//隐藏进度条
-(void) hideProgressBar
{
    [WYProgressHUD AlertLoadDone];
}

-(void) showAlter:(NSString *) errorString
{
    __weak NetbarMapViewController *weakSelf = self;
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:errorString cancelButtonTitle:@"确认" cancelBlock:^{
        [weakSelf backAction:nil];
    }];
    
    [alertView show];
}

#pragma mark -- 定位
-(void) refreshLocation
{
    [self getCurrentLocation];
}

-(void)getCurrentLocation{
    //获取当前位置
    __weak NetbarMapViewController *weakself = self;
    LocationSucessBlock block = nil;
    block = ^(CLLocation *location) {
        
        weakself.currentLocation = [location coordinate];
        if(fabs(weakself.location.latitude) > 0 && fabs(weakself.location.longitude)){
            //有经纬度时，直接返回
            return;
        }
        weakself.location = [location coordinate];
//        [weakself useNewReverseGeoLocation:location];
        [weakself refreshData];
    };
    [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
        
        [weakself hideProgressBar];
        if (errorString.length) {
            [weakself showAlter:errorString];
        }else{
            [weakself showAlter:@"启动定位服务失败"];
        }
    } location:block];
    
}

#pragma mark - MKMapViewDelegate
-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView1
{
    WYLog(@"mapViewWillStartLoadingMap \n");
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView1
{
    WYLog(@"mapViewDidFinishLoadingMap \n");
}

- (void)mapView:(MKMapView *)mapView1 regionDidChangeAnimated:(BOOL)animated
{
    WYLog(@"regionDidChangeAnimated \n");
    
    //判断是否在当前位置，改变按钮图标
    CLLocationCoordinate2D location = mapView1.centerCoordinate;
    long changeLat = fabs((_currentLocation.latitude - location.latitude)*50000);
    long changeLong = fabs((_currentLocation.longitude - location.longitude)*20000);
    
    if (changeLat != 0 || changeLong != 0) {
        [_currentLocationBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back_no"] forState:UIControlStateNormal];
    }
    
//    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
//        if (annotion == nil) {
//            return;
//        }
//        if (![annotion isKindOfClass:[MKUserLocation class]]) {
//            [self.mapView removeAnnotation:annotion];
//        }
//    }
}

@end
