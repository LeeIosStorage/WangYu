//
//  NetbarTabViewController.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarTabViewController.h"
#import "WYTabBarViewController.h"
#import "WYEngine.h"
#import "NetbarTabCell.h"
#import "SKSplashView.h"
#import "SKSplashIcon.h"
#import "NetbarDetailViewController.h"
#import "WYProgressHUD.h"
#import "WYNetbarInfo.h"
#import "OrdersViewController.h"
#import "NetbarSearchViewController.h"
#import "WYLocationServiceUtil.h"
#import "WYAlertView.h"
#import "LocationViewController.h"
#import "NetbarMapViewController.h"
#import <MapKit/MapKit.h>
#import "LocationViewController.h"
#import "WYLinkerHandler.h"
#import "WYUserGuideConfig.h"
#import "AppDelegate.h"
#import "WYSettingConfig.h"

@interface NetbarTabViewController ()<UITableViewDataSource,UITableViewDelegate,SKSplashDelegate,NetbarTabCellDelegate,LocationViewControllerDelegate>
{
    NSString *_chooseCityName;
    NSString *_chooseAreaCode;
    UIImageView *_chooseCityIconImgView;
    
    NSString *_currentLocationLocality;
    
    BOOL _isOpen;
    UIButton *_bgMarkButtonView;
    LocationViewController *_locationChooseVc;
}
@property (strong, nonatomic) IBOutlet UILabel *orderLabel;
@property (strong, nonatomic) IBOutlet UILabel *packetLabel;
@property (strong, nonatomic) IBOutlet UIImageView *weekRedBagIconImgView;
@property (strong, nonatomic) IBOutlet UILabel *bookLabel;
@property (strong, nonatomic) IBOutlet UILabel *bookDecLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotLabel;
@property (strong, nonatomic) IBOutlet UILabel *guessLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UITableView *netBarTable;
@property (strong, nonatomic) SKSplashView *splashView;
@property (strong, nonatomic) IBOutlet UIView *guideView;
@property (strong, nonatomic) IBOutlet UIView *guideImageView;

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIButton *moreButton;

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) NSMutableArray *netbarArray;

- (IBAction)orderAction:(id)sender;
- (IBAction)packetAction:(id)sender;
- (IBAction)searchNetbarAction:(id)sender;
- (IBAction)moreNetbarAction:(id)sender;
- (IBAction)newGuideAction:(id)sender;

@end

@implementation NetbarTabViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTilteLeftViewHide:NO];
    _isOpen = NO;
    [self refreshNewGuideView:NO];
    _chooseCityName = @"城市";
    self.currentLocation = [WYLocationServiceUtil getLastRecordLocation];
    
    self.weekRedBagIconImgView.hidden = ![WYSettingConfig staticInstance].weekRedBagMessageUnreadEvent;
    
//    [self setUserCity];
    
    [self refreshLeftIconViewUI];
    [self refreshUI];
    [self getCacheNetbarInfos];
    [self getNetbarInfos];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.netBarTable];
    self.pullRefreshView.delegate = self;
    [self.netBarTable addSubview:self.pullRefreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWeekRedBagMessageUreadEvent) name:WY_WEEKREDBAG_UNREAD_EVENT_NOTIFICATION object:nil];
}

-(void)refreshUI
{
    self.netBarTable.tableHeaderView = self.headView;
    self.orderLabel.font = SKIN_FONT_FROMNAME(15);
    self.orderLabel.textColor = SKIN_TEXT_COLOR1;
    self.packetLabel.font = SKIN_FONT_FROMNAME(14);
    self.packetLabel.textColor = SKIN_TEXT_COLOR1;
    self.bookLabel.font = SKIN_FONT_FROMNAME(14);
    self.bookLabel.textColor = SKIN_TEXT_COLOR1;
    self.bookDecLabel.font = SKIN_FONT_FROMNAME(12);
    self.bookDecLabel.textColor = SKIN_TEXT_COLOR2;
    self.guessLabel.font = SKIN_FONT_FROMNAME(15);
    self.guessLabel.textColor = SKIN_TEXT_COLOR1;
    self.hotLabel.font = SKIN_FONT_FROMNAME(12);
    self.hotLabel.layer.cornerRadius = 2;
    self.hotLabel.clipsToBounds = YES;
    self.colorLabel.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel.layer.cornerRadius = 1.0;
    self.colorLabel.layer.masksToBounds = YES;
    
    [self.moreButton.layer setMasksToBounds:YES];
    [self.moreButton.layer setCornerRadius:4.0];
    [self.moreButton.layer setBorderWidth:0.5]; //边框宽度
    [self.moreButton.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
    self.moreButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.moreButton.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.netBarTable.tableFooterView = self.footerView;
    
}

- (void)viewSplash
{
    SKSplashIcon *sloganSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"app_slogan_icon"] animationType:SKIconAnimationTypeBounce];
    UIColor *bgColor = UIColorToRGB(0xead356);
    _splashView = [[SKSplashView alloc] initWithSplashIcon:sloganSplashIcon backgroundColor:bgColor animationType:SKSplashAnimationTypeFade];
    _splashView.delegate = self;
    _splashView.animationDuration = 2;
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        self.tabController.view.backgroundColor  = [UIColor whiteColor];
        CGRect frame = self.tabController.tabBar.frame;
        frame.origin.y -= 50.0;
        self.tabController.tabBar.frame = frame;
        
    } completion:^(BOOL finished) {
        WS(weakSelf);
        //获取用户位置
        [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
            
            [weakSelf setUserCity];//定位失败时 默认用户已选择的城市
            [weakSelf getNetbarInfos];
            WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:errorString cancelButtonTitle:@"取消" cancelBlock:^{
            } okButtonTitle:@"确定" okBlock:^{
                [weakSelf chooseCityAction:nil];
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }];
            [alertView show];
            return;
        } location:^(CLLocation *location) {
            weakSelf.currentLocation = [location coordinate];//当前经纬
            [weakSelf getNetbarInfos];
            [weakSelf placemarkReverseLocation:location];
        }];
    }];
}

- (void)placemarkReverseLocation:(CLLocation *)location{
    WS(weakSelf);
    [[WYLocationServiceUtil shareInstance] placemarkReverseGeoLocation:location placemark:^(CLPlacemark *placemark) {
//        WYLog(@"Placemark des: %@", placemark.description);
        NSDictionary *addressDictionary = placemark.addressDictionary;
        WYLog(@"Placemark addressDictionary: %@", addressDictionary);
        NSString *locality = placemark.locality;
        _currentLocationLocality = locality;
        BOOL isChange = [weakSelf setUserCity];
        if (isChange) {
            _chooseCityName = locality;
            _chooseAreaCode = nil;
        }else{
            _chooseCityName = locality;
            _chooseAreaCode = nil;
        }
        [weakSelf refreshLeftIconViewUI];
        [weakSelf getNetbarInfos];
    }];
}

-(BOOL)setUserCity{
    
    if ([[WYEngine shareInstance] hasAccoutLoggedin]) {
        NSString *cityName = [WYEngine shareInstance].userInfo.cityName;
        NSString *cityCode = [WYEngine shareInstance].userInfo.cityCode;
        if (cityName && cityName.length > 0 && cityCode.length > 0 && cityCode) {
            _chooseCityName = cityName;
            _chooseAreaCode = cityCode;
            [self refreshLeftIconViewUI];
            return YES;
        }else{
            if (_currentLocationLocality.length > 0) {
                _chooseCityName = [NSString stringWithString:_currentLocationLocality];
            }else{
                _chooseCityName = @"城市";
            }
            [self refreshLeftIconViewUI];
            return NO;
        }
    }else{
        _chooseCityName = @"城市";
        [self refreshLeftIconViewUI];
        return NO;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    CGRect frame = self.tabController.tabBar.frame;
    frame.origin.y += 50.0;
    self.tabController.tabBar.frame = frame;
    [self viewSplash];
    self.titleNavImageView.hidden = NO;
    [self setRightButtonWithImageName:@"netbar_nav_search" selector:@selector(serviceAction)];
    
    [self setLeftButtonTitle:_chooseCityName];
    [self setLeftButtonWithImageName:nil];
    [self setLeftButtonWithSelector:@selector(chooseCityAction:)];
    [self refreshLeftIconViewUI];
}

- (void)refreshNewGuideView:(BOOL)isNext {
    self.guideView.frame = [UIScreen mainScreen].bounds;
    BOOL isShow = [[WYUserGuideConfig shareInstance] newPeopleGuideShowForVcType:@"netbarTabView"];
    if (isShow) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:self.guideView];
        UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
        [self.guideImageView addGestureRecognizer:gestureRecongnizer];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.guideView.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.guideView.superview) {
                [self.guideView removeFromSuperview];
                if (isNext) {
                    //...
                }
            }
        }];
    }
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"netbarTabView"];
    [self refreshNewGuideView:NO];
}

-(void)refreshLeftIconViewUI{
    if (_chooseCityIconImgView == nil) {
        _chooseCityIconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"city_choose_down_icon"]];
        _chooseCityIconImgView.frame = CGRectMake(0, 0, 14, 14);
        _chooseCityIconImgView.center = self.titleNavBarLeftButton.center;
        [self.titleNavBar addSubview:_chooseCityIconImgView];
    }
    [self setLeftButtonTitle:_chooseCityName];
    float width = [WYCommonUtils widthWithText:_chooseCityName font:self.titleNavBarLeftButton.titleLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    if (width > 65) {
        width = 65;
    }
    CGRect frame = self.titleNavBarLeftButton.frame;
    frame.size.width = width+13;
    self.titleNavBarLeftButton.frame = frame;
    
    frame = _chooseCityIconImgView.frame;
    frame.origin.x = self.titleNavBarLeftButton.frame.origin.x + self.titleNavBarLeftButton.frame.size.width + 2;
    frame.origin.y = self.titleNavBarLeftButton.center.y;
    _chooseCityIconImgView.frame = frame;
    
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)serviceAction {
    [self searchNetbarAction:nil];
}

- (void)chooseCityAction:(id)sender{
    if (!_isOpen) {
        
        if (_locationChooseVc.view.superview) {
            [_locationChooseVc.view removeFromSuperview];
        }
        if (_bgMarkButtonView.superview) {
            [_bgMarkButtonView removeFromSuperview];
        }
        
        _locationChooseVc = [[LocationViewController alloc] init];
        _locationChooseVc.delagte = self;
        _locationChooseVc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 0);
        [self.view addSubview:_locationChooseVc.view];
        [self.view insertSubview:_locationChooseVc.view belowSubview:self.titleNavBar];
        
        _bgMarkButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgMarkButtonView.frame = self.view.bounds;
        [_bgMarkButtonView addTarget:self action:@selector(cancelChooseCity) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bgMarkButtonView];
        [self.view insertSubview:_bgMarkButtonView belowSubview:_locationChooseVc.view];
        _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [UIView animateWithDuration:0.4 animations:^{
            CGRect frame = _locationChooseVc.view.frame;
            frame.size.height = 353;
            _locationChooseVc.view.frame = frame;
            _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
            _chooseCityIconImgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            frame = _chooseCityIconImgView.frame;
            frame.origin.y = self.titleNavBarLeftButton.center.y + 4;
            _chooseCityIconImgView.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        if (_locationChooseVc.view.superview) {
            [UIView animateWithDuration:0.4 animations:^{
                CGRect frame = _locationChooseVc.view.frame;
                frame.size.height = 0;
                _locationChooseVc.view.frame = frame;
                _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                _chooseCityIconImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
                frame = _chooseCityIconImgView.frame;
                frame.origin.y = self.titleNavBarLeftButton.center.y;
                _chooseCityIconImgView.frame = frame;
            } completion:^(BOOL finished) {
                [_locationChooseVc.view removeFromSuperview];
                [_bgMarkButtonView removeFromSuperview];
            }];
        }
    }
    
    _isOpen = !_isOpen;
}

-(void)cancelChooseCity{
    _isOpen = YES;
    [self chooseCityAction:nil];
}

-(void)getCacheNetbarInfos{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getNetbarListWithUid:[WYEngine shareInstance].uid latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude areaCode:_chooseAreaCode tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.netbarArray = [NSMutableArray array];
            
            NSArray *netbarDicArray = [jsonRet arrayObjectForKey:@"object"];
            for (NSDictionary *dic in netbarDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
                [netbarInfo setNetbarInfoByJsonDic:dic];
                [weakSelf.netbarArray addObject:netbarInfo];
            }
            [weakSelf.netBarTable reloadData];
        }
    }];
}

- (void)getNetbarInfos{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getNetbarListWithUid:[WYEngine shareInstance].uid latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude areaCode:_chooseAreaCode tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        [WYProgressHUD AlertLoadDone];
        [self.pullRefreshView finishedLoading];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.netbarArray = [NSMutableArray array];
        NSArray *netbarDicArray = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in netbarDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf.netbarArray addObject:netbarInfo];
        }
        [weakSelf.netBarTable reloadData];
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.netbarArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 39;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 39)];
    CGRect frame = self.sectionView.frame;
    frame.size.width = SCREEN_WIDTH;
    self.sectionView.frame = frame;
    [view addSubview:self.sectionView];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NetbarTabCell";
    NetbarTabCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    cell.delegate = self;
    WYNetbarInfo *netbarInfo = _netbarArray[indexPath.row];
    cell.netbarInfo = netbarInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYNetbarInfo *info = _netbarArray[indexPath.row];
    NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
    ndVc.netbarInfo = info;
    [self.navigationController pushViewController:ndVc animated:YES];
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark - NetbarTabCellDelegate
- (void)netbarTabCellMapClickWithCell:(id)cell {
    NSIndexPath* indexPath = [self.netBarTable indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
    WYNetbarInfo* netbarInfo = _netbarArray[indexPath.row];
    
    if (netbarInfo.latitude.length == 0 || netbarInfo.longitude == 0 || [netbarInfo.latitude intValue] == 0 || [netbarInfo.longitude intValue] == 0) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"该网吧暂无数据" cancelButtonTitle:@"好的"];
        [alertView show];
        return;
    }
    
    NetbarMapViewController *nmVc = [[NetbarMapViewController alloc] init];
    nmVc.netbarInfo = netbarInfo;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [netbarInfo.latitude doubleValue];
    coordinate.longitude = [netbarInfo.longitude doubleValue];
    [nmVc setShowLocation:coordinate.latitude longitute:coordinate.longitude];
    [self.navigationController pushViewController:nmVc animated:YES];
//    nmVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self.navigationController presentViewController:nmVc animated:YES completion:^{
//        
//    }];
}

#pragma mark - IBAction
- (IBAction)orderAction:(id)sender {
    OrdersViewController *orderVc = [[OrdersViewController alloc] init];
    [self.navigationController pushViewController:orderVc animated:YES];
}

- (IBAction)searchNetbarAction:(id)sender {
    NetbarSearchViewController *searchVc = [[NetbarSearchViewController alloc] init];
    searchVc.areaCode = _chooseAreaCode;
    [self.navigationController pushViewController:searchVc animated:YES];
}

- (IBAction)moreNetbarAction:(id)sender{
    NetbarSearchViewController *searchVc = [[NetbarSearchViewController alloc] init];
    searchVc.areaCode = _chooseAreaCode;
    [self.navigationController pushViewController:searchVc animated:YES];
}

- (IBAction)newGuideAction:(id)sender {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"netbarTabView"];
    [self refreshNewGuideView:NO];
}

- (IBAction)packetAction:(id)sender {
    if ([[WYEngine shareInstance] needUserLogin:@"注册或登录后才能领取红包"]) {
        return;
    }
    [[WYSettingConfig staticInstance] setWeekRedBagMessageUnreadEvent:NO];
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/redbag/web/getRedbag?userId=%@&token=%@", [WYEngine shareInstance].baseUrl, [WYEngine shareInstance].uid,[WYEngine shareInstance].token] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)dealloc{
    WYLog(@"NetbarTabViewController dealloc!!!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _splashView.delegate = nil;
    _splashView = nil;
    _netBarTable.delegate = nil;
    _netBarTable.dataSource = nil;
}

- (void)handleUserInfoChanged:(NSNotification *)notification{
    [self setUserCity];
    [self getNetbarInfos];
    [self.netBarTable reloadData];
}
- (void)handleWeekRedBagMessageUreadEvent{
    self.weekRedBagIconImgView.hidden = ![WYSettingConfig staticInstance].weekRedBagMessageUnreadEvent;
}

#pragma mark - LocationViewControllerDelegate
- (void)locationViewControllerWith:(LocationViewController*)vc selectCity:(NSDictionary *)cityDic{
    [self cancelChooseCity];
    _chooseCityName = [cityDic stringObjectForKey:@"name"];
    _chooseAreaCode = [[cityDic objectForKey:@"areaCode"] description];
    [self refreshLeftIconViewUI];
    [self getNetbarInfos];
}

#pragma mark -XETabBarControllerSubVcProtocol
- (void)tabBarController:(WYTabBarViewController *)tabBarController reSelectVc:(UIViewController *)viewController {
    if (viewController == self) {
        [self.netBarTable setContentOffset:CGPointMake(0, 0 - self.netBarTable.contentInset.top) animated:NO];
    }
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self getNetbarInfos];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

@end
