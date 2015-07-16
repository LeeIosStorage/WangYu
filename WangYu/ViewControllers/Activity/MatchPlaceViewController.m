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
#import "MatchApplyViewController.h"
#import "WYActionSheet.h"
#import <objc/message.h>

@interface MatchPlaceViewController ()<UITableViewDelegate,UITableViewDataSource,MatchPlaceCellDelegate,MatchApplyViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *placeTableView;

@property (nonatomic, strong) NSMutableDictionary *actionSheetIndexSelDic;

@property (strong, nonatomic) NSMutableArray *matchInfos;

@end

@implementation MatchPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getCacheMatchInfos];
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

-(void)getCacheMatchInfos{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getActivityAddressWithUid:[WYEngine shareInstance].uid activityId:self.activityId tag:tag];
    
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
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
        }
    }];
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

#pragma mark - MatchPlaceCellDelegate
- (void)matchPlaceCellClickWithCell:(id)cell{
    if ([[WYEngine shareInstance] needUserLogin:@"注册或登录后才能报名参赛"]) {
        return;
    }
    NSIndexPath* indexPath = [self.placeTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYMatchInfo *matchInfo = _matchInfos[indexPath.row];
//    WYMatchInfo* matchInfo = _matchInfos[indexPath.row];
//    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/web/apply?id=%@&userId=%@&token=%@&round=%d", [WYEngine shareInstance].baseUrl, self.activityId , [WYEngine shareInstance].uid, [WYEngine shareInstance].token, matchInfo.round] From:self.navigationController];
//    if (vc) {
//        [self.navigationController pushViewController:vc animated:YES];
//    }
    [self applyActionSheet:matchInfo];
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

- (void)doActionSheetSelectorWithButtonIndex:(NSInteger)buttonIndex matchInfo:(WYMatchInfo *)info{
    if (!_actionSheetIndexSelDic || buttonIndex < 0 || buttonIndex >= _actionSheetIndexSelDic.allKeys.count) {
        return;
    }
    SEL sel = NSSelectorFromString([_actionSheetIndexSelDic objectForKey:[NSNumber numberWithInteger:buttonIndex]]);
    
    if ([self respondsToSelector:sel]) {
        objc_msgSend((id)self, sel, info);
    }
}

- (void)solApplyAction:(WYMatchInfo *)matchInfo{
    MatchApplyViewController *maVc = [[MatchApplyViewController alloc] init];
    maVc.activityId = self.activityId;
    maVc.matchInfo = matchInfo;
    maVc.applyType = ApplyViewTypeSol;
    maVc.delegate = self;
    [self.navigationController pushViewController:maVc animated:YES];
}

- (void)teamApplyAction:(WYMatchInfo *)matchInfo{
    MatchApplyViewController *maVc = [[MatchApplyViewController alloc] init];
    maVc.activityId = self.activityId;
    maVc.matchInfo = matchInfo;
    maVc.applyType = ApplyViewTypeTeam;
    [self.navigationController pushViewController:maVc animated:YES];
}

- (void)applyActionSheet:(WYMatchInfo *)info{
//    _actionSheetIndexSelDic = [[NSMutableDictionary alloc] init];
    WS(weakSelf);
    WYActionSheet *sheet;
    if (info.hasApply < 1) {
        sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
            if (2 == buttonIndex) {
                return;
            }
            if (buttonIndex == 0) {
                [weakSelf solApplyAction:info];
            }else if (buttonIndex == 1){
                [weakSelf teamApplyAction:info];
            }
        } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"个人报名", @"创建报名", nil];
    }else {
        sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
            if (1 == buttonIndex) {
                return;
            }
            if (buttonIndex == 0) {
                [weakSelf teamApplyAction:info];
            }
        } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建报名", nil];
    }
    [sheet showInView:self.view];
    
//    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
//        [weakSelf doActionSheetSelectorWithButtonIndex:buttonIndex matchInfo:info];
//    }];
//    if(info.hasApply < 1){
//        [_actionSheetIndexSelDic setObject:@"solApplyAction:" forKey:[NSNumber numberWithInt:(int)sheet.numberOfButtons]];
//        [sheet addButtonWithTitle:@"个人报名"];
//    }
//    
//    [_actionSheetIndexSelDic setObject:@"teamApplyAction:" forKey:[NSNumber numberWithInt:(int)sheet.numberOfButtons]];
//    [sheet addButtonWithTitle:@"创建报名"];
//    
//    [sheet addButtonWithTitle:@"取消"];
//    sheet.cancelButtonIndex = sheet.numberOfButtons -1;
//    AppDelegate *appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    [sheet showInView:appDelegate.window];
}

#pragma mark - MatchApplyViewDelegate
- (void)refreshMatchPlaceInfo{
    if (self.delegate && [self.delegate respondsToSelector:@selector(refreshMatchDetailInfo)]) {
        [self.delegate refreshMatchDetailInfo];
    }
}

@end
