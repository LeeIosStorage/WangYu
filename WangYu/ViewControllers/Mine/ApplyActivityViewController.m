//
//  ApplyActivityViewController.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ApplyActivityViewController.h"
#import "WYActivityInfo.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "ApplyActivityViewCell.h"
#import "UIImageView+WebCache.h"
#import "MatchDetailViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYTeamInfo.h"
#import "MatchTeamsCell.h"
#import "WYSegmentedView.h"
#import "WYAlertView.h"

#define MATCH_TYPE_ACTIVITY           0
#define MATCH_TYPE_TEAM               1

@interface ApplyActivityViewController ()<UITableViewDataSource,UITableViewDelegate,MatchTeamsCellDelegate>

@property (nonatomic, strong) IBOutlet UITableView *activityTableView;
@property (strong, nonatomic) IBOutlet UITableView *teamTableView;

@property (nonatomic, strong) NSMutableArray *applyActivityInfos;
@property (nonatomic, strong) NSMutableArray *teamInfos;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt32  applyNextCursor;
@property (assign, nonatomic) SInt32  teamNextCursor;
@property (assign, nonatomic) BOOL applyCanLoadMore;
@property (assign, nonatomic) BOOL teamCanLoadMore;

@property (assign, nonatomic) BOOL aRespondSucceed;
@property (assign, nonatomic) BOOL tRespondSucceed;
@property (strong, nonatomic) IBOutlet UIView *activityBlankTipView;
@property (strong, nonatomic) IBOutlet UILabel *activityBlankTipLabel;

@end

@implementation ApplyActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _selectedSegmentIndex = 0;
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.activityTableView];
    self.pullRefreshView.delegate = self;
    [self.activityTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.teamTableView];
    self.pullRefreshView2.delegate = self;
    [self.teamTableView addSubview:self.pullRefreshView2];
    
//    [self getCacheApplyActivityList];
//    [self refreshApplyActivityInfos];
    
    [self feedsTypeSwitch:MATCH_TYPE_ACTIVITY needRefreshFeeds:YES];
    
    WS(weakSelf);
    [self.activityTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.applyCanLoadMore) {
            [weakSelf.activityTableView.infiniteScrollingView stopAnimating];
            weakSelf.activityTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getApplyActivityListWithUid:[WYEngine shareInstance].uid page:weakSelf.applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.activityTableView.infiniteScrollingView stopAnimating];
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
                WYActivityInfo *activityInfo = [[WYActivityInfo alloc] init];
                [activityInfo setActivityInfoByJsonDic:dic];
                [weakSelf.applyActivityInfos addObject:activityInfo];
            }
            
            weakSelf.applyCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.applyCanLoadMore) {
                weakSelf.activityTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.activityTableView.showsInfiniteScrolling = YES;
                weakSelf.applyNextCursor ++;
            }
            
            [weakSelf.activityTableView reloadData];
            
        } tag:tag];
    }];
    
    [self.teamTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.teamCanLoadMore) {
            [weakSelf.teamTableView.infiniteScrollingView stopAnimating];
            weakSelf.teamTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMatchTeamListWithUid:[WYEngine shareInstance].uid page:weakSelf.teamNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.teamTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"teamList"];
            for (NSDictionary *dic in object) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYTeamInfo *teamInfo = [[WYTeamInfo alloc] init];
                [teamInfo setTeamInfoByJsonDic:dic];
                [weakSelf.teamInfos addObject:teamInfo];
            }
            
            weakSelf.teamCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.teamCanLoadMore) {
                weakSelf.teamTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.teamTableView.showsInfiniteScrolling = YES;
                weakSelf.teamNextCursor ++;
            }
            
            [weakSelf.teamTableView reloadData];
            
        } tag:tag];
    }];
    
    weakSelf.activityTableView.showsInfiniteScrolling = NO;
    weakSelf.teamTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    WYSegmentedView *segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    segmentedView.items = @[@"报名赛事",@"我的战队"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - custom
- (void)refreshShowUI{
    self.activityBlankTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.activityBlankTipLabel.textColor = SKIN_TEXT_COLOR2;
    if (self.selectedSegmentIndex == 0) {
        if (self.applyActivityInfos && self.applyActivityInfos.count == 0) {
            CGRect frame = self.activityBlankTipView.frame;
            frame.origin.y = 0;
            frame.size.width = SCREEN_WIDTH;
            self.activityBlankTipView.frame = frame;
            [self.activityTableView addSubview:self.activityBlankTipView];
            
        }else{
            if (self.activityBlankTipView.superview) {
                [self.activityBlankTipView removeFromSuperview];
            }
        }
    }else if (self.selectedSegmentIndex == 1) {
        
    }
}

#pragma mark - request
-(void)getCacheApplyActivityList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getApplyActivityListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.applyActivityInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYActivityInfo *activityInfo = [[WYActivityInfo alloc] init];
                [activityInfo setActivityInfoByJsonDic:dic];
                [weakSelf.applyActivityInfos addObject:activityInfo];
            }
            [weakSelf.activityTableView reloadData];
        }
    }];
}

-(void)refreshApplyActivityInfos{
    _applyNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getApplyActivityListWithUid:[WYEngine shareInstance].uid page:_applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        
        weakSelf.applyActivityInfos = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            WYActivityInfo *activityInfo = [[WYActivityInfo alloc] init];
            [activityInfo setActivityInfoByJsonDic:dic];
            [weakSelf.applyActivityInfos addObject:activityInfo];
        }
        
        weakSelf.applyCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.applyCanLoadMore) {
            weakSelf.activityTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.activityTableView.showsInfiniteScrolling = YES;
            weakSelf.applyNextCursor ++;
        }
        weakSelf.aRespondSucceed = YES;
        [weakSelf refreshShowUI];
        [weakSelf.activityTableView reloadData];
        
    }tag:tag];
}

- (void)getCacheApplyTeamList {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getMatchTeamListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.teamInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYTeamInfo *teamInfo = [[WYTeamInfo alloc] init];
                [teamInfo setTeamInfoByJsonDic:dic];
                [weakSelf.teamInfos addObject:teamInfo];
            }
            [weakSelf.teamTableView reloadData];
        }
    }];
}

- (void)refreshApplyTeamInfos {
    _teamNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchTeamListWithUid:[WYEngine shareInstance].uid page:_teamNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        
        weakSelf.teamInfos = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"teamList"];
        for (NSDictionary *dic in object) {
            WYTeamInfo *teamInfo = [[WYTeamInfo alloc] init];
            [teamInfo setTeamInfoByJsonDic:dic];
            [weakSelf.teamInfos addObject:teamInfo];
        }
        
        weakSelf.teamCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.teamCanLoadMore) {
            weakSelf.teamTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.teamTableView.showsInfiniteScrolling = YES;
            weakSelf.teamNextCursor ++;
        }
        weakSelf.tRespondSucceed = YES;
        [weakSelf refreshShowUI];
        [weakSelf.teamTableView reloadData];
        
    }tag:tag];
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshApplyActivityInfos];
    }else if (view == self.pullRefreshView2) {
        [self refreshApplyTeamInfos];
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
    if (tableView == self.teamTableView) {
        return _teamInfos.count;
    }
    return _applyActivityInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.teamTableView) {
        return 108;
    }
    return 83;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.activityTableView) {
        static NSString *CellIdentifier = @"ApplyActivityViewCell";
        ApplyActivityViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        WYActivityInfo *activityInfo = _applyActivityInfos[indexPath.row];
        cell.activityInfo = activityInfo;
        return cell;
    }else if (tableView == self.teamTableView) {
        static NSString *CellIdentifier = @"MatchTeamsCell";
        MatchTeamsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        WYTeamInfo *teamInfo = _teamInfos[indexPath.row];
        cell.isMine = YES;
        cell.teamInfo = teamInfo;
        cell.delegate = self;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.activityTableView) {
        WYActivityInfo *activityInfo = _applyActivityInfos[indexPath.row];
        MatchDetailViewController *mdVc = [[MatchDetailViewController alloc] init];
        mdVc.activityInfo = activityInfo;
        [self.navigationController pushViewController:mdVc animated:YES];
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark - MatchTeamsCellDelegate
- (void)MatchTeamsCellExitClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.teamTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYTeamInfo* teamInfo = _teamInfos[indexPath.row];
    WS(weakSelf);
    WYAlertView *alert = [[WYAlertView alloc] initWithTitle:nil message:teamInfo.isLeader?@"确认解散战队吗?":@"确认离开战队吗?"  cancelButtonTitle:@"取消" cancelBlock:^{

    } okButtonTitle:@"确认" okBlock:^{
        [weakSelf exitMatchTeamWith:teamInfo indexPath:indexPath];
    }];
    [alert show];
}

- (void)MatchTeamsCellEditClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.teamTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
//    WYTeamInfo* teamInfo = _teamInfos[indexPath.row];
}

- (void)exitMatchTeamWith:(WYTeamInfo *)teamInfo indexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] exitMatchTeamWithUid:[WYEngine shareInstance].uid teamId:teamInfo.teamId tag:tag];
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
        if (teamInfo.isLeader) {
            [WYProgressHUD AlertSuccess:@"战队已解散" At:weakSelf.view];
        } else {
            [WYProgressHUD AlertSuccess:@"战队已退出" At:weakSelf.view];
        }
        [weakSelf.teamInfos removeObjectAtIndex:indexPath.row];
        [weakSelf.teamTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }tag:tag];
}

- (void)segmentedControlAction:(UISegmentedControl *)sender{
    
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

-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == MATCH_TYPE_ACTIVITY) {
        //减速率
        self.teamTableView.decelerationRate = 0.0f;
        self.activityTableView.decelerationRate = 1.0f;
        self.teamTableView.hidden = YES;
        self.activityTableView.hidden = NO;
        
        if (_aRespondSucceed) {
            [self refreshShowUI];
        }
        if (!_applyActivityInfos) {
            [self getCacheApplyActivityList];
            [self refreshApplyActivityInfos];
            return;
        }
        if (needRefresh) {
            [self refreshApplyActivityInfos];
        }
    }else if (tag == MATCH_TYPE_TEAM){
        
        self.teamTableView.decelerationRate = 1.0f;
        self.activityTableView.decelerationRate = 0.0f;
        self.activityTableView.hidden = YES;
        self.teamTableView.hidden = NO;
        
        if (_tRespondSucceed) {
            [self refreshShowUI];
        }
        if (!_teamInfos) {
            [self getCacheApplyTeamList];
            [self refreshApplyTeamInfos];
            return;
        }
        if (needRefresh) {
            [self refreshApplyTeamInfos];
        }
    }
}

-(void)dealloc {
    _teamTableView.delegate = nil;
    _teamTableView.dataSource = nil;
    _activityTableView.delegate = nil;
    _activityTableView.dataSource = nil;
}

@end
