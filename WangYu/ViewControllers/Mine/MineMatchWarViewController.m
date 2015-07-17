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
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYLinkerHandler.h"
#import "MatchWarDetailViewController.h"
#import "PublishMatchWarViewController.h"
#import "AppDelegate.h"

#define MATCHWAR_TYPE_PULISH        0
#define MATCHWAR_TYPE_APPLY         1

@interface MineMatchWarViewController ()<UITableViewDataSource,UITableViewDelegate,PublishMatchWarViewControllerDelegate,MatchWarDetailViewControllerDelegate>

@property (strong, nonatomic) WYSegmentedView *segmentedView;

@property (strong, nonatomic) NSMutableArray *publishMatchList;
@property (nonatomic, strong) IBOutlet UITableView *publishTableView;
@property (strong, nonatomic) NSMutableArray *applyMatchList;
@property (nonatomic, strong) IBOutlet UITableView *applyTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  publishNextCursor;
@property (assign, nonatomic) BOOL publishCanLoadMore;
@property (assign, nonatomic) SInt64  applyNextCursor;
@property (assign, nonatomic) BOOL applyCanLoadMore;

@property (assign, nonatomic) BOOL isHavPublishServerSucceed;
@property (assign, nonatomic) BOOL isHavApplyServerSucceed;
@property (strong, nonatomic) IBOutlet UIView *matchWarBlankTipView;
@property (strong, nonatomic) IBOutlet UILabel *matchWarBlankTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *showPublishButton;

- (IBAction)blankHandleAction:(id)sender;

@end

@implementation MineMatchWarViewController

- (void)dealloc{
    WYLog(@"%@ dealloc!!!",NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleUserInfoChanged:(NSNotification *)notification{
    if (_selectedSegmentIndex == 0) {
        [self refreshPublishMatchWarList];
    }else if (_selectedSegmentIndex == 1){
        [self refreshApplyMatchWarList];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //!!!: 登录失效时 重新登录后通知页面刷新 此处用Notification不太合理 待优化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishCancelMatchWar:) name:WY_MATCHWAR_OWNER_CANCLE_NOTIFICATION object:nil];
    
    _selectedSegmentIndex = 0;
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.publishTableView];
    self.pullRefreshView.delegate = self;
    [self.publishTableView addSubview:self.pullRefreshView];
    
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.applyTableView];
    self.pullRefreshView2.delegate = self;
    [self.applyTableView addSubview:self.pullRefreshView2];
    
    [self feedsTypeSwitch:MATCHWAR_TYPE_PULISH needRefreshFeeds:YES];
    
    WS(weakSelf);
    [self.publishTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.publishCanLoadMore) {
            [weakSelf.publishTableView.infiniteScrollingView stopAnimating];
            weakSelf.publishTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getPulishMatchWarListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.publishNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.publishTableView.infiniteScrollingView stopAnimating];
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
                WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
                [matchWarInfo setMatchWarInfoByJsonDic:dic];
                [weakSelf.publishMatchList addObject:matchWarInfo];
            }
            
            weakSelf.publishCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.publishCanLoadMore) {
                weakSelf.publishTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.publishTableView.showsInfiniteScrolling = YES;
                weakSelf.publishNextCursor ++;
            }
            
            [weakSelf.publishTableView reloadData];
            
        } tag:tag];
    }];
    
    [self.applyTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.applyCanLoadMore) {
            [weakSelf.applyTableView.infiniteScrollingView stopAnimating];
            weakSelf.applyTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getApplyMatchWarListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.applyTableView.infiniteScrollingView stopAnimating];
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
                WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
                [matchWarInfo setMatchWarInfoByJsonDic:dic];
                [weakSelf.applyMatchList addObject:matchWarInfo];
            }
            
            weakSelf.applyCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.applyCanLoadMore) {
                weakSelf.applyTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.applyTableView.showsInfiniteScrolling = YES;
                weakSelf.applyNextCursor ++;
            }
            
            [weakSelf.applyTableView reloadData];
            
        } tag:tag];
    }];
    weakSelf.publishTableView.showsInfiniteScrolling = NO;
    weakSelf.applyTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    _segmentedView = [[WYSegmentedView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-220)/2, (self.titleNavBar.frame.size.height-30-7), 220, 30)];
    _segmentedView.items = @[@"我发布的",@"我报名的"];
    WS(weakSelf);
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
    if (tag == MATCHWAR_TYPE_PULISH) {
        //减速率
        self.applyTableView.decelerationRate = 0.0f;
        self.publishTableView.decelerationRate = 1.0f;
        self.applyTableView.hidden = YES;
        self.publishTableView.hidden = NO;
        
        if (_isHavPublishServerSucceed) {
            [self refreshShowUI];
        }
        
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
        
        if (_isHavApplyServerSucceed) {
            [self refreshShowUI];
        }
        
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

- (IBAction)blankHandleAction:(id)sender{
    if (self.selectedSegmentIndex == 0) {
        if ([[WYEngine shareInstance] needUserLogin:@"注册或登录后才能发起约战"]) {
            return;
        }
        PublishMatchWarViewController *publishVc = [[PublishMatchWarViewController alloc] init];
        publishVc.delegate = self;
        [self.navigationController pushViewController:publishVc animated:YES];
    }else if (self.selectedSegmentIndex == 1){
        AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.mainTabViewController.tabBar selectIndex:TAB_INDEX_CHAT];
    }
}

- (void)refreshShowUI{
    
    self.showPublishButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.showPublishButton.titleLabel.textColor = UIColorToRGB(0xf03f3f);
    [self.showPublishButton.layer setMasksToBounds:YES];
    [self.showPublishButton.layer setCornerRadius:4.0];
    [self.showPublishButton.layer setBorderWidth:1.0];
    [self.showPublishButton.layer setBorderColor:UIColorToRGB(0xf03f3f).CGColor];
    
    self.matchWarBlankTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchWarBlankTipLabel.textColor = SKIN_TEXT_COLOR2;
    if (self.selectedSegmentIndex == 0) {
        if (self.publishMatchList && self.publishMatchList.count == 0) {
            
            [self.showPublishButton setTitle:@"发布" forState:UIControlStateNormal];
            CGRect frame = self.matchWarBlankTipView.frame;
            frame.origin.y = 0;
            frame.size.width = SCREEN_WIDTH;
            self.matchWarBlankTipView.frame = frame;
            self.matchWarBlankTipLabel.text = @"发起约战，来证明你的实力吧";
            [self.publishTableView addSubview:self.matchWarBlankTipView];
            
        }else{
            if (self.matchWarBlankTipView.superview) {
                [self.matchWarBlankTipView removeFromSuperview];
            }
        }
    }else if (self.selectedSegmentIndex == 1){
        if (self.applyMatchList && self.applyMatchList.count == 0) {
            [self.showPublishButton setTitle:@"去看看" forState:UIControlStateNormal];
            CGRect frame = self.matchWarBlankTipView.frame;
            frame.origin.y = 0;
            frame.size.width = SCREEN_WIDTH;
            self.matchWarBlankTipView.frame = frame;
            self.matchWarBlankTipLabel.text = @"暂时无报名的约战记录";
            [self.applyTableView addSubview:self.matchWarBlankTipView];
            
        }else{
            if (self.matchWarBlankTipView.superview) {
                [self.matchWarBlankTipView removeFromSuperview];
            }
        }
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
        
        weakSelf.publishCanLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.publishCanLoadMore) {
            weakSelf.publishTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.publishTableView.showsInfiniteScrolling = YES;
            weakSelf.publishNextCursor ++;
        }
        weakSelf.isHavPublishServerSucceed = YES;
        [weakSelf refreshShowUI];
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
        
        weakSelf.applyCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.applyCanLoadMore) {
            weakSelf.applyTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.applyTableView.showsInfiniteScrolling = YES;
            weakSelf.applyNextCursor ++;
        }
        weakSelf.isHavApplyServerSucceed = YES;
        [weakSelf refreshShowUI];
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
    WYMatchWarInfo *matchWarInfo;
    if (tableView == self.applyTableView) {
        matchWarInfo = _applyMatchList[indexPath.row];
    }else{
        matchWarInfo = _publishMatchList[indexPath.row];
    }
    
    MatchWarDetailViewController *mVc = [[MatchWarDetailViewController alloc] init];
    mVc.matchWarInfo = matchWarInfo;
    mVc.delegate = self;
    [self.navigationController pushViewController:mVc animated:YES];
    
//    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/match/web/detail?id=%@&userId=%@&token=%@", [WYEngine shareInstance].baseUrl, matchWarInfo.mId, [WYEngine shareInstance].uid,[WYEngine shareInstance].token] From:self.navigationController];
//    if (vc) {
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark - PublishMatchWarViewControllerDelegate
- (void)publishMatchWarViewControllerWith:(PublishMatchWarViewController*)viewController withMatchWarInfo:(WYMatchWarInfo*)matchWarInfo{
    [self refreshPublishMatchWarList];
}

#pragma mark - MatchWarDetailViewControllerDelegate
- (void)matchWarDetailViewControllerWith:(MatchWarDetailViewController*)viewController withMatchWarInfo:(WYMatchWarInfo*)matchWarInfo applyCountAdd:(BOOL)add{
    
    BOOL isExist = NO;
    for (WYMatchWarInfo *info in _applyMatchList) {
        if ([info.mId isEqualToString:matchWarInfo.mId]) {
            isExist = YES;
            if (!add) {
                [_applyMatchList removeObject:info];
                [self.applyTableView reloadData];
            }
            break;
        }
    }
    if (!isExist && add) {
        [_applyMatchList addObject:matchWarInfo];
        [self.applyTableView reloadData];
    }
}

#pragma mark -NSNotification
- (void)handleFinishCancelMatchWar:(NSNotification *)notification {
    WYMatchWarInfo *matchWarInfo = notification.object;
    for (WYMatchWarInfo *info in _publishMatchList) {
        if ([info.mId isEqualToString:matchWarInfo.mId]) {
            [_publishMatchList removeObject:info];
            [self.publishTableView reloadData];
            [self refreshShowUI];
            break;
        }
    }
}

@end
