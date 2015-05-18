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
#import "WYActionSheet.h"
#import "WYProgressHUD.h"
#import "WYEngine.h"
#import "MapChooseAnnotationView.h"
#import "CLLocation+Sino.h"

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


@interface NetbarMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
{
    WYActionSheet* _acsheet;
}
@property (strong, nonatomic) NSMutableArray *pois;
@property (nonatomic, strong) NSArray* annotations;

@property (strong, nonatomic) IBOutlet UIView *mainContainerView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) UIButton* currentLocationBtn;


@property (nonatomic, assign) BOOL showMode;//YES 定位具体某个位置
@property (nonatomic, assign) CLLocationCoordinate2D showLocation;
@property (strong, nonatomic) CLGeocoder *mRgeo;
@property (nonatomic, assign) CLLocationCoordinate2D reseverLocation; // 当前解析的坐标

@end

@implementation NetbarMapViewController

-(void)dealloc{
    _mapView.delegate = nil;
    _mapView = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_mRgeo) {
        [_mRgeo cancelGeocode];
        [self setMRgeo:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [WYEngine shareInstance].uid = @"21";
    [WYEngine shareInstance].token = @"sZsSuV+5U9eJakz3JLmqNQ==";
    
    
    
    self.titleNavBarRightBtn.hidden = YES;
    self.mapView.delegate = self;
    
    _currentLocationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    CGRect frame = CGRectMake(11, self.mapView.bounds.size.height - 51, 40, 40);
    _currentLocationBtn.frame = frame;
    
    [_currentLocationBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back_no"] forState:UIControlStateNormal];
    [_currentLocationBtn addTarget:self action:@selector(backTOCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    _currentLocationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.mapView addSubview:_currentLocationBtn];
    
    if(_showMode){
//        [WYProgressHUD AlertLoading:@"正在获取位置信息..." At:self.view];
        [self setTitle:@"位置信息"];
        [self updateAnnotationByLocation:_showLocation isNeedAnimation:NO];
    }else{
        [WYProgressHUD AlertLoading:@"定位中..."];
        if (_location.longitude == 0 && _location.latitude == 0) {
            [self refreshLocation];
        } else {
            [self refreshData];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews
{
    [self setTitle:@"附近网吧"];
    [self setRightButtonWithTitle:@"路线" selector:@selector(sendPosition:)];
}

- (void)backAction:(id)sender{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
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
            
            coordinate = [WYLocationServiceUtil convertNewCoordinateWith:coordinate];
            
            placeMark.coordinate = coordinate;
            [annotations addObject:placeMark];
        }
        self.annotations = annotations;
        [self.mapView addAnnotations:annotations];
        if (annotations.count > 0) {
            [self.mapView selectAnnotation:[annotations objectAtIndex:0] animated:YES];
        }
        
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

#pragma mark - 定位具体某个位置
-(void)setShowLocation:(double)lat longitute:(double)log{
    _showMode = YES;
    
    CLLocationCoordinate2D location;
    location.latitude = lat;
    location.longitude = log;
    
    location = [WYLocationServiceUtil convertNewCoordinateWith:location];
    
    //要保证小数点八位以上的精度，不然有可能会解析不到位置信息
    NSMutableString* strLat = [NSMutableString stringWithString:[[NSNumber numberWithDouble:location.latitude] description]];
    NSMutableString* strLon = [NSMutableString stringWithString:[[NSNumber numberWithDouble:location.longitude] description]];
    if ([strLat rangeOfString:@"."].location != NSNotFound) {
        NSString* temp = [[strLat componentsSeparatedByString:@"."] objectAtIndex:1];
        for(int i = (int)temp.length; i < 8; ++i) {
            [strLat appendString:@"0"];
        }
        location.latitude = [strLat doubleValue];
    }
    if ([strLon rangeOfString:@"."].location != NSNotFound) {
        NSString* temp = [[strLon componentsSeparatedByString:@"."] objectAtIndex:1];
        for(int i = (int)temp.length; i < 8; ++i) {
            [strLon appendString:@"0"];
        }
        location.longitude = [strLon doubleValue];
    }
    
    _showLocation = location;
}

-(void)updateAnnotationByLocation:(CLLocationCoordinate2D)location isNeedAnimation:(BOOL) isAnimation
{
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    
    [self getCurrentCity:location];
//    [self addCustomMark:location];
    
}
-(void)getCurrentCity:(CLLocationCoordinate2D)location
{
    [self useNewReverseGeo:location];
}

-(void)useNewReverseGeo:(CLLocationCoordinate2D)location
{
    if (_mRgeo) {
        [_mRgeo cancelGeocode];
        [self setMRgeo:nil];
    }
    
    _mRgeo = [[CLGeocoder alloc] init];
    _reseverLocation = location;
    CLLocation *clocation = [[CLLocation alloc] initWithCoordinate:location altitude:0 horizontalAccuracy:kCLLocationAccuracyNearestTenMeters verticalAccuracy:kCLLocationAccuracyNearestTenMeters timestamp:nil];
    __weak NetbarMapViewController *weakSelf = self;
    [_mRgeo reverseGeocodeLocation:clocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks.count && !error) {
            [WYProgressHUD AlertLoadDone];
        }else {
            [weakSelf addCustomMark:location];
            _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
            NSLog(@"did not FindPlacemark, error = %@",error);
            [WYProgressHUD AlertError:@"位置获取失败" At:weakSelf.view];
            return;
        }
        [weakSelf showAnnotationAt:[placemarks objectAtIndex:0]];
    }];
}
-(void)showAnnotationAt:(CLPlacemark*) place
{
    if (-180 == _reseverLocation.latitude && -180 == _reseverLocation.longitude) {
        return;
    }
    
    CLLocationCoordinate2D location = _reseverLocation;  //place.location.coordinate (0,0)
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    
    MapChooseAnnotationView *annotation = [[MapChooseAnnotationView alloc] init];
    annotation.isShowIndicator = NO;
    [annotation setCoordinate:location];
    annotation.title = @"位置信息";
    
    NSString *detail = place.name;
    if ([detail rangeOfString:@","].length) {
        annotation.subtitle = [detail substringFromIndex:[detail rangeOfString:@","].location + 1];
    }else{
        annotation.subtitle = detail;
    }
    
    //    NSLog(@"annotation.subTitle = %@", annotation.subtitle);
    
    //	annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    [self.mapView addAnnotation:annotation];
    MKCoordinateRegion region = self.mapView.region;
    region.center = location;
    region.span.longitudeDelta = 0.01;
    region.span.latitudeDelta = 0.01;
    
    [self.mapView setRegion:region animated:NO];
    [self.mapView selectAnnotation:annotation animated:NO];
    if (!_showMode) {
        self.titleNavBarRightBtn.hidden = NO;
    }else{
        self.titleNavBarRightBtn.hidden = NO;
        [self.titleNavBarRightBtn setTitle:@"路线" forState:UIControlStateNormal];
    }
    [self hideProgressBar];
}

-(void) addCustomMark:(CLLocationCoordinate2D)location
{
    self.titleNavBarRightBtn.hidden = NO;
    [self.titleNavBarRightBtn setTitle:@"路线" forState:UIControlStateNormal];
    
    MapChooseAnnotationView *annotation = [[MapChooseAnnotationView alloc] init];
    [annotation setCoordinate:location];
    annotation.title = _netbarName;
    NSString *detail = _showPlaceTitle;
    annotation.subtitle = detail;
    [self.mapView addAnnotation:annotation];
    
    MKCoordinateRegion region = self.mapView.region;
    region.center = location;
    region.span.longitudeDelta = 0.01;
    region.span.latitudeDelta = 0.01;
    
    [self.mapView setRegion:region animated:YES];
    
    [self.mapView selectAnnotation:annotation animated:YES];
}

- (IBAction)sendPosition:(id)sender {
    if (_showMode) {
        NSString* sheetTitle = @"导航";
        if (self.showPlaceTitle && [self.showPlaceTitle length] > 0) {
            sheetTitle = [NSString stringWithFormat:@"导航到 %@ 的位置",self.showPlaceTitle];
        }
        
        __weak NetbarMapViewController *weakSelf = self;
        //        LSActionSheet *sheet = [[LSActionSheet alloc] initWithTitle:sheetTitle actionBlock:^(NSInteger buttonIndex) {
        //            [weakSelf doActionSheetWithButtonIndex:buttonIndex];
        //        } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"百度地图",@"高德地图", @"苹果地图", nil];
        _acsheet = [[WYActionSheet alloc] initWithTitle:sheetTitle actionBlock:^(NSInteger buttonIndex) {
            [weakSelf doActionSheetWithButtonIndex:buttonIndex];
        }cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
            [_acsheet addButtonWithTitle:@"百度地图"];
        }
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            [_acsheet addButtonWithTitle:@"高德地图"];
        }
        
        //        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        //            [_acsheet addButtonWithTitle:@"苹果地图"];
        //        }
        [_acsheet addButtonWithTitle:@"苹果地图"];
        [_acsheet addButtonWithTitle:@"取消"];
        _acsheet.cancelButtonIndex = _acsheet.numberOfButtons -1;
        
        //        if (_acsheet.numberOfButtons == 1) {
        //            _acsheet = nil;//
        //            return;
        //        }
        
        [_acsheet showInView:self.view];
        return;
    }
    
//    if (self.navigationController) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [self dismissViewControllerAnimated:YES completion:^{
//            
//        }];
//    }
}

- (void)doActionSheetWithButtonIndex:(NSInteger)buttonIndex{
    
    //    NSLog(@"0702 buttonIndex is %d\n\n",buttonIndex);
    if (_currentLocation.longitude == 0 && _currentLocation.latitude == 0) {
        __weak NetbarMapViewController *weakSelf = self;
        [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString){
            
            if (errorString.length) {
                [weakSelf showAlter:errorString];
            }else{
                [weakSelf showAlter:@"启动定位服务失败"];
            }
        } location:^(CLLocation *location) {
            
            weakSelf.currentLocation = [location coordinate];//当前经纬
            [weakSelf userOtherMap:buttonIndex];
        }];
    }else{
        [self userOtherMap:buttonIndex];
    }
    
    
}

- (void)userOtherMap:(NSInteger)buttonIndex{
    if (!_acsheet) {
        return;
    }
    
    NSString* urlString = nil;
    NSString* tipString = nil;
    
    NSString* buttonTitle = [_acsheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"百度地图"]) {
        NSString* souceLat = [NSString stringWithString:[[NSNumber numberWithDouble:_currentLocation.latitude] description]];
        NSString* souceLong = [NSString stringWithString:[[NSNumber numberWithDouble:_currentLocation.longitude] description]];
        NSString* desLat = [NSString stringWithString:[[NSNumber numberWithDouble:_showLocation.latitude] description]];
        NSString* desLong = [NSString stringWithString:[[NSNumber numberWithDouble:_showLocation.longitude] description]];
        urlString = [NSString stringWithFormat:@"baidumap://map/direction?origin=%@,%@&destination=%@,%@&mode=driving&src=Xiaoer&coord_type=gcj02",souceLat,souceLong,desLat,desLong];
        tipString = @"您还未安装百度地图";
    }else if ([buttonTitle isEqualToString:@"高德地图"]){
        //style  导航方式：(=0：速度最快，=1：费用最少，=2：距离最短，=3：不走高速，=4：躲避拥堵，=5：不走高速且避免收费，=6：不走高速且躲避拥堵，=7：躲避收费和拥堵，=8：不走高速躲避收费和拥堵)
        urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=Xiaoer&backScheme=Xiaoer://&lat=%f&lon=%f&dev=1&style=2",_showLocation.latitude,_showLocation.longitude];
        //poiname=fangheng&poiid=BGVIS&
        tipString = @"您还未安装高德地图";
    }else if ([buttonTitle isEqualToString:@"苹果地图"]){
        tipString = @"地址不正确";
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) { // ios6以下，调用google map
            urlString = [[NSString alloc]
                         initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",
                         _currentLocation.latitude,_currentLocation.longitude,_showLocation.latitude,_showLocation.longitude];
        }else{
            //调用apple 地图客户端
            CLLocationCoordinate2D to;
            to.latitude = _showLocation.latitude;
            to.longitude = _showLocation.longitude;
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil] ];
            if (_showPlaceTitle && [_showPlaceTitle length] > 0) {
                toLocation.name = _showPlaceTitle;
            }else{
                toLocation.name = @"目的地/Destination";
            }
            
            [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
            return;
            
        }
        
    }else{
        return;
    }
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:urlString]];
    }
    else{
        //        [LSUIUtils showCommonTip:tipString At:self.mapView];
        [WYProgressHUD lightAlert:tipString];
        NSLog(@"0702 %@\n",tipString);
    }
    
}

//判断是否要显示indicator
-(UIView *) isNeedAddIndicatorView:(id<MKAnnotation>)annotation
{
    UIView *goalView = nil;
    MapChooseAnnotationView * mapAnnotation = (MapChooseAnnotationView *) annotation;
    if (mapAnnotation.isShowIndicator) {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.frame = CGRectMake(15, 0, 30, 30);
        [indicator startAnimating];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray ;
        indicator.center = CGPointMake(38, 15);
        goalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
        [goalView addSubview:indicator];
    }
    
    return goalView;
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    BOOL isMapAn = [annotation isKindOfClass:[MapChooseAnnotationView class]];
    static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
    MKAnnotationView *draggablePinView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
    if (draggablePinView) {
        if (isMapAn) {
            draggablePinView.leftCalloutAccessoryView = [self isNeedAddIndicatorView:annotation];
        }
        draggablePinView.annotation = annotation;
    } else {
        draggablePinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
        draggablePinView.canShowCallout = YES;
        draggablePinView.userInteractionEnabled = NO;
        draggablePinView.draggable = NO;
        draggablePinView.image=[UIImage imageNamed:@"Pin_Ios7"];
        if (isMapAn) {
            draggablePinView.leftCalloutAccessoryView =  [self isNeedAddIndicatorView:annotation];
        }
    }
    
    return draggablePinView;
}

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
