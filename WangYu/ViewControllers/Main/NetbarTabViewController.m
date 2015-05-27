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

@interface NetbarTabViewController ()<UITableViewDataSource,UITableViewDelegate,SKSplashDelegate,NetbarTabCellDelegate,LocationViewControllerDelegate>
{
    NSString *_chooseCityName;
    NSString *_chooseAreaCode;
    UIImageView *_chooseCityIconImgView;
    
    BOOL _isOpen;
    UIButton *_bgMarkButtonView;
    LocationViewController *_locationChooseVc;
}
@property (strong, nonatomic) IBOutlet UILabel *orderLabel;
@property (strong, nonatomic) IBOutlet UILabel *packetLabel;
@property (strong, nonatomic) IBOutlet UILabel *bookLabel;
@property (strong, nonatomic) IBOutlet UILabel *bookDecLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotLabel;
@property (strong, nonatomic) IBOutlet UILabel *guessLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UITableView *netBarTable;
@property (strong, nonatomic) SKSplashView *splashView;

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;
@property (strong, nonatomic) NSMutableArray *netbarArray;

- (IBAction)orderAction:(id)sender;
- (IBAction)packetAction:(id)sender;
- (IBAction)searchNetbarAction:(id)sender;

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
    _chooseCityName = @"选择城市";
    [self refreshLeftIconViewUI];
    [self refreshUI];
    [self getCacheNetbarInfos];
    [self getNetbarInfos];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.netBarTable];
    self.pullRefreshView.delegate = self;
    [self.netBarTable addSubview:self.pullRefreshView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
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
}

- (void)viewSplash
{
    SKSplashIcon *sloganSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"app_slogan_icon"] animationType:SKIconAnimationTypeBounce];
    UIColor *bgColor = SKIN_COLOR;
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
            WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:errorString cancelButtonTitle:@"取消" cancelBlock:^{
            } okButtonTitle:@"确定" okBlock:^{
//                LocationViewController *lVc = [[LocationViewController alloc] init];
//                [self.navigationController pushViewController:lVc animated:YES];
                [weakSelf chooseCityAction:nil];
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
    [[WYLocationServiceUtil shareInstance] placemarkReverseGeoLocation:location placemark:^(CLPlacemark *placemark) {
//        WYLog(@"Placemark des: %@", placemark.description);
        NSDictionary *addressDictionary = placemark.addressDictionary;
        WYLog(@"Placemark addressDictionary: %@", addressDictionary);
        _chooseCityName = placemark.locality;
        [self refreshLeftIconViewUI];
    }];
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
//    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"客服" message:@"H5页跳转" cancelButtonTitle:@"确定"];
//    [alertView show];
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
            frame.size.height = 380;
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

- (IBAction)packetAction:(id)sender {
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"每周领红包" message:@"H5页跳转" cancelButtonTitle:@"确定"];
    [alertView show];
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
    [self getNetbarInfos];
    [self.netBarTable reloadData];
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
