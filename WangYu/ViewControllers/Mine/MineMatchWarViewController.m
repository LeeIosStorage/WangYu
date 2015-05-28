//
//  MineMatchWarViewController.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MineMatchWarViewController.h"
#import "WYSegmentedView.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYMatchWarInfo.h"
#import "MatchWarViewCell.h"

#define MATCHWAR_TYPE_PULISH        0
#define MATCHWAR_TYPE_APPLY         1

@interface MineMatchWarViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *publishMatchList;
@property (nonatomic, strong) IBOutlet UITableView *publishTableView;
@property (strong, nonatomic) NSMutableArray *applyMatchList;
@property (nonatomic, strong) IBOutlet UITableView *applyTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  publishNextCursor;
@property (assign, nonatomic) BOOL publishCanLoadMore;
@property (assign, nonatomic) SInt64  applyNextCursor;
@property (assign, nonatomic) BOOL applyCanLoadMore;

@end

@implementation MineMatchWarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _selectedSegmentIndex = 0;
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.publishTableView];
    self.pullRefreshView.delegate = self;
    [self.publishTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.applyTableView];
    self.pullRefreshView2.delegate = self;
    [self.applyTableView addSubview:self.pullRefreshView2];
    
    [self feedsTypeSwitch:MATCHWAR_TYPE_PULISH needRefreshFeeds:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    WYSegmentedView *segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    segmentedView.items = @[@"我发布的",@"我报名的"];
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
    if (tag == MATCHWAR_TYPE_PULISH) {
        //减速率
        self.applyTableView.decelerationRate = 0.0f;
        self.publishTableView.decelerationRate = 1.0f;
        self.applyTableView.hidden = YES;
        self.publishTableView.hidden = NO;
        
        if (!_publishMatchList) {
            [self getCachePublishMatchWar];
            [self refreshPublishMatchWarList];
            return;
        }
        if (needRefresh) {
            [self refreshPublishMatchWarList];
        }
    }else if (tag == MATCHWAR_TYPE_APPLY){
        
        self.applyTableView.decelerationRate = 1.0f;
        self.publishTableView.decelerationRate = 0.0f;
        self.publishTableView.hidden = YES;
        self.applyTableView.hidden = NO;
        if (!_applyMatchList) {
            [self getCacheApplyMatchWar];
            [self refreshApplyMatchWarList];
            return;
        }
        if (needRefresh) {
            [self refreshApplyMatchWarList];
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
        [self refreshPublishMatchWarList];
    }else if (view == self.pullRefreshView2){
        [self refreshApplyMatchWarList];
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

#pragma mark - 我发布的
-(void)getCachePublishMatchWar{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getPulishMatchWarListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.publishMatchList = [NSMutableArray array];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
                [matchWarInfo setMatchWarInfoByJsonDic:dic];
                [weakSelf.publishMatchList addObject:matchWarInfo];
            }
            [weakSelf.publishTableView reloadData];
        }
    }];
}
-(void)refreshPublishMatchWarList{
    _publishNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getPulishMatchWarListWithUid:[WYEngine shareInstance].uid page:(int)_publishNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
//    [[WYEngine shareInstance] getMatchListWithPage:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        weakSelf.publishMatchList = [NSMutableArray array];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
            [matchWarInfo setMatchWarInfoByJsonDic:dic];
            [weakSelf.publishMatchList addObject:matchWarInfo];
        }
        [weakSelf.publishTableView reloadData];
        
    }tag:tag];
}
#pragma mark - 我报名的
-(void)getCacheApplyMatchWar{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getApplyMatchWarListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.applyMatchList = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
                [matchWarInfo setMatchWarInfoByJsonDic:dic];
                [weakSelf.applyMatchList addObject:matchWarInfo];
            }
            [weakSelf.applyTableView reloadData];
        }
    }];
}
-(void)refreshApplyMatchWarList{
    _applyNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getApplyMatchWarListWithUid:[WYEngine shareInstance].uid page:(int)_applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        
        weakSelf.applyMatchList = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
            [matchWarInfo setMatchWarInfoByJsonDic:dic];
            [weakSelf.applyMatchList addObject:matchWarInfo];
        }
        [weakSelf.applyTableView reloadData];
        
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.applyTableView) {
        return self.applyMatchList.count;
    }
    return self.publishMatchList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 138;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.applyTableView) {
        static NSString *CellIdentifier = @"MatchWarViewCell";
        MatchWarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        WYMatchWarInfo *matchWarInfo = _applyMatchList[indexPath.row];
        cell.matchWarInfo = matchWarInfo;
        return cell;
    }
    static NSString *CellIdentifier = @"MatchWarViewCell";
    MatchWarViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    WYMatchWarInfo *matchWarInfo = _publishMatchList[indexPath.row];
    cell.matchWarInfo = matchWarInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
