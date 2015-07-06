//
//  ManageMatchWarViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/3.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ManageMatchWarViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYMatchApplyInfo.h"
#import "SettingViewCell.h"
#import "UIImageView+WebCache.h"
#import "WYActionSheet.h"
#import "WYAlertView.h"
#import <MessageUI/MessageUI.h>
#import "InviteFriendsViewController.h"
#import "PbUserInfo.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface ManageMatchWarViewController ()<UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *applyPeoples;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *cancelMatchButton;

@property (assign, nonatomic) SInt64  applyNextCursor;
@property (assign, nonatomic) BOOL applyCanLoadMore;

- (IBAction)cancelMatchWar:(id)sender;

@end

@implementation ManageMatchWarViewController

- (void)dealloc{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIEdgeInsets inset = UIEdgeInsetsMake(self.titleNavBar.frame.size.height + 12, 0, 0, 0);
    [self setContentInsetForScrollView:self.tableView inset:inset];
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.tableView];
    self.pullRefreshView.delegate = self;
    [self.tableView addSubview:self.pullRefreshView];
    
    
    _applyPeoples = [[NSMutableArray alloc] initWithArray:_applys];
    [self.tableView reloadData];
    
    [self refreshViewUI];
    
    [self getCacheApplys];
    [self refreshApplyPeople];
    
    
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
        [[WYEngine shareInstance] manageMatchAppliersWithUid:[WYEngine shareInstance].uid matchId:weakSelf.matchWarInfo.mId page:(int)weakSelf.applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    WYMatchApplyInfo *applyInfo = [[WYMatchApplyInfo alloc] init];
                    [applyInfo setApplyInfoByDic:dic];
                    [weakSelf.applyPeoples addObject:applyInfo];
                }
            }
            
            weakSelf.applyCanLoadMore = [[jsonRet dictionaryObjectForKey:@"object"] boolValueForKey:@"isLast"];
            if (weakSelf.applyCanLoadMore) {
                weakSelf.tableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.tableView.showsInfiniteScrolling = YES;
                //可以加载更多
                weakSelf.applyNextCursor ++;
            }
            
            [weakSelf.tableView reloadData];
            
        } tag:tag];
    }];
    self.tableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"人员管理"];
    [self setRightButtonWithTitle:@"邀请" selector:@selector(inviteAction:)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshViewUI{
    self.cancelMatchButton.titleLabel.font = SKIN_FONT_FROMNAME(15);
    [self.cancelMatchButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.cancelMatchButton.layer setMasksToBounds:YES];
    [self.cancelMatchButton.layer setCornerRadius:4.0];
    self.cancelMatchButton.backgroundColor = SKIN_COLOR;
}

#pragma custom
-(void)inviteAction:(id)sender{
    
    WS(weakSelf);
    InviteFriendsViewController *inviteFriendsVc = [[InviteFriendsViewController alloc] init];
    inviteFriendsVc.sendInviteFriendsCallBack = ^(NSArray *array){
        
        [weakSelf invitePeopleToMSM:array];
    };
    [self.navigationController pushViewController:inviteFriendsVc animated:YES];
    
}
- (IBAction)cancelMatchWar:(id)sender{
    
    WS(weakSelf);
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"你确定要取消该约战" cancelButtonTitle:@"取消" cancelBlock:^{
        
    } okButtonTitle:@"确定" okBlock:^{
        [weakSelf ownerCancelMatchWar];
    }];
    [alertView show];
}

- (void)ownerCancelMatchWar{
    self.cancelMatchButton.enabled = NO;
    __weak ManageMatchWarViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] cancelApplyMatchWarWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        self.cancelMatchButton.enabled = YES;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"取消约战成功" At:weakSelf.view];
        [weakSelf performSelector:@selector(cancelFinished) withObject:nil afterDelay:1.0];
    } tag:tag];
}

-(void)removeApplyPeopleWith:(WYMatchApplyInfo*)info{
    if ([[WYEngine shareInstance] needUserLogin:nil]) {
        return;
    }
    __weak ManageMatchWarViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] removeApplyMatchWarPeopleWithMatchId:_matchWarInfo.mId uid:[WYEngine shareInstance].uid applyId:info.applyId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSInteger index = [weakSelf.applyPeoples indexOfObject:info];
        if (index == NSNotFound || index < 0 || index >= weakSelf.applyPeoples.count) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [weakSelf.applyPeoples removeObjectAtIndex:indexPath.row];
        [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }tag:tag];
}

-(void)invitePeopleToMSM:(NSArray *)applys{
    
    NSMutableArray *invitedPhones = nil;
    if (applys.count > 0) {
        invitedPhones = [NSMutableArray array];
        for (PbUserInfo *pbUserInfo in applys) {
            if (pbUserInfo.phoneNUm.length > 0) {
                [invitedPhones addObject:pbUserInfo.phoneNUm];
            }
        }
    }
    if (!invitedPhones || invitedPhones.count == 0) {
        return;
    }
    
    [WYProgressHUD AlertLoading:@"邀请中..." At:self.view];
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] invitedPbPeopleWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId invitedPhones:invitedPhones tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSString * pidsString = @"邀请成功";
        if (invitedPhones != nil && invitedPhones.count > 0) {
            pidsString = [WYCommonUtils stringSplitWithCommaForIds:invitedPhones];
            pidsString = [NSString stringWithFormat:@"手机联系人 %@ 邀请成功",pidsString];
        }
        [WYProgressHUD AlertSuccess:pidsString At:weakSelf.view];
    } tag:tag];
    
}

-(void)cancelFinished{
    if (self.navigationController.viewControllers.count > 2) {
        UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
        if (vc) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

-(void)getCacheApplys{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] manageMatchAppliersWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            
            weakSelf.applyPeoples = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    WYMatchApplyInfo *applyInfo = [[WYMatchApplyInfo alloc] init];
                    [applyInfo setApplyInfoByDic:dic];
                    [weakSelf.applyPeoples addObject:applyInfo];
                }
            }
            [weakSelf.tableView reloadData];
        }
    }];
}
-(void)refreshApplyPeople{
    
    self.applyNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] manageMatchAppliersWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId page:(int)self.applyNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        weakSelf.applyPeoples = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            if ([dic isKindOfClass:[NSDictionary class]]) {
                WYMatchApplyInfo *applyInfo = [[WYMatchApplyInfo alloc] init];
                [applyInfo setApplyInfoByDic:dic];
                [weakSelf.applyPeoples addObject:applyInfo];
            }
        }
        
        weakSelf.applyCanLoadMore = [[jsonRet dictionaryObjectForKey:@"object"] boolValueForKey:@"isLast"];
        if (weakSelf.applyCanLoadMore) {
            weakSelf.tableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.tableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.applyNextCursor ++;
        }
        
        [weakSelf.tableView reloadData];
        
    }tag:tag];
    
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshApplyPeople];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

#pragma mark - Table view data source
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.tableView) {
            WS(weakSelf);
            WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"是否要删除该成员" cancelButtonTitle:@"取消" cancelBlock:^{
                
            } okButtonTitle:@"确定" okBlock:^{
                WYMatchApplyInfo *applyInfo = _applyPeoples[indexPath.row];
                [weakSelf removeApplyPeopleWith:applyInfo];
            }];
            [alertView show];
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.applyPeoples.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        UIImageView *actionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-14-18, (49-14)/2, 14, 14)];
        actionImageView.image = [UIImage imageNamed:@"match_invite_phone_icon"];
        [cell addSubview:actionImageView];
    }
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:0];
        if (indexPath.row == self.applyPeoples.count-1) {
            [cell setLineImageViewWithType:-1];
        }
    }else if (indexPath.row == self.applyPeoples.count-1){
        [cell setLineImageViewWithType:2];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = YES;
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = YES;
    
    CGFloat rowHeight = 49;
    CGRect frame = cell.avatarImageView.frame;
    frame.origin.y = (rowHeight-30)/2;
    frame.size.width = 30;
    frame.size.height = 30;
    cell.avatarImageView.frame = frame;
    
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width/2;
    cell.avatarImageView.clipsToBounds = YES;
    cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 7;
    cell.titleLabel.frame = frame;
    
    WYMatchApplyInfo *applyInfo = _applyPeoples[indexPath.row];
    
    cell.titleLabel.text = applyInfo.nickName;
    [cell.avatarImageView sd_setImageWithURL:applyInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"wangyu_message_icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    WYMatchApplyInfo *applyInfo = _applyPeoples[indexPath.row];
//    __weak ManageMatchWarViewController *weakSelf = self;
    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        if (buttonIndex == 0) {
            [WYCommonUtils usePhoneNumAction:applyInfo.telephone];
        }else if (buttonIndex == 1){
            [self displaySMSComposerSheet:applyInfo];
        }
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"电话联系", @"短信联系", nil];
    [sheet showInView:self.view];
}

-(void)displaySMSComposerSheet:(WYMatchApplyInfo*)applyInfo{
    
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if (smsClass != nil && [MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.body = [WYUIUtils documentOfInviteMsg:0];
        NSMutableArray* phones = [[NSMutableArray alloc] initWithCapacity:1];
        [phones addObject:applyInfo.telephone];
        controller.recipients = phones;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultCancelled:
            
            break;
        case MessageComposeResultFailed:
            
            break;
        case MessageComposeResultSent:{
            [WYProgressHUD AlertSuccess:@"短信已发送" At:self.view];
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
