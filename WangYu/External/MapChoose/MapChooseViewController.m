//
//  MapChooseViewController.m
//  Xiaoer
//
//  Created by KID on 15/1/20.
//
//

#import "MapChooseViewController.h"
#import "WYProgressHUD.h"
#import "WYLocationServiceUtil.h"
#import "MapChooseAnnotationView.h"
#import "WYCommonUtils.h"
#import "WYActionSheet.h"
#import "WYAlertView.h"

@interface MapChooseViewController ()<CLLocationManagerDelegate>{
    WYActionSheet* _acsheet;
}

@property (nonatomic, retain)CLPlacemark* selectedPlace;
@property (nonatomic, assign)BOOL showMode;
@property (nonatomic, assign)CLLocationCoordinate2D showLocation;
@property (strong, nonatomic) CLGeocoder *mRgeo;
@property (nonatomic, assign)CLLocationCoordinate2D reseverLocation; // 当前解析的坐标
@property (nonatomic, assign)CLLocationCoordinate2D currentLocation; // 保存当前的坐标
@property (assign, nonatomic) BOOL bDisappear;
//用户去设置mapview的region的时候
@property (assign, nonatomic) BOOL isUserChangeRegion;
@property (assign, nonatomic) int istartloading;
@property (assign, nonatomic) int ichanged;
@property (assign, nonatomic) int iloadfirst;
//@property (strong, nonatomic) MBProgressHUD *hud;
@property (assign, nonatomic) BOOL isLoadingAnimation;
//@property (strong, nonatomic) CLGeocoder *mCLGeo;
//用户有没滑动，滑动后舍弃定位来的解析请求
@property (assign, nonatomic) BOOL isFlip;
//当前region是否在改变，用来判断加载的annotation是否要被丢弃
@property (assign, nonatomic) BOOL isCancle;
//当前位置是否显示（有时候解析好位置后在显示出来前，刚好地图加载完成导致解析好的数据不能显示在屏幕上）
@property (assign, nonatomic) BOOL isShowLoading;
@property (strong, nonatomic) UIButton*  backCurrentBtn;

@end

@implementation MapChooseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _bShowCurrent = NO;
        _showMode = NO;
        _isUserChangeRegion = NO;
        _isFlip = NO;
        _istartloading = 0;
        _ichanged = 0;
        _iloadfirst = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _bDisappear = NO;
    
//    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    if ([LSCommonUtils isUpperSDK]) {
//        frame = [UIScreen mainScreen].bounds;
//    }
//    CGRect mframe = self.mapContainerView.frame;
//    
//    mframe.size.height = frame.size.height - mframe.origin.y;
//    
//    self.mapContainerView.frame = mframe;
//    self.mapView.frame = self.mapContainerView.bounds;
//    CGRect fframe = self.floatingPin.frame;
//    fframe.origin.y = mframe.size.height/2 - fframe.size.height + 5;
//    fframe.origin.x += 7.3;
    
    self.floatingPin.image=[UIImage imageNamed:@"Pin_Ios7"];
    self.floatingPin.center = self.mapView.center;
    
    //默认先影藏
    self.floatingPin.hidden = YES;
    self.titleNavBarRightBtn.hidden = YES;
    
    if(_showMode){
        [self setTitle:@"位置信息"];
        [self updateAnnotationByLocation:_showLocation isNeedAnimation:NO];
    }
    
//    CLLocationManager *locationManager = [[CLLocationManager alloc] init];//创建位置管理器
//    locationManager.delegate=self;//设置代理
//    locationManager.desiredAccuracy=kCLLocationAccuracyBest;//指定需要的精度级别
//    locationManager.distanceFilter=1000.0f;//设置距离筛选器
//    [locationManager startUpdatingLocation];//启动位置管理器
    
    //在地图为加载前显示下在加载
//    _hud = [[MBProgressHUD alloc] initWithView:self.mapContainerView];
//    _hud.labelText = @"正在获取位置信息...";
//    [self.mapView addSubview:_hud];
//    [_hud show:YES];
    
    [WYProgressHUD AlertLoading:@"正在获取位置信息..." At:self.view];
//    _backCurrentBtn = [[UIButton alloc] init];
//    CGRect aframe = CGRectMake(11, self.mapView.bounds.size.height - 100, 40, 40);
//    _backCurrentBtn.frame = aframe;
//    
////    [_backCurrentBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back_no@2x.png"] forState:UIControlStateNormal];
//    [_backCurrentBtn setTitle:@"我的" forState:0];
//    [_backCurrentBtn addTarget:self action:@selector(backTOCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
//    _backCurrentBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    [self.mapView addSubview:_backCurrentBtn];
    
    
    //判断定位服务是否开启
    if (!_showMode) {
        __weak MapChooseViewController *weakself = self;
        LocationSucessBlock block = nil;
        if (_bShowCurrent) {
            block = ^(CLLocation *location) {
                if (weakself.bDisappear) {
                    return;
                }
                _currentLocation = location.coordinate;
                _iloadfirst = 1;
                if (!_isFlip) {
                    [weakself useNewReverseGeoLocation:location];
                }
            };
        }
        
        //获取用户位置
        [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
            //            NSLog(@"locationservice error :%@", errorString);
            [weakself hideProgressBar];
            if (errorString.length) {
                [weakself showAlter:errorString];
            }else{
                [weakself showAlter:@"启动定位服务失败"];
            }
        } location:block];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews
{
    [self setRightButtonWithTitle:@"路线" selector:@selector(sendPosition:)];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //定位
    self.mapView.delegate = self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - custom
-(void) addCustomMark:(CLLocationCoordinate2D)location
{
    MapChooseAnnotationView *annotation = [[MapChooseAnnotationView alloc] init];
    [annotation setCoordinate:location];
    annotation.title = @" ";
    NSString *detail = [NSString stringWithFormat:@"%f,%f",location.latitude,location.longitude];;
    annotation.subtitle = detail;
    [self.mapView addAnnotation:annotation];
    
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 250, 250);
//    [self.mapView setRegion:region animated:YES];
    
//    MKCoordinateRegion region = self.mapView.region;
//    region.center = location;
//    [self.mapView setRegion:region animated:YES];
    
//    [self.mapView setCenterCoordinate:location animated:YES];
    [self.mapView selectAnnotation:annotation animated:YES];
}

#pragma mark - old
-(void)backTOCurrentLocation{
    [self.backCurrentBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back"] forState:UIControlStateNormal];
    if (_currentLocation.longitude != 0 && _currentLocation.latitude != 0) {
        MKCoordinateRegion region = self.mapView.region;
        region.center = self.currentLocation;
        [self.mapView setRegion:region];
    }else{
        __weak MapChooseViewController *weakSelf = self;
        [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString){
            if (errorString.length) {
                [weakSelf showAlter:errorString];
            }else{
                [weakSelf showAlter:@"启动定位服务失败"];
            }
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

//提示错误
-(void) showAlter:(NSString *) errorString
{
    __weak MapChooseViewController *weakSelf = self;
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:errorString cancelButtonTitle:@"确认" cancelBlock:^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertView show];
}

-(void)showCurrentLocation:(BOOL)bshow
{
    _bShowCurrent = bshow;
}

-(void)setCurrentLocation:(double)lat longitute:(double)log
{
    _showMode = YES;
    CLLocationCoordinate2D location;
//    location.latitude = 30.189734;
//    location.longitude = 120.154937;
    location.latitude = lat;
    location.longitude = log;
    
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
    
    
    _iloadfirst = 1;
    _ichanged = 1;
    _showLocation = location;
//    [self getCurrentCity:location];
    //todo update map view;
    
}

- (IBAction)sendPosition:(id)sender {
    if (_showMode) {
        NSString* sheetTitle = @"导航";
        if (self.showPlaceTitle && [self.showPlaceTitle length] > 0) {
            sheetTitle = [NSString stringWithFormat:@"导航到 %@ 的位置",self.showPlaceTitle];
        }
        
        __weak MapChooseViewController *weakSelf = self;
        //        LSActionSheet *sheet = [[LSActionSheet alloc] initWithTitle:sheetTitle actionBlock:^(NSInteger buttonIndex) {
        //            [weakSelf doActionSheetWithButtonIndex:buttonIndex];
        //        } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"百度地图",@"高德地图", @"苹果地图", nil];
        _acsheet = [[WYActionSheet alloc] initWithTitle:sheetTitle actionBlock:^(NSInteger buttonIndex) {
            [weakSelf doActionSheetWithButtonIndex:buttonIndex];
        }cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
//        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
//            [_acsheet addButtonWithTitle:@"百度地图"];
//        }
        
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
    
    
    if([_selectDelegater respondsToSelector:@selector(didSelectMapLocationAt:location:)]){
        [_selectDelegater didSelectMapLocationAt:_selectedPlace location:_reseverLocation];
    }
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)doActionSheetWithButtonIndex:(NSInteger)buttonIndex{
    
//    NSLog(@"0702 buttonIndex is %d\n\n",buttonIndex);
    if (_currentLocation.longitude == 0 && _currentLocation.latitude == 0) {
        __weak MapChooseViewController *weakSelf = self;
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_mRgeo) {
        [_mRgeo cancelGeocode];
        [self setMRgeo:nil];
    }
    _bDisappear = YES;
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

-(void)dealloc
{
    //    NSLog(@"dealloc mapchoose");
    self.mapView.delegate = nil;
    [self setMapView:nil];
    [self setFloatingPin:nil];
    self.selectedPlace = nil;
    [self setMapContainerView:nil];
    [self setMRgeo:nil];
    //    [self setMCLGeo:nil];
}

-(void)updateAnnotationByLocation:(CLLocationCoordinate2D)location isNeedAnimation:(BOOL) isAnimation
{
    //    NSLog(@"updateAnnotationByLocation: %f", location.latitude);
    //    ichanged = 0;
    
    if(_iloadfirst == 0)
        return;
    
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    
    if (isAnimation) {
        [self loadAnnotation:location];
    }
    
    //    if (location.longitude == self.selectedPlace.coordinate.longitude
    //        && location.latitude == self.selectedPlace.coordinate.latitude) {
    ////        return;
    //    }
    [self getCurrentCity:location];
    
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
    if (!_bDisappear) {
        _reseverLocation = location;
        //        CLLocation *clocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        CLLocation *clocation = [[CLLocation alloc] initWithCoordinate:location altitude:0 horizontalAccuracy:kCLLocationAccuracyNearestTenMeters verticalAccuracy:kCLLocationAccuracyNearestTenMeters timestamp:nil];
        __weak MapChooseViewController *weakSelf = self;
        [_mRgeo reverseGeocodeLocation:clocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (placemarks.count && !error) {
                [WYProgressHUD AlertLoadDone];
                //                NSLog(@"didFindPlacemark: placemarks.count = %d, %@", placemarks.count, placemarks);
            }else {
//                [weakSelf addCustomMark:location];//test
                _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
                NSLog(@"did not FindPlacemark, error = %@",error);
                [WYProgressHUD AlertError:@"位置获取失败" At:weakSelf.view];
                return;
            }
            //    NSLog(@"didFindPlacemark des: %@", placemark.description);
            //            NSLog(@"ichanged: %d, istartloading:%d", weakSelf.ichanged, weakSelf.istartloading);
            if (weakSelf.bDisappear) {
                _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
                return;
            }
            if(weakSelf.ichanged == 0 || weakSelf.istartloading == 1)
            {
                _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
                return;
            }
            weakSelf.ichanged = 0;
            weakSelf.isCancle = YES;
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAnnotationAt:[placemarks objectAtIndex:0]];
            //            });
        }];
    }
}


-(void)useNewReverseGeoLocation:(CLLocation *)location
{
    if (_mRgeo) {
        [_mRgeo cancelGeocode];
        [self setMRgeo:nil];
    }
    
    _mRgeo = [[CLGeocoder alloc] init];
    if (!_bDisappear) {
        _reseverLocation = location.coordinate;
        //        CLLocation *clocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        __weak MapChooseViewController *weakSelf = self;
        [_mRgeo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {            if (placemarks.count && !error) {
            //                NSLog(@"didFindPlacemark: placemarks.count = %d, %@", placemarks.count, placemarks);
        }else {
            _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
            //                NSLog(@"did not FindPlacemark, error = %@",error);
            [WYProgressHUD AlertError:@"位置获取失败" At:weakSelf.view];
            return;
        }
            //    NSLog(@"didFindPlacemark des: %@", placemark.description);
            //            NSLog(@"ichanged: %d, istartloading:%d", weakSelf.ichanged, weakSelf.istartloading);
            if (weakSelf.bDisappear) {
                _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
                return;
            }
            //            if(weakSelf.ichanged == 0 || weakSelf.istartloading == 1)
            //            {
            //                _reseverLocation = CLLocationCoordinate2DMake(-180, -180);
            //                return;
            //            }
            weakSelf.ichanged = 0;
            weakSelf.isCancle = YES;
            //            dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf showAnnotationAt:[placemarks objectAtIndex:0]];
            //            });
        }];
    }
}

-(void)showAnnotationAt:(CLPlacemark*) place
{
    if (-180 == _reseverLocation.latitude && -180 == _reseverLocation.longitude) {
        return;
    }
    
    //    iloadfirst++;
    self.selectedPlace = place;
    CLLocationCoordinate2D location = _reseverLocation;  //place.location.coordinate (0,0)
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    //    DDAnnotation *annotation = [[[DDAnnotation alloc] initWithCoordinate:location addressDictionary:nil] autorelease];
    
    //    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
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
    if(_iloadfirst == 1)
    {
        _iloadfirst++;
        region.span.longitudeDelta = 0.01;
        region.span.latitudeDelta = 0.01;
    }
    // Add point (not placemark) to the mapView
    _isUserChangeRegion = YES;
    [self.mapView setRegion:region animated:NO];
    [self.mapView selectAnnotation:annotation animated:NO];
    _isUserChangeRegion = NO;
    self.floatingPin.hidden = YES;
    if (!_showMode) {
        self.titleNavBarRightBtn.hidden = NO;
    }else{
        self.titleNavBarRightBtn.hidden = NO;
        [self.titleNavBarRightBtn setTitle:@"路线" forState:UIControlStateNormal];
    }
    _isShowLoading = NO;
    [self hideProgressBar];
}

#pragma MKMapViewDelegate
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
        draggablePinView.image=[UIImage imageNamed:@"Pin_Ios7.png"];
        if (isMapAn) {
            draggablePinView.leftCalloutAccessoryView =  [self isNeedAddIndicatorView:annotation];
        }
    }
    
    return draggablePinView;
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

-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView1
{
    NSLog(@"mapViewWillStartLoadingMap \n");
    if (_bDisappear) {
        return;
    }
    if(_showMode)
        return;
    //     [mapView removeAnnotations:mapView1.annotations];
    
    if (_iloadfirst > 0) {
        //        self.floatingPin.hidden = NO;
    }
    _istartloading = 1;
    _ichanged = 1;
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView1
{
    NSLog(@"mapViewDidFinishLoadingMap \n");
    if (_bDisappear) {
        return;
    }
    
    if(_showMode)
        return;
    _istartloading = 0;
    if(_ichanged == 1 && _iloadfirst >1 && _isShowLoading)
        //    if(iloadfirst >1)
    {
        [self updateAnnotationByLocation:mapView1.centerCoordinate isNeedAnimation:NO];
    }
}

-(void) loadAnnotation:(CLLocationCoordinate2D)location
{
//    if (self.floatingPin.hidden || _isLoadingAnimation) {
//        return;
//    }
    
    CGRect frame = self.floatingPin.frame;
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        _isLoadingAnimation = YES;
        self.floatingPin.frame = CGRectMake(frame.origin.x, frame.origin.y - 20, frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
        self.floatingPin.frame = frame;
        _isLoadingAnimation = NO;
        //添加一个mark上面是loading的view
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //        NSLog(@"loadAnnotation isCancle = %d",_isCancle);
        if (!_isCancle) {
            [self addLoadingEmptyMark:location];
        }
        //        });
    }];
}

-(void) addLoadingEmptyMark:(CLLocationCoordinate2D)location
{
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    MapChooseAnnotationView *annotation = [[MapChooseAnnotationView alloc] init];
    annotation.isShowIndicator = YES;
    [annotation setCoordinate:location];
    annotation.title = @" ";
    NSString *detail = @" ";
    annotation.subtitle = detail;
    [self.mapView addAnnotation:annotation];
    MKCoordinateRegion region = self.mapView.region;
    region.center = location;
    if(_iloadfirst == 1)
    {
        _iloadfirst++;
        region.span.longitudeDelta = 0.01;
        region.span.latitudeDelta = 0.01;
    }
    // Add point (not placemark) to the mapView
    _isUserChangeRegion = YES;
    [self.mapView setRegion:region animated:NO];
    [self.mapView selectAnnotation:annotation animated:NO];
    _isUserChangeRegion = NO;
    _isShowLoading = YES;
}

-(void)mapView:(MKMapView *)mapView1 regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"regionWillChangeAnimated \n");
    if (_bDisappear || _showMode || _isUserChangeRegion) {
        return;
    }
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    if (_iloadfirst > 0) {
        self.floatingPin.hidden = NO;
        _isFlip = YES;
    }
    _ichanged = 0;
    _istartloading = 0;
    _isCancle = YES;
}

- (void)mapView:(MKMapView *)mapView1 regionDidChangeAnimated:(BOOL)animated
{
    //判断是否在当前位置，改变按钮-返回当前位置的图标
    CLLocationCoordinate2D location = mapView1.centerCoordinate;
    long changeLat = fabs((_currentLocation.latitude - location.latitude)*50000);
    long changeLong = fabs((_currentLocation.longitude - location.longitude)*20000);
    
    if (changeLat == 0 && changeLong == 0) {
        //        return;
    }else{
        [_backCurrentBtn setBackgroundImage:[UIImage imageNamed:@"s_location_back_no"] forState:UIControlStateNormal];
    }
    
    //    NSLog(@"regionDidChangeAnimated \n");
    if (_bDisappear || _showMode || _isUserChangeRegion) {
        return;
    }
    _ichanged = 1;
    
    for (id<MKAnnotation> annotion in [self.mapView annotations]) {
        if (annotion == nil) {
            return;
        }
        if (![annotion isKindOfClass:[MKUserLocation class]]) {
            [self.mapView removeAnnotation:annotion];
        }
    }
    //    if(istartloading == 0)
    _isCancle = NO;
    [self updateAnnotationByLocation:mapView1.centerCoordinate isNeedAnimation:YES];
}

-(void)mapViewDidStopLocatingUser:(MKMapView *)mapView
{
}

@end
