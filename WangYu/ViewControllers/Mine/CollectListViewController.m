//
//  CollectListViewController.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "CollectListViewController.h"
#import "WYSegmentedView.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYNetbarInfo.h"
#import "WYGameInfo.h"
#import "NetbarDetailViewController.h"
#import "NetbarTabCell.h"
#import "UIImageView+WebCache.h"
#import "GameCollectViewCell.h"

#define COLLECT_TYPE_NETBAR       0
#define COLLECT_TYPE_GAME         1

@interface CollectListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *netbarCollectList;
@property (nonatomic, strong) IBOutlet UITableView *netbarTableView;
@property (strong, nonatomic) NSMutableArray *gameCollectList;
@property (nonatomic, strong) IBOutlet UITableView *gameTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  netbarNextCursor;
@property (assign, nonatomic) BOOL netbarCanLoadMore;
@property (assign, nonatomic) SInt64  gameNextCursor;
@property (assign, nonatomic) BOOL gameCanLoadMore;

@end

@implementation CollectListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _selectedSegmentIndex = 0;
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.netbarTableView];
    self.pullRefreshView.delegate = self;
    [self.netbarTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.gameTableView];
    self.pullRefreshView2.delegate = self;
    [self.gameTableView addSubview:self.pullRefreshView2];
    
    [self feedsTypeSwitch:COLLECT_TYPE_NETBAR needRefreshFeeds:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    WYSegmentedView *segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    segmentedView.items = @[@"网吧收藏",@"游戏收藏"];
    WS(weakSelf);
    segmentedView.segmentedButtonClickBlock = ^(NSInteger index){
        if (index == weakSelf.selectedSegmentIndex) {
            return;
        }
        weakSelf.selectedSegmentIndex = index;
        [self feedsTypeSwitch:(int)index needRefreshFeeds:NO];
    };
    [self.titleNavBar addSubview:segmentedView];
}

-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == COLLECT_TYPE_NETBAR) {
        //减速率
        self.gameTableView.decelerationRate = 0.0f;
        self.netbarTableView.decelerationRate = 1.0f;
        self.gameTableView.hidden = YES;
        self.netbarTableView.hidden = NO;
        
        if (!_netbarCollectList) {
            [self getCacheNetbarCollect];
            [self refreshNetbarCollectList];
            return;
        }
        if (needRefresh) {
            [self refreshNetbarCollectList];
        }
    }else if (tag == COLLECT_TYPE_GAME){
        
        self.gameTableView.decelerationRate = 1.0f;
        self.netbarTableView.decelerationRate = 0.0f;
        self.netbarTableView.hidden = YES;
        self.gameTableView.hidden = NO;
        if (!_gameCollectList) {
            [self getCacheGameCollect];
            [self refreshGameCollectList];
            return;
        }
        if (needRefresh) {
            [self refreshGameCollectList];
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

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshNetbarCollectList];
    }else if (view == self.pullRefreshView2){
        [self refreshGameCollectList];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 网吧收藏
-(void)getCacheNetbarCollect{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getCollectNetBarListWithUid:[WYEngine shareInstance].uid latitude:0 longitude:0 page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.netbarCollectList = [NSMutableArray array];
            
            NSArray *netbarDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in netbarDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
                [netbarInfo setNetbarInfoByJsonDic:dic];
                [weakSelf.netbarCollectList addObject:netbarInfo];
            }
            [weakSelf.netbarTableView reloadData];
        }
    }];
}
-(void)refreshNetbarCollectList{
    _netbarNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getCollectNetBarListWithUid:[WYEngine shareInstance].uid latitude:0 longitude:0 page:(int)_netbarNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        weakSelf.netbarCollectList = [NSMutableArray array];
        NSArray *netbarDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in netbarDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf.netbarCollectList addObject:netbarInfo];
        }
        [weakSelf.netbarTableView reloadData];
        
    }tag:tag];
}
#pragma mark - 游戏收藏
-(void)getCacheGameCollect{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getCollectGameListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.gameCollectList = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
                [gameInfo setGameInfoByJsonDic:dic];
                [weakSelf.gameCollectList addObject:gameInfo];
            }
            [weakSelf.gameTableView reloadData];
        }
    }];
}
-(void)refreshGameCollectList{
    _gameNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getCollectGameListWithUid:[WYEngine shareInstance].uid page:(int)_gameNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    
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
        
        weakSelf.gameCollectList = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
            [gameInfo setGameInfoByJsonDic:dic];
            [weakSelf.gameCollectList addObject:gameInfo];
        }
        
        [weakSelf.gameTableView reloadData];
        
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.gameTableView) {
        return self.gameCollectList.count;
    }
    return self.netbarCollectList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.gameTableView) {
        static NSString *CellIdentifier = @"GameCollectViewCell";
        GameCollectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        WYGameInfo *gameInfo = _gameCollectList[indexPath.row];
        cell.gameInfo = gameInfo;
        return cell;
    }
    static NSString *CellIdentifier = @"NetbarTabCell";
    NetbarTabCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    WYNetbarInfo *netbarInfo = _netbarCollectList[indexPath.row];
    cell.netbarInfo = netbarInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.gameTableView) {
        
    }else{
        WYNetbarInfo *info = _netbarCollectList[indexPath.row];
        NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
        ndVc.netbarInfo = info;
        [self.navigationController pushViewController:ndVc animated:YES];
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
