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
#import "TopicsViewController.h"
#import "WYAlertView.h"
#import "DVSwitch.h"
#import "WYScrollPage.h"
#import "WYLinkerHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYUserGuideConfig.h"
#import "AppDelegate.h"

@interface ActivityTabViewController ()<UITableViewDataSource,UITableViewDelegate,WYScrollPageDelegate>{
    WYScrollPage *scrollPageView;
    BOOL bClicked;
}

@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (nonatomic, strong) IBOutlet UIView *adsViewContainer;
@property (strong, nonatomic) IBOutlet UITableView *leagueTableView;
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) IBOutlet UITableView *matchTableView;
@property (strong, nonatomic) IBOutlet UIScrollView *containerView;
@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (strong, nonatomic) IBOutlet UIView *guideView;
@property (strong, nonatomic) IBOutlet UIView *guideImageView;

@property (strong, nonatomic) NSMutableArray *activityInfos;
@property (strong, nonatomic) NSMutableArray *newsInfos;
@property (strong, nonatomic) NSMutableArray *matchInfos;  //约战
@property (nonatomic, strong) NSMutableArray* adsNewsArray;   //广告数据源

@property (strong, nonatomic) DVSwitch *switcher;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (assign, nonatomic) SInt32 leagueCursor;
@property (assign, nonatomic) BOOL leagueLoadMore;
@property (assign, nonatomic) SInt32 newsCursor;
@property (assign, nonatomic) BOOL newsLoadMore;
@property (assign, nonatomic) SInt32 matchCursor;
@property (assign, nonatomic) BOOL matchLoadMore;

- (IBAction)publicAction:(id)sender;
- (IBAction)newGuideAction:(id)sender;

@end

@implementation ActivityTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSwitchView];
    [self initContainerScrollView];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.leagueTableView];
    self.pullRefreshView.delegate = self;
    [self.leagueTableView addSubview:self.pullRefreshView];
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.newsTableView];
    self.pullRefreshView2.delegate = self;
    [self.newsTableView addSubview:self.pullRefreshView2];
    self.pullRefreshView3 = [[PullToRefreshView alloc] initWithScrollView:self.matchTableView];
    self.pullRefreshView3.delegate = self;
    [self.matchTableView addSubview:self.pullRefreshView3];
    
    _selectedIndex = 0;
    [self refreshDataSourceWithIndex:_selectedIndex];
    
    WS(weakSelf);
    [self.leagueTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.leagueLoadMore) {
            [weakSelf.leagueTableView.infiniteScrollingView stopAnimating];
            weakSelf.leagueTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getActivityListWithPage:weakSelf.leagueCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.leagueTableView.infiniteScrollingView stopAnimating];
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
                [weakSelf.activityInfos addObject:activityInfo];
            }
            [weakSelf.leagueTableView reloadData];
            weakSelf.leagueLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.leagueLoadMore) {
                weakSelf.leagueTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.leagueTableView.showsInfiniteScrolling = YES;
                weakSelf.leagueCursor ++;
            }
        } tag:tag];
    }];
    
    [self.newsTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.newsLoadMore) {
            [weakSelf.newsTableView.infiniteScrollingView stopAnimating];
            weakSelf.newsTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getInfoListWithPage:weakSelf.newsCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.newsTableView.infiniteScrollingView stopAnimating];
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
                WYNewsInfo *newsInfo = [[WYNewsInfo alloc] init];
                [newsInfo setNewsInfoByJsonDic:dic];
                [weakSelf.newsInfos addObject:newsInfo];
            }
            [weakSelf.newsTableView reloadData];
            weakSelf.newsLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.newsLoadMore) {
                weakSelf.newsTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.newsTableView.showsInfiniteScrolling = YES;
                weakSelf.newsCursor ++;
            }
        } tag:tag];
    }];
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
    weakSelf.leagueTableView.showsInfiniteScrolling = NO;
    weakSelf.newsTableView.showsInfiniteScrolling = NO;
    weakSelf.matchTableView.showsInfiniteScrolling = NO;
}

- (void)initSwitchView{
//    self.switcher = [DVSwitch switchWithStringsArray:@[@"赛事报名", @"赛事资讯", @"个人约战"]];
    self.switcher = [DVSwitch switchWithStringsArray:@[@"赛事报名", @"赛事资讯"]];
    self.switcher.frame = CGRectMake(12, 7, SCREEN_WIDTH - 12 * 2, 30);
    self.switcher.font = SKIN_FONT_FROMNAME(14);
    self.switcher.cornerRadius = 4;
    self.switcher.sliderOffset = 0.5;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)initContainerScrollView{
    CGRect frame = _containerView.frame;
    frame.size.height = SCREEN_HEIGHT - 50 - CGRectGetHeight(self.titleNavBar.frame) - CGRectGetHeight(self.sectionView.frame);
    _containerView.frame = frame;
//    _containerView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, _containerView.frame.size.height);
        _containerView.contentSize = CGSizeMake(SCREEN_WIDTH * 2, _containerView.frame.size.height);
    
    frame = self.newsTableView.frame;
    frame.origin.x = SCREEN_WIDTH;
    self.newsTableView.frame = frame;
//    self.newsTableView.tableHeaderView = self.adsViewContainer;
    
    frame = self.matchTableView.frame;
    frame.origin.x = SCREEN_WIDTH*2;
    self.matchTableView.frame = frame;
    
    self.floatView.layer.masksToBounds = YES;
    self.floatView.layer.cornerRadius = self.floatView.frame.size.width/2;
    self.floatView.clipsToBounds = YES;
    self.floatView.contentMode = UIViewContentModeScaleAspectFill;
    frame = self.floatView.frame;
    CGFloat temp = .0;
    if (SCREEN_WIDTH > 320 && SCREEN_WIDTH < 414) {
        temp = 54;
    }else if (SCREEN_WIDTH >= 414){
        temp = 95;
    }
    frame.origin.x = SCREEN_WIDTH*3 - 12 - self.floatView.frame.size.width - temp;
    self.floatView.frame = frame;
}

///刷新广告位
- (void)refreshAdsScrollView {
    if (!_adsNewsArray.count) {
        self.newsTableView.tableHeaderView = nil;
        return;
    }
    //移除老view
    for (UIView *view in _adsViewContainer.subviews) {
        [view removeFromSuperview];
    }
    
    CGRect frame = _adsViewContainer.bounds;
    scrollPageView = [[WYScrollPage alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    scrollPageView.duration = 4;
    scrollPageView.adsType = AdsType_Theme;
    scrollPageView.dataArray = _adsNewsArray;
    scrollPageView.delegate = self;
    [_adsViewContainer addSubview:scrollPageView];
    
    self.newsTableView.tableHeaderView = _adsViewContainer;
//    [self.newsTableView reloadData];
}

- (void)refreshDataSourceWithIndex:(NSUInteger)index{
    switch (index) {
        case 0:
            [self getCacheLeagueInfoList];
            [self getLeagueInfoList];
            break;
        case 1:
            [self getCacheNewsInfoList];
            [self getNewsInfoList];
            break;
        case 2:
            if (!bClicked) {
                [self refreshNewGuideView:NO];
            }
            [self getCacheMatchInfoList];
            [self getMatchInfoList];
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

- (void)refreshNewGuideView:(BOOL)isNext {
    bClicked = YES;
    self.guideView.frame = [UIScreen mainScreen].bounds;
    BOOL isShow = [[WYUserGuideConfig shareInstance] newPeopleGuideShowForVcType:@"activityTabView"];
    if (isShow) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:self.guideView];
        UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
        [self.guideImageView addGestureRecognizer:gestureRecongnizer];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.guideView.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.guideView.superview) {
                [self.guideView removeFromSuperview];
                if (isNext) {
                    //...
                }
            }
        }];
    }
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"activityTabView"];
    [self refreshNewGuideView:NO];
}

- (IBAction)newGuideAction:(id)sender {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"activityTabView"];
    [self refreshNewGuideView:NO];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)getCacheLeagueInfoList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getActivityListWithPage:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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

- (void)getLeagueInfoList{
    self.leagueCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getActivityListWithPage:weakSelf.leagueCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        
        weakSelf.leagueLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.leagueLoadMore) {
            weakSelf.leagueTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.leagueTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.leagueCursor ++;
        }
    }tag:tag];
}

- (void)getCacheNewsInfoList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getInfoListWithPage:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            //解析数据
//            weakSelf.adsNewsArray = [NSMutableArray array];
//            NSArray*themeDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"hots"];
//            for (NSDictionary *dic  in themeDicArray) {
//                if (![dic isKindOfClass:[NSDictionary class]]) {
//                    continue;
//                }
//                WYNewsInfo *hotsInfo = [[WYNewsInfo alloc] init];
//                [hotsInfo setNewsInfoByJsonDic:dic];
//                [weakSelf.adsNewsArray addObject:hotsInfo];
//            }
//            if (weakSelf.adsNewsArray.count) {
//                [weakSelf refreshAdsScrollView];
//            }
            
            weakSelf.newsInfos = [NSMutableArray array];
            NSArray *newsDicArray = [[[jsonRet objectForKey:@"object"] objectForKey:@"infos"] arrayObjectForKey:@"list"];
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

- (void)getNewsInfoList{
    self.newsCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getInfoListWithPage:weakSelf.newsCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [WYProgressHUD AlertLoadDone];
        [self.pullRefreshView2 finishedLoading];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
//        [weakSelf.adsNewsArray removeAllObjects];
//        //解析数据
//        weakSelf.adsNewsArray = [NSMutableArray array];
//        NSArray*themeDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"hots"];
//        for (NSDictionary *dic  in themeDicArray) {
//            if (![dic isKindOfClass:[NSDictionary class]]) {
//                continue;
//            }
//            WYNewsInfo *hotsInfo = [[WYNewsInfo alloc] init];
//            [hotsInfo setNewsInfoByJsonDic:dic];
//            [weakSelf.adsNewsArray addObject:hotsInfo];
//        }
//        if (weakSelf.adsNewsArray.count) {
//            [weakSelf refreshAdsScrollView];
//        }

        weakSelf.newsInfos = [NSMutableArray array];
        NSArray *newsDicArray = [[[jsonRet objectForKey:@"object"] objectForKey:@"infos"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in newsDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNewsInfo *newsInfo = [[WYNewsInfo alloc] init];
            [newsInfo setNewsInfoByJsonDic:dic];
            [weakSelf.newsInfos addObject:newsInfo];
        }
        
        weakSelf.newsLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"infos"] boolValueForKey:@"isLast"];
        if (weakSelf.newsLoadMore) {
            weakSelf.newsTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.newsTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.newsCursor ++;
        }
        [weakSelf.newsTableView reloadData];
    }tag:tag];
}

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

- (void)getMatchInfoList{
    self.matchCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchListWithPage:weakSelf.matchCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [WYProgressHUD AlertLoadDone];
        [self.pullRefreshView3 finishedLoading];
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
    }else if (tableView == self.matchTableView) {
        return self.matchInfos.count;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leagueTableView) {
        return 221;
    }else if(tableView == self.newsTableView) {
        return 83;
    }
    return 138;
}

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
        if(_matchInfos.count > 0){
            WYMatchWarInfo *matchInfo = _matchInfos[indexPath.row];
            cell.matchWarInfo = matchInfo;
        }
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
        WYNewsInfo *newsInfo = _newsInfos[indexPath.row];
        if (newsInfo.isSubject) {
            TopicsViewController *tVc = [[TopicsViewController alloc] init];
            tVc.newsInfo = newsInfo;
            [self.navigationController pushViewController:tVc animated:YES];
        }else {
            id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/info/web/detail?id=%@&title=%@&imageUrl=%@&brief=%@", [WYEngine shareInstance].baseUrl, newsInfo.nid,newsInfo.title,newsInfo.newsImageUrl,newsInfo.brief] From:self.navigationController];
            if (vc) {
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else {
        WYMatchWarInfo *matchWarInfo = _matchInfos[indexPath.row];
        id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/match/web/detail?id=%@&userId=%@&token=%@", [WYEngine shareInstance].baseUrl, matchWarInfo.mId, [WYEngine shareInstance].uid,[WYEngine shareInstance].token] From:self.navigationController];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }
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
    }
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self getLeagueInfoList];
    }else if (view == self.pullRefreshView2) {
        [self getNewsInfoList];
    }else if (view == self.pullRefreshView3) {
        [self getMatchInfoList];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _leagueTableView.delegate = nil;
    _leagueTableView.dataSource = nil;
    _newsTableView.delegate = nil;
    _newsTableView.dataSource = nil;
    _matchTableView.delegate = nil;
    _matchTableView.dataSource = nil;
}

- (IBAction)publicAction:(id)sender {
    if ([[WYEngine shareInstance] needUserLogin:@"注册或登录后才能发起约战"]) {
        return;
    }
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/match/web/release?userId=%@&token=%@", [WYEngine shareInstance].baseUrl, [WYEngine shareInstance].uid,[WYEngine shareInstance].token] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:WY_NEWS_SHOW_ADS_VIEW_NOTIFICATION object:[NSNumber numberWithBool:YES]];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] postNotificationName:WY_NEWS_STOP_ADS_VIEW_NOTIFICATION object:[NSNumber numberWithBool:YES]];
    [super viewDidDisappear:animated];
}

- (void)applicationWillResignActive:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:WY_NEWS_STOP_ADS_VIEW_NOTIFICATION object:[NSNumber numberWithBool:YES]];
}

- (void)appWillEnterForeground:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:WY_NEWS_SHOW_ADS_VIEW_NOTIFICATION object:[NSNumber numberWithBool:YES]];
}

@end
