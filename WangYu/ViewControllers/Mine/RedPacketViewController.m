//
//  RedPacketViewController.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RedPacketViewController.h"
#import "WYSegmentedView.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "RedPacketInfo.h"
#import "RedPacketViewCell.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYLinkerHandler.h"

#define REDPACKET_TYPE_FREE            0
#define REDPACKET_TYPE_HISTORY         1

@interface RedPacketViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *freeRedPacketList;
@property (nonatomic, strong) IBOutlet UITableView *freeRedPacketTableView;
@property (strong, nonatomic) NSMutableArray *historyRedPacketList;
@property (nonatomic, strong) IBOutlet UITableView *historyRedPacketTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  freeNextCursor;
@property (assign, nonatomic) BOOL freeCanLoadMore;
@property (assign, nonatomic) SInt64  historyNextCursor;
@property (assign, nonatomic) BOOL historyCanLoadMore;

@end

@implementation RedPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _selectedSegmentIndex = 0;
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.freeRedPacketTableView];
    self.pullRefreshView.delegate = self;
    [self.freeRedPacketTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.historyRedPacketTableView];
    self.pullRefreshView2.delegate = self;
    [self.historyRedPacketTableView addSubview:self.pullRefreshView2];
    
    [self feedsTypeSwitch:REDPACKET_TYPE_FREE needRefreshFeeds:YES];
    
    WS(weakSelf);
    [self.freeRedPacketTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.freeCanLoadMore) {
            [weakSelf.freeRedPacketTableView.infiniteScrollingView stopAnimating];
            weakSelf.freeRedPacketTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getFreeRedPacketListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.freeNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.freeRedPacketTableView.infiniteScrollingView stopAnimating];
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
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                RedPacketInfo *redPacketInfo = [[RedPacketInfo alloc] init];
                [redPacketInfo setRedPacketInfoByJsonDic:dic];
                [weakSelf.freeRedPacketList addObject:redPacketInfo];
            }
            
            weakSelf.freeCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.freeCanLoadMore) {
                weakSelf.freeRedPacketTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.freeRedPacketTableView.showsInfiniteScrolling = YES;
                weakSelf.freeNextCursor ++;
            }
            
            [weakSelf.freeRedPacketTableView reloadData];
            
        } tag:tag];
    }];
    
    [self.historyRedPacketTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.historyCanLoadMore) {
            [weakSelf.historyRedPacketTableView.infiniteScrollingView stopAnimating];
            weakSelf.historyRedPacketTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getHistoryRedPacketListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.historyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.historyRedPacketTableView.infiniteScrollingView stopAnimating];
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
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                RedPacketInfo *redPacketInfo = [[RedPacketInfo alloc] init];
                [redPacketInfo setRedPacketInfoByJsonDic:dic];
                [weakSelf.historyRedPacketList addObject:redPacketInfo];
            }
            
            weakSelf.historyCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.historyCanLoadMore) {
                weakSelf.historyRedPacketTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.historyRedPacketTableView.showsInfiniteScrolling = YES;
                weakSelf.historyNextCursor ++;
            }
            
            [weakSelf.historyRedPacketTableView reloadData];
            
        } tag:tag];
    }];
    weakSelf.freeRedPacketTableView.showsInfiniteScrolling = NO;
    weakSelf.historyRedPacketTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    
    [self setRightButtonWithImageName:@"redpacket_help_icon" selector:@selector(aboutRedPacketAction:)];
    
    WYSegmentedView *segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    segmentedView.items = @[@"可用红包",@"历史红包"];
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
    if (tag == REDPACKET_TYPE_FREE) {
        //减速率
        self.historyRedPacketTableView.decelerationRate = 0.0f;
        self.freeRedPacketTableView.decelerationRate = 1.0f;
        self.historyRedPacketTableView.hidden = YES;
        self.freeRedPacketTableView.hidden = NO;
        
        if (!_freeRedPacketList) {
            [self getCacheFreeRedPacket];
            [self refreshFreeRedPacketList];
            return;
        }
        if (needRefresh) {
            [self refreshFreeRedPacketList];
        }
    }else if (tag == REDPACKET_TYPE_HISTORY){
        
        self.historyRedPacketTableView.decelerationRate = 1.0f;
        self.freeRedPacketTableView.decelerationRate = 0.0f;
        self.freeRedPacketTableView.hidden = YES;
        self.historyRedPacketTableView.hidden = NO;
        if (!_historyRedPacketList) {
            [self getCacheHistoryRedPacket];
            [self refreshHistoryRedPacketList];
            return;
        }
        if (needRefresh) {
            [self refreshHistoryRedPacketList];
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
        [self refreshFreeRedPacketList];
    }else if (view == self.pullRefreshView2){
        [self refreshHistoryRedPacketList];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

-(void)aboutRedPacketAction:(id)sender{
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/redbag/web/help", [WYEngine shareInstance].baseUrl] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - 可用红包
-(void)getCacheFreeRedPacket{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getFreeRedPacketListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.freeRedPacketList = [NSMutableArray array];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                RedPacketInfo *redPacketInfo = [[RedPacketInfo alloc] init];
                [redPacketInfo setRedPacketInfoByJsonDic:dic];
                [weakSelf.freeRedPacketList addObject:redPacketInfo];
            }
            [weakSelf.freeRedPacketTableView reloadData];
        }
    }];
}
-(void)refreshFreeRedPacketList{
    _freeNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getFreeRedPacketListWithUid:[WYEngine shareInstance].uid page:(int)_freeNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        weakSelf.freeRedPacketList = [NSMutableArray array];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            RedPacketInfo *redPacketInfo = [[RedPacketInfo alloc] init];
            [redPacketInfo setRedPacketInfoByJsonDic:dic];
            [weakSelf.freeRedPacketList addObject:redPacketInfo];
        }
        
        weakSelf.freeCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.freeCanLoadMore) {
            weakSelf.freeRedPacketTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.freeRedPacketTableView.showsInfiniteScrolling = YES;
            weakSelf.freeNextCursor ++;
        }
        
        [weakSelf.freeRedPacketTableView reloadData];
        
    }tag:tag];
}
#pragma mark - 历史红包
-(void)getCacheHistoryRedPacket{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getHistoryRedPacketListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.historyRedPacketList = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                RedPacketInfo *redPacketInfo = [[RedPacketInfo alloc] init];
                [redPacketInfo setRedPacketInfoByJsonDic:dic];
                [weakSelf.historyRedPacketList addObject:redPacketInfo];
            }
            [weakSelf.historyRedPacketTableView reloadData];
        }
    }];
}
-(void)refreshHistoryRedPacketList{
    _historyNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getHistoryRedPacketListWithUid:[WYEngine shareInstance].uid page:(int)_historyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    
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
        
        weakSelf.historyRedPacketList = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            RedPacketInfo *redPacketInfo = [[RedPacketInfo alloc] init];
            [redPacketInfo setRedPacketInfoByJsonDic:dic];
            [weakSelf.historyRedPacketList addObject:redPacketInfo];
        }
        
        weakSelf.historyCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.historyCanLoadMore) {
            weakSelf.historyRedPacketTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.historyRedPacketTableView.showsInfiniteScrolling = YES;
            weakSelf.historyNextCursor ++;
        }
        
        [weakSelf.historyRedPacketTableView reloadData];
        
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.historyRedPacketTableView) {
        return _historyRedPacketList.count;
    }
    return _freeRedPacketList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 123;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyRedPacketTableView) {
        static NSString *CellIdentifier = @"RedPacketViewCell";
        RedPacketViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.isPast = YES;
        RedPacketInfo *redPacketInfo = _historyRedPacketList[indexPath.row];
        cell.redPacketInfo = redPacketInfo;
        return cell;
    }
    static NSString *CellIdentifier = @"RedPacketViewCell";
    RedPacketViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.isPast = NO;
    RedPacketInfo *redPacketInfo = _freeRedPacketList[indexPath.row];
    cell.redPacketInfo = redPacketInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyRedPacketTableView) {
        
    }else{
        
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
