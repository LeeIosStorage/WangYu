//
//  MatchWarViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchWarViewController.h"
#import "WYEngine.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYProgressHUD.h"
#import "WYMatchWarInfo.h"
#import "WYLinkerHandler.h"
#import "MatchWarViewCell.h"
#import "WYTabBarViewController.h"
#import "PublishMatchWarViewController.h"
#import "MatchWarDetailViewController.h"

@interface MatchWarViewController ()<UITableViewDataSource,UITableViewDelegate,PublishMatchWarViewControllerDelegate,MatchWarDetailViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *matchTableView;
@property (strong, nonatomic) NSMutableArray *matchInfos;  //约战

@property (assign, nonatomic) SInt32 matchCursor;
@property (assign, nonatomic) BOOL matchLoadMore;

@end

@implementation MatchWarViewController

- (void)dealloc {
    WYLog(@"%@ dealloc!!!",NSStringFromClass([self class]));
    _matchTableView.delegate = nil;
    _matchTableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishCancelMatchWar:) name:WY_MATCHWAR_OWNER_CANCLE_NOTIFICATION object:nil];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.matchTableView];
    self.pullRefreshView.delegate = self;
    [self.matchTableView addSubview:self.pullRefreshView];
    
//    UIEdgeInsets inset = UIEdgeInsetsMake(self.titleNavBar.frame.size.height - 10, 0, 0, 0);
//    [self setContentInsetForScrollView:self.matchTableView inset:inset];
    
    [self getCacheMatchInfoList];
    [self refreshMatchInfoList];
    
    WS(weakSelf);
    [self.matchTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.matchLoadMore) {
            [weakSelf.matchTableView.infiniteScrollingView stopAnimating];
            weakSelf.matchTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMatchListWithPage:weakSelf.matchCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.matchTableView.infiniteScrollingView stopAnimating];
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
                WYMatchWarInfo *warInfo = [[WYMatchWarInfo alloc] init];
                [warInfo setMatchWarInfoByJsonDic:dic];
                [weakSelf.matchInfos addObject:warInfo];
            }
            [weakSelf.matchTableView reloadData];
            weakSelf.matchLoadMore = [[jsonRet dictionaryObjectForKey:@"object"] boolValueForKey:@"isLast"];
            if (weakSelf.matchLoadMore) {
                weakSelf.matchTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.matchTableView.showsInfiniteScrolling = YES;
                weakSelf.matchCursor ++;
            }
        } tag:tag];
    }];
    weakSelf.matchTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"个人约战"];
    [self setRightButtonWithImageName:@"matchWar_publish_iocn" selector:@selector(publishMatch:)];
    [self setRightButtonWithTitle:@" 发布"];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
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
-(void)publishMatch:(id)sender{
    if ([[WYEngine shareInstance] needUserLogin:@"注册或登录后才能发起约战"]) {
        return;
    }
    PublishMatchWarViewController *publishVc = [[PublishMatchWarViewController alloc] init];
    publishVc.delegate = self;
    [self.navigationController pushViewController:publishVc animated:YES];
    
}
#pragma mark - request
- (void)getCacheMatchInfoList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getMatchListWithPage:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.matchInfos = [NSMutableArray array];
            NSArray *matchDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in matchDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYMatchWarInfo *matchInfo = [[WYMatchWarInfo alloc] init];
                [matchInfo setMatchWarInfoByJsonDic:dic];
                [weakSelf.matchInfos addObject:matchInfo];
            }
            [weakSelf.matchTableView reloadData];
        }
    }];
}

- (void)refreshMatchInfoList{
    self.matchCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchListWithPage:weakSelf.matchCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        weakSelf.matchInfos = [NSMutableArray array];
        NSArray *matchDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in matchDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYMatchWarInfo *matchInfo = [[WYMatchWarInfo alloc] init];
            [matchInfo setMatchWarInfoByJsonDic:dic];
            [weakSelf.matchInfos addObject:matchInfo];
        }
        [weakSelf.matchTableView reloadData];
        weakSelf.matchLoadMore = [[jsonRet objectForKey:@"object"]  boolValueForKey:@"isLast"];
        if (weakSelf.matchLoadMore) {
            weakSelf.matchTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.matchTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.matchCursor ++;
        }
    }tag:tag];
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshMatchInfoList];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 138;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchWarViewCell";
    MatchWarViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if(_matchInfos.count > 0){
        WYMatchWarInfo *matchInfo = _matchInfos[indexPath.row];
        cell.matchWarInfo = matchInfo;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYMatchWarInfo *matchWarInfo = _matchInfos[indexPath.row];
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
    [self refreshMatchInfoList];
}

#pragma mark - MatchWarDetailViewControllerDelegate
- (void)matchWarDetailViewControllerWith:(MatchWarDetailViewController*)viewController withMatchWarInfo:(WYMatchWarInfo*)matchWarInfo applyCountAdd:(BOOL)add{
    for (WYMatchWarInfo *info in _matchInfos) {
        if ([info.mId isEqualToString:matchWarInfo.mId]) {
            info.applyCount = matchWarInfo.applyCount;
            [self.matchTableView reloadData];
            break;
        }
    }
}

#pragma mark -NSNotification
- (void)handleFinishCancelMatchWar:(NSNotification *)notification {
    WYMatchWarInfo *matchWarInfo = notification.object;
    for (WYMatchWarInfo *info in _matchInfos) {
        if ([info.mId isEqualToString:matchWarInfo.mId]) {
            [_matchInfos removeObject:info];
            [self.matchTableView reloadData];
            break;
        }
    }
}

@end
