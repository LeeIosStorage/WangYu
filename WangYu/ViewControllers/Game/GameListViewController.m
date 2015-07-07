//
//  GameListViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/7.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameListViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYGameInfo.h"
#import "GameListViewCell.h"
#import "GameDetailsViewController.h"

@interface GameListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *gameCommendInfos;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation GameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.pullRefreshView.delegate = self;
    [self.tableView addSubview:self.pullRefreshView];
    
    
    [self getCacheGameList];
    [self refreshGameInfos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"手游推荐"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getCacheGameList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getGameListWithUid:[WYEngine shareInstance].uid page:1 pageSize:20 tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.gameCommendInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
                [gameInfo setGameInfoByJsonDic:dic];
                [weakSelf.gameCommendInfos addObject:gameInfo];
            }
            [weakSelf.tableView reloadData];
        }
    }];
}
-(void)refreshGameInfos{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getGameListWithUid:[WYEngine shareInstance].uid page:1 pageSize:20 tag:tag];
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
        weakSelf.gameCommendInfos = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
            [gameInfo setGameInfoByJsonDic:dic];
            [weakSelf.gameCommendInfos addObject:gameInfo];
        }
        [weakSelf.tableView reloadData];
        
    }tag:tag];
}

-(void)getGameDownloadUrl:(WYGameInfo*)gameInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getGameDownloadUrlWithGameId:gameInfo.gameId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"数据请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        NSString *iosDownloadUrl = [object stringObjectForKey:@"url_ios"];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:iosDownloadUrl]];
        gameInfo.downloadCount ++;
        [weakSelf.tableView reloadData];
        
    }tag:tag];
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshGameInfos];
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
    return _gameCommendInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GameListViewCell";
    GameListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        [cell.downloadButton addTarget:self action:@selector(handleClickAt:event:) forControlEvents:UIControlEventTouchUpInside];
    }
    WYGameInfo *gameInfo = _gameCommendInfos[indexPath.row];
    cell.gameInfo = gameInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    WYGameInfo *gameInfo = _gameCommendInfos[indexPath.row];
    GameDetailsViewController *gameVc = [[GameDetailsViewController alloc] init];
    gameVc.gameInfo = gameInfo;
    [self.navigationController pushViewController:gameVc animated:YES];
}

-(void)handleClickAt:(id)sender event:(id)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil){
        
        WYGameInfo *gameInfo = _gameCommendInfos[indexPath.row];
        [self getGameDownloadUrl:gameInfo];
    }
    
}

@end
