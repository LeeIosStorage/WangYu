//
//  MineTabViewController.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MineTabViewController.h"
#import "WYTabBarViewController.h"
#import "AboutViewController.h"
#import "WYEngine.h"
#import "AppDelegate.h"
#import "SettingViewController.h"
#import "OrdersViewController.h"
#import "UIImageView+WebCache.h"
#import "SettingViewCell.h"
#import "PersonalEditViewController.h"
#import "MessageListViewController.h"
#import "CollectListViewController.h"
#import "RedPacketViewController.h"
#import "ApplyActivityViewController.h"
#import "MineMatchWarViewController.h"
#import "WYBadgeView.h"
#import "WYLinkerHandler.h"
#import "WYSettingConfig.h"
#import "PersonalProfileViewController.h"
#import "GameCommendViewController.h"
#import "GameListViewController.h"

enum TABLEVIEW_SECTION_INDEX {
    kMessage = 0,
    kEvents,
//    kCollect,
    kGames,
    //kSettings,
};

@interface MineTabViewController () <UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *headView;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) WYBadgeView *badgeView;

- (IBAction)editAction:(id)sender;
@end

@implementation MineTabViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshBadgeView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTilteLeftViewHide:NO];
    [self getUnReadMessage];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendTimelineUreadEvent) name:WY_MINEMESSAGE_UNREAD_EVENT_NOTIFICATION object:nil];
    
    [self refreshUI];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 19)];
    footer.userInteractionEnabled = NO;
    footer.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = footer;
}

- (void)handleUserInfoChanged:(NSNotification *)notification{
    [self refreshUI];
}
- (void)handleFriendTimelineUreadEvent {
    [self getUnReadMessage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"我的"];
//    [self setRightButtonWithImageName:@"netbar_service_icon" selector:@selector(serviceAction:)];
    [self setRightButtonWithImageName:@"mine_seeting_icon" selector:@selector(settingAction:)];
    [self setLeftButtonWithImageName:@"personal_email_icon"];
    [self setLeftButtonWithSelector:@selector(messageAction:)];
    
    CGRect messageIconFrame = CGRectMake(27 ,29, 35, 20);
    _badgeView = [[WYBadgeView alloc] initWithFrame:messageIconFrame];
    _badgeView.hidden = YES;
    [self.titleNavBar addSubview:_badgeView];
    
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
-(void)refreshUI{
    
    self.userNameLabel.textColor = SKIN_TEXT_COLOR1;
    self.userNameLabel.font = SKIN_FONT_FROMNAME(15);
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.userNameLabel.text = [WYEngine shareInstance].userInfo.nickName;
    if (![[WYEngine shareInstance] hasAccoutLoggedin]) {
        self.userNameLabel.text = @"点击注册登录";
    }
    if ([WYEngine shareInstance].userInfo.smallAvatarUrl) {
        [self.avatarImageView sd_setImageWithURL:[WYEngine shareInstance].userInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon_small"]];
    }else{
        [self.avatarImageView sd_setImageWithURL:nil];
        self.avatarImageView.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
    }
    
    self.tableView.tableHeaderView = self.headView;
    [self.tableView reloadData];
}

-(void)refreshBadgeView{
    int unreadNum = [[WYSettingConfig staticInstance] getMessageCount];
    self.badgeView.unreadNum = unreadNum;
    if (unreadNum == 0) {
        self.badgeView.hidden = YES;
    }else{
        self.badgeView.hidden = NO;
    }
}

#pragma mark - request
- (void)getUnReadMessage{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getUnReadMessageCountWithUid:[WYEngine shareInstance].uid tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            return;
        }
        
//        int unreadNum = [[WYSettingConfig staticInstance] getMessageCount];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[jsonRet dictionaryObjectForKey:@"object"]];
//        int activityNum = [[jsonRet objectForKey:@"object"] intValueForKey:@"activity"];
//        int orderNum = [[jsonRet objectForKey:@"object"] intValueForKey:@"order"];
//        int systemNum = [[jsonRet objectForKey:@"object"] intValueForKey:@"sys"];
//        int unreadNum = activityNum + orderNum + systemNum;
//        [[WYSettingConfig staticInstance] addMessageNum:unreadNum];
        [[WYSettingConfig staticInstance] saveMessageDic:dic];
        [weakSelf refreshBadgeView];
        
    }tag:tag];
}

#pragma mark - IBAction
- (void)settingAction:(id)sender{
    SettingViewController *setVc = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:setVc animated:YES];
}

- (void)serviceAction:(id)sender{
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/cs/web/detail", [WYEngine shareInstance].baseUrl] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
//    [WYUIUtils transitionWithType:@"rippleEffect" WithSubtype:kCATransitionFromTop ForView:_badgeView];
}
- (void)messageAction:(id)sender{
    if ([[WYEngine shareInstance] needUserLogin:nil]) {
        return;
    }
    MessageListViewController *messageVc = [[MessageListViewController alloc] init];
    [self.navigationController pushViewController:messageVc animated:YES];
}
- (IBAction)editAction:(id)sender{
    if (![[WYEngine shareInstance] hasAccoutLoggedin]) {
        [[WYEngine shareInstance] gotoLogin];
        return;
    }
    PersonalProfileViewController *vc = [[PersonalProfileViewController alloc] init];
    vc.userInfo = [WYEngine shareInstance].userInfo;
    [self.navigationController pushViewController:vc animated:YES];
    
//    PersonalEditViewController *personalEditVc = [[PersonalEditViewController alloc] init];
//    [self.navigationController pushViewController:personalEditVc animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kGames + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kMessage) {
        return 1;
    }else if (section == kEvents){
        return 4;
    }else if (section == kGames){
        return 1;
    }
//    else if (section == kCollect){
//        return 1;
//    }
//    else if (section == kSettings){
//        return 1;
//    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

static int RedImageView_tag = 201;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        UIImageView *red_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 -20 , (44-10)/2, 10, 10)];
        red_imageView.image = [UIImage imageNamed:@"s_n_round_red"];
        red_imageView.tag = RedImageView_tag;
        [cell addSubview:red_imageView];
    }
    UIImageView *red_imageView = (UIImageView *)[cell viewWithTag:RedImageView_tag];
    red_imageView.hidden = YES;
    cell.rightLabel.hidden = YES;
    cell.avatarImageView.hidden = NO;
    CGRect frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 10;
    cell.titleLabel.frame = frame;
    
    switch (indexPath.section) {
        case kMessage:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"我的订单";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_order_icon"];
                cell.rightLabel.text = @"查看全部";
                cell.rightLabel.hidden = NO;
                [cell setLineImageViewWithType:-1];
            }
        }
            break;
        case kEvents:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"我的约战";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_war_icon"];
                [cell setLineImageViewWithType:0];
            }else if (indexPath.row == 1){
                cell.titleLabel.text = @"我的赛事";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_message_icon"];
                [cell setLineImageViewWithType:1];
            }else if (indexPath.row == 2){
                cell.titleLabel.text = @"我的红包";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_redpacket_icon"];
                [cell setLineImageViewWithType:1];
            }else if (indexPath.row == 3){
                cell.titleLabel.text = @"我的收藏";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_collcet_icon"];
                [cell setLineImageViewWithType:2];
            }
        }
            break;
//        case kCollect:{
//            if (indexPath.row == 0){
//                cell.titleLabel.text = @"我的收藏";
//                cell.avatarImageView.image = [UIImage imageNamed:@"personal_collcet_icon"];
//                [cell setLineImageViewWithType:-1];
//            }
//        }
//            break;
        case kGames:{
            if (indexPath.row == 0){
                red_imageView.hidden = NO;
                cell.titleLabel.text = @"手游中心";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_game_icon"];
                [cell setLineImageViewWithType:-1];
            }
        }
            break;
//        case kSettings:{
//            if (indexPath.row == 0){
//                cell.titleLabel.text = @"设置";
//                cell.avatarImageView.image = [UIImage imageNamed:@"personal_setting_icon"];
//                [cell setLineImageViewWithType:-1];
//            }
//        }
//            break;
        default:
            break;
    }
    
    if (indexPath.row == 0) {
        // cell.topline.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    if (indexPath.section != kGames) {
        if ([[WYEngine shareInstance] needUserLogin:nil]) {
            return;
        }
    }
    switch (indexPath.section) {
        case kMessage:{
            if (indexPath.row == 0){
                OrdersViewController *orderVc = [[OrdersViewController alloc] init];
                [self.navigationController pushViewController:orderVc animated:YES];
            }
        }
            break;
        case kEvents:{
            if (indexPath.row == 0){
                MineMatchWarViewController *vc = [[MineMatchWarViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }else if (indexPath.row == 1){
                ApplyActivityViewController *vc = [[ApplyActivityViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }else if (indexPath.row == 2){
                RedPacketViewController *vc = [[RedPacketViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }else if (indexPath.row == 3){
                CollectListViewController *vc = [[CollectListViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
//        case kCollect:{
//            if (indexPath.row == 0){
//                CollectListViewController *vc = [[CollectListViewController alloc] init];
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//            break;
        case kGames:{
            if (indexPath.row == 0){
                GameListViewController *vc = [[GameListViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
//        case kSettings:{
//            if (indexPath.row == 0){
//                SettingViewController *setVc = [[SettingViewController alloc] init];
//                [self.navigationController pushViewController:setVc animated:YES];
//            }
//        }
//            break;
        default:
            break;
    }
}

@end
