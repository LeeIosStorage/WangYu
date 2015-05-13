//
//  OrdersViewController.m
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "OrdersViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "ReserveOrderViewCell.h"
#import "PayOrderViewCell.h"
#import "WYSegmentedView.h"

#define ORDER_TYPE_RESERVE     0
#define ORDER_TYPE_PAY         1

@interface OrdersViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *reserveOrderList;
@property (nonatomic, strong) IBOutlet UITableView *reserveOrderTableView;
@property (strong, nonatomic) NSMutableArray *payOrderList;
@property (nonatomic, strong) IBOutlet UITableView *payOrderTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  reserveNextCursor;
@property (assign, nonatomic) BOOL reserveCanLoadMore;
@property (assign, nonatomic) SInt64  payNextCursor;
@property (assign, nonatomic) BOOL payCanLoadMore;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = UIColorRGB(241, 241, 241);
    _selectedSegmentIndex = 0;
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.reserveOrderTableView];
    self.pullRefreshView.delegate = self;
    [self.reserveOrderTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.payOrderTableView];
    self.pullRefreshView2.delegate = self;
    [self.payOrderTableView addSubview:self.pullRefreshView2];
    
    [self feedsTypeSwitch:ORDER_TYPE_RESERVE needRefreshFeeds:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
//    [self setSegmentedControlWithSelector:@selector(segmentedControlAction:) items:@[@"预订订单",@"支付订单"]];
    WYSegmentedView *segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    segmentedView.items = @[@"预订订单",@"支付订单"];
    __weak OrdersViewController *weakSelf = self;
    segmentedView.segmentedButtonClickBlock = ^(NSInteger index){
        if (index == weakSelf.selectedSegmentIndex) {
            return;
        }
        weakSelf.selectedSegmentIndex = index;
//        WYLog(@"selectedSegmentIndex = %d",(int)index);
        [self feedsTypeSwitch:(int)index needRefreshFeeds:NO];
    };
    [self.titleNavBar addSubview:segmentedView];
}

-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == ORDER_TYPE_RESERVE) {
        //减速率
        self.payOrderTableView.decelerationRate = 0.0f;
        self.reserveOrderTableView.decelerationRate = 1.0f;
        self.payOrderTableView.hidden = YES;
        self.reserveOrderTableView.hidden = NO;
        
        if (!_reserveOrderList) {
            [self getCacheReserveOrders];
            [self refreshReserveOrdersList];
            return;
        }
        if (needRefresh) {
            [self refreshReserveOrdersList];
        }
    }else if (tag == ORDER_TYPE_PAY){
        
        self.payOrderTableView.decelerationRate = 1.0f;
        self.reserveOrderTableView.decelerationRate = 0.0f;
        self.reserveOrderTableView.hidden = YES;
        self.payOrderTableView.hidden = NO;
        if (!_payOrderList) {
            [self getCachePayOrders];
            [self refreshPayOrdersList];
            return;
        }
        if (needRefresh) {
            [self refreshPayOrdersList];
        }
    }
}

-(void)segmentedControlAction:(UISegmentedControl *)sender{
    
    _selectedSegmentIndex = sender.selectedSegmentIndex;
    [self feedsTypeSwitch:(int)_selectedSegmentIndex needRefreshFeeds:NO];
    switch (_selectedSegmentIndex) {
        case 0:
        {
            WYLog(@"selectedSegmentIndex0");
        }
            break;
        case 1:
        {
            WYLog(@"selectedSegmentIndex1");
        }
            break;
        default:
            break;
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

#pragma mark - 预订订单
- (void)getCacheReserveOrders{
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getReserveOrderListWithUid:[WYEngine shareInstance].uid page:1 pageSize:10 tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.reserveOrderList = [[NSMutableArray alloc] init];
            
//            NSArray *object = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"activity"];
//            for (NSDictionary *dic in object) {
//                XEActivityInfo *activityInfo = [[XEActivityInfo alloc] init];
//                [activityInfo setActivityInfoByJsonDic:dic];
//                [weakSelf.activityList addObject:activityInfo];
//            }
            [weakSelf.reserveOrderTableView reloadData];
        }
    }];
}
- (void)refreshReserveOrdersList{
    
    _reserveNextCursor = 1;
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getReserveOrderListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.reserveNextCursor pageSize:10 tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [self.pullRefreshView finishedLoading];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
//            return;
        }
        weakSelf.reserveOrderList = [[NSMutableArray alloc] init];
//        NSArray *object = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"activity"];
//        for (NSDictionary *dic in object) {
//            XEActivityInfo *activityInfo = [[XEActivityInfo alloc] init];
//            [activityInfo setActivityInfoByJsonDic:dic];
//            [weakSelf.activityList addObject:activityInfo];
//        }
//        
//        weakSelf.reserveCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"end"] boolValue];
//        if (!weakSelf.reserveCanLoadMore) {
//            weakSelf.reserveOrderTableView.showsInfiniteScrolling = NO;
//        }else{
//            weakSelf.reserveOrderTableView.showsInfiniteScrolling = YES;
//            weakSelf.reserveNextCursor ++;
//        }
        
        [weakSelf.reserveOrderTableView reloadData];
        
    }tag:tag];
}

#pragma mark - 历史活动
- (void)getCachePayOrders{
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getPayOrderListWithUid:[WYEngine shareInstance].uid page:1 pageSize:10 tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.payOrderList = [[NSMutableArray alloc] init];
//            NSArray *object = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"activity"];
//            for (NSDictionary *dic in object) {
//                XERecipesInfo *recipesInfo = [[XERecipesInfo alloc] init];
//                [recipesInfo setRecipesInfoByDic:dic];
//                [weakSelf.payOrderList addObject:recipesInfo];
//            }
            [weakSelf.payOrderTableView reloadData];
        }
    }];
}
- (void)refreshPayOrdersList{
    
    _payNextCursor = 1;
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getPayOrderListWithUid:[WYEngine shareInstance].uid page:(int)_payNextCursor pageSize:10 tag:tag];

    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [self.pullRefreshView2 finishedLoading];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
//            return;
        }
        
        weakSelf.payOrderList = [[NSMutableArray alloc] init];
        [weakSelf.payOrderList addObject:@"0"];
        [weakSelf.payOrderList addObject:@"0"];
        [weakSelf.payOrderList addObject:@"0"];
        [weakSelf.payOrderList addObject:@"0"];
//        NSArray *object = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"activity"];
//        for (NSDictionary *dic in object) {
//            XERecipesInfo *recipesInfo = [[XERecipesInfo alloc] init];
//            [recipesInfo setRecipesInfoByDic:dic];
//            [weakSelf.payOrderList addObject:recipesInfo];
//        }
//        
//        weakSelf.payCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"end"] boolValue];
//        if (!weakSelf.payCanLoadMore) {
//            weakSelf.payOrderTableView.showsInfiniteScrolling = NO;
//        }else{
//            weakSelf.payOrderTableView.showsInfiniteScrolling = YES;
//            weakSelf.payNextCursor ++;
//        }
        
        [weakSelf.payOrderTableView reloadData];
        
    }tag:tag];
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshReserveOrdersList];
    }else if (view == self.pullRefreshView2){
        [self refreshPayOrdersList];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.payOrderTableView) {
        return _payOrderList.count;
    }
    return _reserveOrderList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.payOrderTableView) {
        return 150;
    }
    return 150;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.payOrderTableView) {
        
        static NSString *CellIdentifier = @"PayOrderViewCell";
        PayOrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.orderInfo = nil;
        return cell;
    }
    static NSString *CellIdentifier = @"ReserveOrderViewCell";
    ReserveOrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.orderInfo = nil;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
