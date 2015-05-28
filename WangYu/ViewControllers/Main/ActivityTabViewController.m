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
#import "WYEngine.h"
#import "WYActivityInfo.h"
#import "WYNewsInfo.h"
#import "WYMatchWarInfo.h"
#import "WYProgressHUD.h"
#import "MatchDetailViewController.h"
#import "WYAlertView.h"

@interface ActivityTabViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UITableView *leagueTableView;
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) IBOutlet UITableView *matchTableView;

@property (strong, nonatomic) NSMutableArray *activityInfos;
@property (strong, nonatomic) NSMutableArray *newsInfos;
@property (strong, nonatomic) NSMutableArray *matchInfos;  //约战

@end

@implementation ActivityTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self getLeagueInfo];
    self.leagueTableView.hidden = YES;
    self.newsTableView.hidden = YES;
//    self.promiseTableView.hidden = YES;
//    [self getNewsInfo];
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

- (void)getMatchInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchListWithPage:1 pageSize:10 tag:tag];
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
    return 44;
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

@end
