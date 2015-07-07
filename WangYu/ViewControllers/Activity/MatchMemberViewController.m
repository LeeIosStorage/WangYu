//
//  MatchMemberViewController.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchMemberViewController.h"
#import "MatchMemberCell.h"
#import "InviteMemberViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYMemberInfo.h"

@interface MatchMemberViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *memberInfos;
@property (strong, nonatomic) IBOutlet UITableView *memberTableView;

@end

@implementation MatchMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshTeamMembers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews {
    [self setTitle:@"我的队友"];
     [self setRightButtonWithImageName:@"match_invite_icon" selector:@selector(inviteAction)];
}

- (void)refreshTeamMembers {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchTeamMemberWithUid:[WYEngine shareInstance].uid teamId:self.teamId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.memberInfos = [NSMutableArray array];
        NSArray *matchDicArray = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in matchDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYMemberInfo *memberInfo = [[WYMemberInfo alloc] init];
            [memberInfo setMemberInfoByJsonDic:dic];
            if (!memberInfo.isLeader) {
                [weakSelf.memberInfos addObject:memberInfo];
            }
        }
        [weakSelf.memberTableView reloadData];
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _memberInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 12)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchMemberCell";
    MatchMemberCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    WYMemberInfo *memberInfo = _memberInfos[indexPath.row];
    cell.memberInfo = memberInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WYMemberInfo *memberInfo = [_memberInfos objectAtIndex:indexPath.row];
        if (!memberInfo) {
            return;
        }
        [self removeMember:memberInfo tableView:tableView forRowAtIndexPath:indexPath];
    }
}

- (void)removeMember:(WYMemberInfo *)memberInfo tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] removeMemberWithUid:[WYEngine shareInstance].uid memberId:memberInfo.memberId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        [_memberInfos removeObjectAtIndex:indexPath.row];
        [self.memberTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }tag:tag];
}

- (void)inviteAction {
    InviteMemberViewController *imVc = [[InviteMemberViewController alloc] init];
    imVc.activityId = self.activityId;
    imVc.teamId = self.teamId;
    [self.navigationController pushViewController:imVc animated:YES];
}

@end
