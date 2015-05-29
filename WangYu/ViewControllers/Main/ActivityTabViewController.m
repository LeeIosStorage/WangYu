//
//  ActivityTabViewController.m
//  WangYu
//
//  Created by KID on 15/5/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ActivityTabViewController.h"
#import "WYTabBarViewController.h"
#import "ActivityViewCell.h"
#import "NewsViewCell.h"
#import "MatchWarViewCell.h"
#import "WYEngine.h"
#import "WYActivityInfo.h"
#import "WYNewsInfo.h"
#import "WYMatchWarInfo.h"
#import "WYProgressHUD.h"
#import "MatchDetailViewController.h"
#import "WYAlertView.h"
#import "DVSwitch.h"

@interface ActivityTabViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UITableView *leagueTableView;
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) IBOutlet UITableView *matchTableView;
@property (strong, nonatomic) IBOutlet UIScrollView *containerView;

@property (strong, nonatomic) NSMutableArray *activityInfos;
@property (strong, nonatomic) NSMutableArray *newsInfos;
@property (strong, nonatomic) NSMutableArray *matchInfos;  //约战

@property (strong, nonatomic) DVSwitch *switcher;
@property (assign, nonatomic) NSUInteger selectedIndex;
@end

@implementation ActivityTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSwitchView];
    [self initContainerScrollView];
    _selectedIndex = 0;
    [self refreshDataSourceWithIndex:_selectedIndex];
}

- (void)initSwitchView{
    self.switcher = [DVSwitch switchWithStringsArray:@[@"网竞联赛", @"赛事资讯", @"个人约战"]];
    self.switcher.frame = CGRectMake(12, 7, SCREEN_WIDTH - 12 * 2, 29);
    self.switcher.font = SKIN_FONT_FROMNAME(14);
    self.switcher.cornerRadius = 4;
    self.switcher.sliderOffset = .0;
    [self.switcher.layer setMasksToBounds:YES];
    [self.switcher.layer setCornerRadius:4.0];
    [self.switcher.layer setBorderWidth:0.5]; //边框宽度
    [self.switcher.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
    
    self.switcher.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0];
    self.switcher.sliderColor = [UIColor whiteColor];
    
    self.switcher.labelTextColorInsideSlider = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.switcher.labelTextColorOutsideSlider = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [self.sectionView addSubview:self.switcher];
    WS(weakSelf);
    [self.switcher setPressedHandler:^(NSUInteger index) {
        NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
        weakSelf.selectedIndex = index;
        [weakSelf refreshDataSourceWithIndex:index];
    }];
}

- (void)initContainerScrollView{
    
    _containerView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, _containerView.frame.size.height);
    CGRect frame = self.newsTableView.frame;
    frame.origin.x = SCREEN_WIDTH;
    self.newsTableView.frame = frame;
    
    frame = self.matchTableView.frame;
    frame.origin.x = SCREEN_WIDTH*2;
    self.matchTableView.frame = frame;
}

- (void)refreshDataSourceWithIndex:(NSUInteger)index{
    switch (index) {
        case 0:
            [self getCacheLeagueInfo];
            [self getLeagueInfo];
            break;
        case 1:
            [self getCacheNewsInfo];
            [self getNewsInfo];
            break;
        case 2:
            [self getCacheMatchInfo];
            [self getMatchInfo];
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"精彩活动"];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

//- (void)getHotActivityInfo{
//    WS(weakSelf);
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    [[WYEngine shareInstance] getActivityHotListWithTag:tag];
//    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        //        [WYProgressHUD AlertLoadDone];
//        [self.pullRefreshView finishedLoading];
//        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
//        if (!jsonRet || errorMsg) {
//            if (!errorMsg.length) {
//                errorMsg = @"请求失败";
//            }
//            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
//            return;
//        }
//        
//        weakSelf.activityInfos = [NSMutableArray array];
//        NSArray *activityDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
//        for (NSDictionary *dic in activityDicArray) {
//            if (![dic isKindOfClass:[NSDictionary class]]) {
//                continue;
//            }
//            WYActivityInfo *activityInfo = [[WYActivityInfo alloc] init];
//            [activityInfo setActivityInfoByJsonDic:dic];
//            [weakSelf.activityInfos addObject:activityInfo];
//        }
//        [weakSelf.leagueTableView reloadData];
//    }tag:tag];
//}

- (void)getCacheLeagueInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getActivityListWithPage:1 pageSize:10 tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.activityInfos = [NSMutableArray array];
            NSArray *activityDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in activityDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYActivityInfo *activityInfo = [[WYActivityInfo alloc] init];
                [activityInfo setActivityInfoByJsonDic:dic];
                [weakSelf.activityInfos addObject:activityInfo];
            }
            [weakSelf.leagueTableView reloadData];
        }
    }];
}

- (void)getLeagueInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getActivityListWithPage:1 pageSize:10 tag:tag];
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
        weakSelf.activityInfos = [NSMutableArray array];
        NSArray *activityDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in activityDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYActivityInfo *activityInfo = [[WYActivityInfo alloc] init];
            [activityInfo setActivityInfoByJsonDic:dic];
            [weakSelf.activityInfos addObject:activityInfo];
        }
        [weakSelf.leagueTableView reloadData];
    }tag:tag];
}

- (void)getCacheNewsInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getInfoListWithPage:1 pageSize:10 tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.newsInfos = [NSMutableArray array];
            NSArray *newsDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in newsDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYNewsInfo *newsInfo = [[WYNewsInfo alloc] init];
                [newsInfo setNewsInfoByJsonDic:dic];
                [weakSelf.newsInfos addObject:newsInfo];
            }
            [weakSelf.newsTableView reloadData];
        }
    }];
}

- (void)getNewsInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getInfoListWithPage:1 pageSize:10 tag:tag];
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
        weakSelf.newsInfos = [NSMutableArray array];
        NSArray *newsDicArray = [[jsonRet objectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in newsDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNewsInfo *newsInfo = [[WYNewsInfo alloc] init];
            [newsInfo setNewsInfoByJsonDic:dic];
            [weakSelf.newsInfos addObject:newsInfo];
        }
        [weakSelf.newsTableView reloadData];
    }tag:tag];
}

- (void)getCacheMatchInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getMatchListWithPage:1 pageSize:10 tag:tag];
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

- (void)getMatchInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchListWithPage:1 pageSize:10 tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [WYProgressHUD AlertLoadDone];
//        [self.pullRefreshView finishedLoading];
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
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leagueTableView) {
        return self.activityInfos.count;
    }else if(tableView == self.newsTableView) {
        return self.newsInfos.count;
    }
    return 10;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 44;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leagueTableView) {
        return 158;
    }else if(tableView == self.newsTableView) {
        return 83;
    }
    return 138;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] init];
//
//    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
//    CGRect frame = self.sectionView.frame;
//    frame.size.width = SCREEN_WIDTH;
//    self.sectionView.frame = frame;
//    [view addSubview:self.sectionView];
//    
//    return view;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leagueTableView) {
        static NSString *CellIdentifier = @"ActivityViewCell";
        ActivityViewCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        WYActivityInfo *activityInfo = _activityInfos[indexPath.row];
        cell.activityInfo = activityInfo;
        return cell;
    }else if (tableView == self.newsTableView) {
        static NSString *CellIdentifier = @"NewsViewCell";
        NewsViewCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        WYNewsInfo *newsInfo = _newsInfos[indexPath.row];
        cell.newsInfo = newsInfo;
        return cell;
    }else if (tableView == self.matchTableView) {
        static NSString *CellIdentifier = @"MatchWarViewCell";
        MatchWarViewCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        WYMatchWarInfo *matchInfo = _matchInfos[indexPath.row];
        cell.matchWarInfo = matchInfo;
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.leagueTableView) {
        WYActivityInfo *activityInfo = _activityInfos[indexPath.row];
        MatchDetailViewController *mdVc = [[MatchDetailViewController alloc] init];
        mdVc.activityInfo = activityInfo;
        [self.navigationController pushViewController:mdVc animated:YES];
    }else if (tableView == self.newsTableView) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"赛事资讯" message:@"H5页跳转" cancelButtonTitle:@"确定"];
        [alertView show];
    }else {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"个人约战" message:@"H5页跳转" cancelButtonTitle:@"确定"];
        [alertView show];
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.containerView){
//        CGFloat offset = scrollView.contentOffset.x - _selectedIndex*SCREEN_WIDTH;
//        NSLog(@"===================%lu",(unsigned long)_selectedIndex);
//        NSLog(@"offset=======================%f",offset);
//        if(offset > 0 && _selectedIndex < 2){//右
//            [self.switcher setWillBePressedHandler:^(NSUInteger index) {
//
//            }];
//        }else if(offset < 0 && _selectedIndex > 1){
//            [self.switcher forceSelectedIndex:_selectedIndex-1 animated:YES];
//        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.containerView) {
        if (0==fmod(scrollView.contentOffset.x,SCREEN_WIDTH)){
            _selectedIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
            [self.switcher forceSelectedIndex:_selectedIndex animated:YES];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.containerView) {
        if (decelerate) {
            _selectedIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
        }
    }
}

- (void)transitionToViewAtIndex:(NSUInteger)index{
    [_containerView setContentOffset:CGPointMake(index * SCREEN_WIDTH, 0)];
}

- (void)setSelectedIndex:(NSUInteger)index{
    if (index != self.selectedIndex) {
        _selectedIndex = index;
        [self transitionToViewAtIndex:index];
//        if ([self categoryNecessaryRefreshWith:index-1]) {
//            XECategoryView *cv = _categoryViews[index-1];
//            cv.delegate = self;
//            [cv.pullRefreshView triggerPullToRefresh];
//            //[self getCategoryInfoWithTag:_titles[_selectedIndex-1] andIndex:_selectedIndex-1];
//        }
    }
}

#pragma mark -XETabBarControllerSubVcProtocol
- (void)tabBarController:(WYTabBarViewController *)tabBarController reSelectVc:(UIViewController *)viewController {
    if (viewController == self) {
        if (_selectedIndex == 0) {
            [self.leagueTableView setContentOffset:CGPointMake(0, 0 - self.leagueTableView.contentInset.top) animated:NO];
        }else if (_selectedIndex == 1) {
            [self.newsTableView setContentOffset:CGPointMake(0, 0 - self.newsTableView.contentInset.top) animated:NO];
        }else if (_selectedIndex == 2) {
            [self.matchTableView setContentOffset:CGPointMake(0, 0 - self.matchTableView.contentInset.top) animated:NO];
        }
    }
}

- (void)dealloc {
    WYLog(@"ActivityTabViewController dealloc!!!");
    _leagueTableView.delegate = nil;
    _leagueTableView.dataSource = nil;
    _newsTableView.delegate = nil;
    _newsTableView.dataSource = nil;
    _matchTableView.delegate = nil;
    _matchTableView.dataSource = nil;
}

@end
