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
#import "WYOrderInfo.h"
#import "NetbarDetailViewController.h"
#import "QuickPayViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYPayManager.h"
#import "WYAlertView.h"
#import "BookDetailViewController.h"
#import "OrderDetailViewController.h"

#define ORDER_TYPE_RESERVE     0
#define ORDER_TYPE_PAY         1

@interface OrdersViewController ()<UITableViewDataSource,UITableViewDelegate,ReserveOrderViewCellDelegate,PayOrderViewCellDelegate,WYPayManagerListener>

//创建需要@property 不然viewController 不会释放
@property (strong, nonatomic) WYSegmentedView *segmentedView;

@property (strong, nonatomic) NSMutableArray *reserveOrderList;
@property (nonatomic, strong) IBOutlet UITableView *reserveOrderTableView;
@property (strong, nonatomic) NSMutableArray *payOrderList;
@property (nonatomic, strong) IBOutlet UITableView *payOrderTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  reserveNextCursor;
@property (assign, nonatomic) BOOL reserveCanLoadMore;
@property (assign, nonatomic) SInt64  payNextCursor;
@property (assign, nonatomic) BOOL payCanLoadMore;

@property (assign, nonatomic) BOOL isHavReserveServerSucceed;
@property (assign, nonatomic) BOOL isHavPayServerSucceed;
@property (strong, nonatomic) IBOutlet UIView *orderBlankTipView;
@property (strong, nonatomic) IBOutlet UILabel *orderBlankTipLabel;

@end

@implementation OrdersViewController

- (void)dealloc{
    WYLog(@"%@ dealloc!!!",NSStringFromClass([self class]));
    [[WYPayManager shareInstance] removeListener:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleUserInfoChanged:(NSNotification *)notification{
    if (_selectedSegmentIndex == 0) {
        [self refreshReserveOrdersList];
    }else if (_selectedSegmentIndex == 1){
        [self refreshPayOrdersList];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //!!!: 登录失效时 重新登录后通知页面刷新 此处用Notification感觉不太合理 待优化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
    
    self.view.backgroundColor = UIColorRGB(241, 241, 241);
    
    [[WYPayManager shareInstance] addListener:self];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.reserveOrderTableView];
    self.pullRefreshView.delegate = self;
    [self.reserveOrderTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.payOrderTableView];
    self.pullRefreshView2.delegate = self;
    [self.payOrderTableView addSubview:self.pullRefreshView2];
    
    if (_isShowPayPage) {
        _selectedSegmentIndex = ORDER_TYPE_PAY;
        [self feedsTypeSwitch:ORDER_TYPE_PAY needRefreshFeeds:YES];
    }else{
        _selectedSegmentIndex = ORDER_TYPE_RESERVE;
        [self feedsTypeSwitch:ORDER_TYPE_RESERVE needRefreshFeeds:YES];
    }
    
    WS(weakSelf);
    [self.reserveOrderTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.reserveCanLoadMore) {
            [weakSelf.reserveOrderTableView.infiniteScrollingView stopAnimating];
            weakSelf.reserveOrderTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getReserveOrderListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.reserveNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.reserveOrderTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
                [orderInfo setOrderInfoByJsonDic:dic];
                [weakSelf.reserveOrderList addObject:orderInfo];
            }
            
            weakSelf.reserveCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.reserveCanLoadMore) {
                weakSelf.reserveOrderTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.reserveOrderTableView.showsInfiniteScrolling = YES;
                weakSelf.reserveNextCursor ++;
            }
            
            [weakSelf.reserveOrderTableView reloadData];
            
        } tag:tag];
    }];
    
    [self.payOrderTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.payCanLoadMore) {
            [weakSelf.payOrderTableView.infiniteScrollingView stopAnimating];
            weakSelf.payOrderTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getPayOrderListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.payNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.payOrderTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
                [orderInfo setOrderInfoByJsonDic:dic];
                [weakSelf.payOrderList addObject:orderInfo];
            }
            
            weakSelf.payCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.payCanLoadMore) {
                weakSelf.payOrderTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.payOrderTableView.showsInfiniteScrolling = YES;
                weakSelf.payNextCursor ++;
            }
            
            [weakSelf.payOrderTableView reloadData];
            
        } tag:tag];
    }];
    weakSelf.reserveOrderTableView.showsInfiniteScrolling = NO;
    weakSelf.payOrderTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
//    [self setSegmentedControlWithSelector:@selector(segmentedControlAction:) items:@[@"预订订单",@"支付订单"]];
    _segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    _segmentedView.items = @[@"预订订单",@"支付订单"];
    _segmentedView.selectIndex = 0;
    if (_isShowPayPage) {
        _segmentedView.selectIndex = 1;
    }
    __weak OrdersViewController *weakSelf = self;
    _segmentedView.segmentedButtonClickBlock = ^(NSInteger index){
        if (index == weakSelf.selectedSegmentIndex) {
            return;
        }
        weakSelf.selectedSegmentIndex = index;
        [weakSelf feedsTypeSwitch:(int)index needRefreshFeeds:NO];
    };
    [self.titleNavBar addSubview:_segmentedView];
}

-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == ORDER_TYPE_RESERVE) {
        //减速率
        self.payOrderTableView.decelerationRate = 0.0f;
        self.reserveOrderTableView.decelerationRate = 1.0f;
        self.payOrderTableView.hidden = YES;
        self.reserveOrderTableView.hidden = NO;
        
        if (_isHavReserveServerSucceed) {
            [self refreshShowUI];
        }
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
        
        if (_isHavPayServerSucceed) {
            [self refreshShowUI];
        }
        
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

- (void)refreshShowUI{
    self.orderBlankTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.orderBlankTipLabel.textColor = SKIN_TEXT_COLOR2;
    if (self.selectedSegmentIndex == 0) {
        if (self.reserveOrderList && self.reserveOrderList.count == 0) {
            CGRect frame = self.orderBlankTipView.frame;
            frame.origin.y = 0;
            frame.size.width = SCREEN_WIDTH;
            self.orderBlankTipView.frame = frame;
            self.orderBlankTipLabel.text = @"这么小气的，订单空空的";
            [self.reserveOrderTableView addSubview:self.orderBlankTipView];
            
        }else{
            if (self.orderBlankTipView.superview) {
                [self.orderBlankTipView removeFromSuperview];
            }
        }
    }else if (self.selectedSegmentIndex == 1){
        if (self.payOrderList && self.payOrderList.count == 0) {
            CGRect frame = self.orderBlankTipView.frame;
            frame.origin.y = 0;
            frame.size.width = SCREEN_WIDTH;
            self.orderBlankTipView.frame = frame;
            self.orderBlankTipLabel.text = @"这么小气的，订单空空的";
            [self.payOrderTableView addSubview:self.orderBlankTipView];
            
        }else{
            if (self.orderBlankTipView.superview) {
                [self.orderBlankTipView removeFromSuperview];
            }
        }
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
    [[WYEngine shareInstance] getReserveOrderListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.reserveOrderList = [[NSMutableArray alloc] init];
            
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
                [orderInfo setOrderInfoByJsonDic:dic];
                [weakSelf.reserveOrderList addObject:orderInfo];
            }
            [weakSelf.reserveOrderTableView reloadData];
        }
    }];
}
- (void)refreshReserveOrdersList{
    
    _reserveNextCursor = 1;
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getReserveOrderListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.reserveNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [self.pullRefreshView finishedLoading];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.reserveOrderList = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
            [orderInfo setOrderInfoByJsonDic:dic];
            [weakSelf.reserveOrderList addObject:orderInfo];
        }
//
        weakSelf.reserveCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.reserveCanLoadMore) {
            weakSelf.reserveOrderTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.reserveOrderTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.reserveNextCursor ++;
        }
        weakSelf.isHavReserveServerSucceed = YES;
        [weakSelf refreshShowUI];
        [weakSelf.reserveOrderTableView reloadData];
        
    }tag:tag];
}

#pragma mark - 支付订单
- (void)getCachePayOrders{
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getPayOrderListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.payOrderList = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
                [orderInfo setOrderInfoByJsonDic:dic];
                [weakSelf.payOrderList addObject:orderInfo];
            }
            [weakSelf.payOrderTableView reloadData];
        }
    }];
}
- (void)refreshPayOrdersList{
    
    _payNextCursor = 1;
    __weak OrdersViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getPayOrderListWithUid:[WYEngine shareInstance].uid page:(int)_payNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];

    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [self.pullRefreshView2 finishedLoading];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        weakSelf.payOrderList = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
            [orderInfo setOrderInfoByJsonDic:dic];
            [weakSelf.payOrderList addObject:orderInfo];
        }
//
        weakSelf.payCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.payCanLoadMore) {
            weakSelf.payOrderTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.payOrderTableView.showsInfiniteScrolling = YES;
            weakSelf.payNextCursor ++;
        }
        weakSelf.isHavPayServerSucceed = YES;
        [weakSelf refreshShowUI];
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
        cell.delegate = self;
        cell.orderInfo = _payOrderList[indexPath.row];
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
    cell.delegate = self;
    cell.orderInfo = _reserveOrderList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
    if (_selectedSegmentIndex == ORDER_TYPE_PAY) {
        orderInfo = _payOrderList[indexPath.row];
        OrderDetailViewController *odVc = [[OrderDetailViewController alloc] init];
        odVc.orderInfo = orderInfo;
        [self.navigationController pushViewController:odVc animated:YES];
    }else {
        orderInfo = _reserveOrderList[indexPath.row];
        BookDetailViewController *bdVc = [[BookDetailViewController alloc] init];
        bdVc.orderInfo = orderInfo;
        [self.navigationController pushViewController:bdVc animated:YES];
    }
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark - ReserveOrderViewCellDelegate
- (void)reserveOrderViewCellNetbarClickWithCell:(id)cell{
    
    NSIndexPath* indexPath = [self.reserveOrderTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYOrderInfo* orderInfo = _reserveOrderList[indexPath.row];
    NetbarDetailViewController *vc = [[NetbarDetailViewController alloc] init];
    WYNetbarInfo *netBarInfo = [[WYNetbarInfo alloc] init];
    netBarInfo.nid = orderInfo.netbarId;
    netBarInfo.netbarName = orderInfo.netbarName;
    vc.netbarInfo = netBarInfo;
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)reserveOrderViewCellCancelClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.reserveOrderTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYOrderInfo* orderInfo = _reserveOrderList[indexPath.row];
    WS(weakSelf);
    WYAlertView *alert = [[WYAlertView alloc] initWithTitle:nil message:@"确认取消订单吗?" cancelButtonTitle:@"取消" cancelBlock:^{
        
    } okButtonTitle:@"确认" okBlock:^{
        [weakSelf cancelReserveOrder:orderInfo];
    }];
    [alert show];
}
- (void)reserveOrderViewCellPayClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.reserveOrderTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYOrderInfo* orderInfo = _reserveOrderList[indexPath.row];
    if ([orderInfo.amount doubleValue] == 0) {
        //没加价时 确认前往 处理
        [self affirmGoNetBar:orderInfo];
        return;
    }
    [self reserveToOrder:orderInfo];
}

#pragma mark - 根据预订订单生成支付订单
- (void)reserveToOrder:(WYOrderInfo *)orderInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] reserveToOrderWithUid:[WYEngine shareInstance].uid reserveId:orderInfo.reserveId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [WYProgressHUD AlertLoadDone];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        orderInfo.orderId = [[jsonRet objectForKey:@"object"] stringObjectForKey:@"order_id"];
        
        QuickPayViewController *payVc = [[QuickPayViewController alloc] init];
        payVc.isBooked = YES;
        payVc.orderInfo = orderInfo;
        WYNetbarInfo *netBarInfo = [[WYNetbarInfo alloc] init];
        netBarInfo.nid = orderInfo.netbarId;
        netBarInfo.netbarName = orderInfo.netbarName;
        payVc.netbarInfo = netBarInfo;
        [self.navigationController pushViewController:payVc animated:YES];
    }tag:tag];
}

- (void)affirmGoNetBar:(WYOrderInfo *)orderInfo{
    
    WS(weakSelf);
    [WYProgressHUD AlertLoading:@"确认中..." At:weakSelf.view];
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] confirmReserveWithUid:[WYEngine shareInstance].uid reserveId:orderInfo.reserveId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"确认成功" At:weakSelf.view];
//        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        orderInfo.isValid = 2;
        orderInfo.status = 1;
        [weakSelf.reserveOrderTableView reloadData];
        
    }tag:tag];
    
}

#pragma mark -WYPayManagerListener
- (void)payManagerResultStatus:(int)status payType:(int)payType{
    [self refreshPayOrdersList];
}

#pragma mark - PayOrderViewCellDelegate
- (void)payOrderViewCellNetbarClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.payOrderTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYOrderInfo* orderInfo = _payOrderList[indexPath.row];
    NetbarDetailViewController *vc = [[NetbarDetailViewController alloc] init];
    WYNetbarInfo *netBarInfo = [[WYNetbarInfo alloc] init];
    netBarInfo.nid = orderInfo.netbarId;
    netBarInfo.netbarName = orderInfo.netbarName;
    vc.netbarInfo = netBarInfo;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)payOrderViewCellCancelClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.payOrderTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYOrderInfo* orderInfo = _payOrderList[indexPath.row];
    WS(weakSelf);
    WYAlertView *alert = [[WYAlertView alloc] initWithTitle:nil message:@"确认删除订单吗?" cancelButtonTitle:@"取消" cancelBlock:^{
        
    } okButtonTitle:@"确认" okBlock:^{
        [weakSelf deletePayOrder:orderInfo];
    }];
    [alert show];
}
- (void)payOrderViewCellPayClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.payOrderTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYOrderInfo* orderInfo = _payOrderList[indexPath.row];
    [self continuePayOrder:orderInfo];
//    QuickPayViewController *payVc = [[QuickPayViewController alloc] init];
//    [self.navigationController pushViewController:payVc animated:YES];
}

-(void)continuePayOrder:(WYOrderInfo *)orderInfo{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (orderInfo.type == 2) {
        if (![WXApi isWXAppInstalled]) {
            [WYUIUtils showAlertWithMsg:@"微信支付失败！"];
            return;
        }

        if (orderInfo.nonceStr) {
            [dic setValue:orderInfo.nonceStr forKey:@"nonce_str"];
        }
        if (orderInfo.prepayId) {
            [dic setValue:orderInfo.prepayId forKey:@"prepay_id"];
        }
        [[WYPayManager shareInstance] payForWinxinWith:dic];
    }else if (orderInfo.type == 1) {
        
        if (orderInfo.orderId) {
            [dic setValue:orderInfo.orderId forKey:@"orderId"];
        }
        if (orderInfo.outTradeNo) {
            [dic setValue:orderInfo.outTradeNo forKey:@"out_trade_no"];
        }
        if (orderInfo.netbarName) {
            [dic setValue:orderInfo.netbarName forKey:@"netbarName"];
        }
        if (orderInfo.amount) {
            [dic setValue:orderInfo.amount forKey:@"amount"];
        }
        [[WYPayManager shareInstance] payForAlipayWith:dic];
    }
}

-(void)cancelReserveOrder:(WYOrderInfo *)orderInfo{
    
    __weak OrdersViewController *weakSelf = self;
    [WYProgressHUD AlertLoading:@"取消中..." At:weakSelf.view];
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] cancelReserveOrderWithUid:[WYEngine shareInstance].uid reserveId:orderInfo.reserveId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"取消订单成功" At:weakSelf.view];
        orderInfo.isValid = 0;
        [weakSelf.reserveOrderTableView reloadData];
        
    } tag:tag];
}

-(void)deletePayOrder:(WYOrderInfo *)orderInfo{
    __weak OrdersViewController *weakSelf = self;
    [WYProgressHUD AlertLoading:@"删除中..." At:weakSelf.view];
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] deletePayOrderWithUid:[WYEngine shareInstance].uid orderId:orderInfo.orderId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"删除订单成功" At:weakSelf.view];
        orderInfo.isValid = 0;
//        [weakSelf.payOrderTableView reloadData];
        
        NSInteger index = [weakSelf.payOrderList indexOfObject:orderInfo];
        if (index == NSNotFound || index < 0 || index >= weakSelf.payOrderList.count) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [weakSelf.payOrderList removeObjectAtIndex:indexPath.row];
        [weakSelf.payOrderTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } tag:tag];
}

@end
