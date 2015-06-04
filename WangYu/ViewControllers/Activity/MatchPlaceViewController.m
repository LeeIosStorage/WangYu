//
//  MatchPlaceViewController.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchPlaceViewController.h"
#import "MatchPlaceCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYMatchInfo.h"
#import "WYAlertView.h"
#import "WYLinkerHandler.h"
#import "AppDelegate.h"
#import "NetbarDetailViewController.h"

@interface MatchPlaceViewController ()<UITableViewDelegate,UITableViewDataSource,MatchPlaceCellDelegate>

@property (strong, nonatomic) IBOutlet UITableView *placeTableView;

@property (strong, nonatomic) NSMutableArray *matchInfos;

@end

@implementation MatchPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getMatchInfos];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 19)];
    footer.userInteractionEnabled = NO;
    footer.backgroundColor = [UIColor clearColor];
    _placeTableView.tableFooterView = footer;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"比赛地点"];
}

- (void)getMatchInfos {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getActivityAddressWithUid:[WYEngine shareInstance].uid activityId:self.activityId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [WYProgressHUD AlertLoadDone];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.matchInfos = [NSMutableArray array];
        NSArray *matchDicArray = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in matchDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYMatchInfo *matchInfo = [[WYMatchInfo alloc] init];
            [matchInfo setMatchInfoByJsonDic:dic];
            [weakSelf.matchInfos addObject:matchInfo];
        }
        [weakSelf.placeTableView reloadData];
    }tag:tag];

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
    WYMatchInfo *matchInfo = _matchInfos[indexPath.row];
    return [MatchPlaceCell heightForMatchInfo:matchInfo];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchPlaceCell";
    MatchPlaceCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    cell.delegate = self;
    WYMatchInfo *matchInfo = _matchInfos[indexPath.row];
    cell.matchInfo = matchInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (void)signOutAndLogin{
    AppDelegate * appDelgate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    WYLog(@"signOut for user logout from SettingViewController");
    [appDelgate signOut];
    [[WYEngine shareInstance] visitorLogin];
}

#pragma mark - MatchPlaceCellDelegate
- (void)matchPlaceCellClickWithCell:(id)cell{
    if (![[WYEngine shareInstance] hasAccoutLoggedin]) {
        [self signOutAndLogin];
        return;
    }
    NSIndexPath* indexPath = [self.placeTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYMatchInfo* matchInfo = _matchInfos[indexPath.row];
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/web/apply?id=%@&userId=%@&token=%@&round=%d", [WYEngine shareInstance].baseUrl, self.activityId , [WYEngine shareInstance].uid, [WYEngine shareInstance].token, matchInfo.round] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)matchPlaceCellClickNetbarWithCell:(id)cell netbarInfo:(WYNetbarInfo *)netbar {
//    NSIndexPath* indexPath = [self.placeTableView indexPathForCell:cell];
//    if (indexPath == nil) {
//        return;
//    }
//    WYMatchInfo* matchInfo = _matchInfos[indexPath.row];
//    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/netbar/web/detail?id=%@", [WYEngine shareInstance].baseUrl, netbarId] From:self.navigationController];
//    if (vc) {
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    
    NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
    ndVc.netbarInfo = netbar;
    [self.navigationController pushViewController:ndVc animated:YES];
}

@end
