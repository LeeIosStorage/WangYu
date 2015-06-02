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

enum TABLEVIEW_SECTION_INDEX {
    kMessage = 0,
    kEvents,
    kCollect,
    kSettings,
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTilteLeftViewHide:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUserInfoChanged:) name:WY_USERINFO_CHANGED_NOTIFICATION object:nil];
    
    [self refreshUI];
    
}

- (void)handleUserInfoChanged:(NSNotification *)notification{
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"我的"];
    [self setRightButtonWithImageName:@"netbar_service_icon" selector:@selector(serviceAction:)];
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
    [self.avatarImageView sd_setImageWithURL:[WYEngine shareInstance].userInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon_small"]];
    
    self.tableView.tableHeaderView = self.headView;
    [self.tableView reloadData];
}

#pragma mark - request

#pragma mark - IBAction
- (void)serviceAction:(id)sender{
    _badgeView.unreadNum = 2;
    _badgeView.hidden = NO;
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/cs/web/detail", [WYEngine shareInstance].baseUrl] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
//    [WYUIUtils transitionWithType:@"rippleEffect" WithSubtype:kCATransitionFromTop ForView:_badgeView];
}
- (void)messageAction:(id)sender{
    MessageListViewController *messageVc = [[MessageListViewController alloc] init];
    [self.navigationController pushViewController:messageVc animated:YES];
}
- (IBAction)editAction:(id)sender{
    PersonalEditViewController *personalEditVc = [[PersonalEditViewController alloc] init];
    [self.navigationController pushViewController:personalEditVc animated:YES];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSettings + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kMessage) {
        return 1;
    }else if (section == kEvents){
        return 3;
    }else if (section == kCollect){
        return 1;
    }else if (section == kSettings){
        return 1;
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
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
            }
        }
            break;
        case kEvents:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"我的约战";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_war_icon"];
            }else if (indexPath.row == 1){
                cell.titleLabel.text = @"我的赛事";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_message_icon"];
            }else if (indexPath.row == 2){
                cell.titleLabel.text = @"我的红包";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_redpacket_icon"];
            }
        }
            break;
        case kCollect:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"我的收藏";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_collcet_icon"];
            }
        }
            break;
        case kSettings:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"设置";
                cell.avatarImageView.image = [UIImage imageNamed:@"personal_setting_icon"];
            }
        }
            break;
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
            }
        }
            break;
        case kCollect:{
            if (indexPath.row == 0){
                CollectListViewController *vc = [[CollectListViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case kSettings:{
            if (indexPath.row == 0){
                SettingViewController *setVc = [[SettingViewController alloc] init];
                [self.navigationController pushViewController:setVc animated:YES];
            }
        }
            break;
        default:
            break;
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
