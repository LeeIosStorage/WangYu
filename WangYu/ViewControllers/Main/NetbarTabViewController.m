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

@interface NetbarTabViewController ()<UITableViewDataSource,UITableViewDelegate,SKSplashDelegate,NetbarTabCellDelegate>

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
    [self refreshUI];
    [self getCacheNetbarInfos];
    [self getNetbarInfos];
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
                LocationViewController *lVc = [[LocationViewController alloc] init];
                [self.navigationController pushViewController:lVc animated:YES];
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
    [self setRightButtonWithImageName:@"netbar_service_icon" selector:@selector(serviceAction)];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)serviceAction {
    
}

-(void)getCacheNetbarInfos{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getNetbarListWithUid:[WYEngine shareInstance].uid latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude tag:tag];
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
    [[WYEngine shareInstance] getNetbarListWithUid:[WYEngine shareInstance].uid latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [WYProgressHUD AlertLoadDone];
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
    nmVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:nmVc animated:YES completion:^{
        
    }];
}

#pragma mark - IBAction
- (IBAction)orderAction:(id)sender {
    OrdersViewController *orderVc = [[OrdersViewController alloc] init];
    [self.navigationController pushViewController:orderVc animated:YES];
}

- (IBAction)searchNetbarAction:(id)sender {
    NetbarSearchViewController *searchVc = [[NetbarSearchViewController alloc] init];
    [self.navigationController pushViewController:searchVc animated:YES];
}

- (IBAction)packetAction:(id)sender {
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"每周领红包" message:@"H5跳转" cancelButtonTitle:@"确定"];
    [alertView show];
}

-(void)dealloc{
    WYLog(@"NetbarTabViewController dealloc!!!");
    _splashView.delegate = nil;
    _splashView = nil;
    _netBarTable.delegate = nil;
    _netBarTable.dataSource = nil;
}

@end
