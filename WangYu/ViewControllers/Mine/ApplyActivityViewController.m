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

@interface ApplyActivityViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *applyActivityInfos;
@property (assign, nonatomic) SInt64  applyNextCursor;
@property (assign, nonatomic) BOOL applyCanLoadMore;

@property (strong, nonatomic) IBOutlet UIView *activityBlankTipView;
@property (strong, nonatomic) IBOutlet UILabel *activityBlankTipLabel;

@end

@implementation ApplyActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _applyActivityInfos = [[NSMutableArray alloc] init];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.pullRefreshView.delegate = self;
    [self.tableView addSubview:self.pullRefreshView];
    
    [self getCacheApplyActivityList];
    [self refreshApplyActivityInfos];
    
    WS(weakSelf);
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.applyCanLoadMore) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            weakSelf.tableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getApplyActivityListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
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
                weakSelf.tableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.tableView.showsInfiniteScrolling = YES;
                weakSelf.applyNextCursor ++;
            }
            
            [weakSelf.tableView reloadData];
            
        } tag:tag];
    }];
    weakSelf.tableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"我的报名赛事"];
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
    if (self.applyActivityInfos && self.applyActivityInfos.count == 0) {
        CGRect frame = self.activityBlankTipView.frame;
        frame.origin.y = 0;
        frame.size.width = SCREEN_WIDTH;
        self.activityBlankTipView.frame = frame;
        [self.tableView addSubview:self.activityBlankTipView];
        
    }else{
        if (self.activityBlankTipView.superview) {
            [self.activityBlankTipView removeFromSuperview];
        }
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
            [weakSelf.tableView reloadData];
        }
    }];
}
-(void)refreshApplyActivityInfos{
    _applyNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getApplyActivityListWithUid:[WYEngine shareInstance].uid page:(int)_applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
            weakSelf.tableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.tableView.showsInfiniteScrolling = YES;
            weakSelf.applyNextCursor ++;
        }
        [weakSelf refreshShowUI];
        [weakSelf.tableView reloadData];
        
    }tag:tag];
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshApplyActivityInfos];
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
    return _applyActivityInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 83;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplyActivityViewCell";
    ApplyActivityViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    WYActivityInfo *activityInfo = _applyActivityInfos[indexPath.row];
    cell.activityInfo = activityInfo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYActivityInfo *activityInfo = _applyActivityInfos[indexPath.row];
    MatchDetailViewController *mdVc = [[MatchDetailViewController alloc] init];
    mdVc.activityInfo = activityInfo;
    [self.navigationController pushViewController:mdVc animated:YES];
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
