//
//  ActivityDetailViewController.m
//  WangYu
//
//  Created by 许 磊 on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "MatchDetailCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "WYAlertView.h"
#import "WYShareActionSheet.h"
#import "MatchPlaceViewController.h"
#import "TopicsViewController.h"
#import "WYLinkerHandler.h"
#import "MatchTeamsViewController.h"

#define MemberCount 24

@interface MatchDetailViewController ()<UITableViewDelegate,UITableViewDataSource,WYShareActionSheetDelegate,MatchPlaceViewDelegate>{
    WYShareActionSheet *_shareAction;
    BOOL bFavor;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *membersView;
@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (strong, nonatomic) IBOutlet UIView *statusView;
@property (strong, nonatomic) IBOutlet UITableView *matchTableView;
@property (strong, nonatomic) IBOutlet UIImageView *matchImageView;
@property (strong, nonatomic) IBOutlet UILabel *matchLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *joinLabel;
@property (strong, nonatomic) IBOutlet UIButton *collectButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) IBOutlet UIButton *showButton;

- (IBAction)collectAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)joinAction:(id)sender;
- (IBAction)showMatchAction:(id)sender;

@end

@implementation MatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUI];
    // Do any additional setup after loading the view from its nib.
    self.matchTableView.tableHeaderView = self.headerView;
    
    [self getCacheActivityInfo];
    [self getActivityInfo];
    [self refreshFloatView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"赛事详情"];
}

- (void)refreshUI{
    self.joinButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.joinButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.joinButton.layer setMasksToBounds:YES];
    [self.joinButton.layer setCornerRadius:4.0];
    self.joinButton.backgroundColor = SKIN_COLOR;
    
    self.showButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.showButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.showButton.layer setMasksToBounds:YES];
    [self.showButton.layer setCornerRadius:4.0];
    self.showButton.backgroundColor = SKIN_COLOR;
}

- (void)refreshFloatView {
    if (self.activityInfo.status == 1) {
        self.joinButton.hidden = NO;
        self.showButton.hidden = YES;
    }else{
        self.joinButton.hidden = YES;
        self.showButton.hidden = NO;
    }
    
    if (self.activityInfo.favored == 1) {
        [self.collectButton setBackgroundImage:[UIImage imageNamed:@"netbar_detail_collect_icon"] forState:UIControlStateNormal];
    }else if(self.activityInfo.favored == 0 || self.activityInfo.favored == -1){
        [self.collectButton setBackgroundImage:[UIImage imageNamed:@"netbar_detail_uncollect_icon"] forState:UIControlStateNormal];
    }
}

- (void)refreshHeaderView {
    self.matchLabel.text = self.activityInfo.title;
    if (![self.activityInfo.activityImageUrl isEqual:[NSNull null]]) {
        [self.matchImageView sd_setImageWithURL:self.activityInfo.smallImageURL placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
    }else{
        [self.matchImageView sd_setImageWithURL:nil];
        [self.matchImageView setImage:[UIImage imageNamed:@"activity_load_icon"]];
    }
    if (self.activityInfo.status == 1) {
        self.statusLabel.text = @"进行中";
        self.statusView.backgroundColor = UIColorToRGB(0xfdd730);
    }else if (self.activityInfo.status == 2){
        self.statusLabel.text = @"未开始";
        self.statusView.backgroundColor = UIColorToRGB(0xf1f1f1);
    }else if (self.activityInfo.status == 3){
        self.statusLabel.text = @"已截止";
        self.statusView.backgroundColor = UIColorToRGB(0xf1f1f1);
    }else if (self.activityInfo.status == 4){
        self.statusLabel.text = @"已结束";
        self.statusView.backgroundColor = UIColorToRGB(0xf1f1f1);
    }
    self.statusView.clipsToBounds = YES;
    [self.statusView.layer setMasksToBounds:YES];
    [self.statusView.layer setCornerRadius:self.statusView.frame.size.width/2];
}

- (void)refreshFooterView {
    self.joinLabel.text = [NSString stringWithFormat:@"%@人报名了",self.activityInfo.memberCount];
    
    CGRect frame = self.membersView.frame;
    int index = 0;
    for (WYUserInfo *memberInfo in self.activityInfo.members) {
        int count = 8;
        CGFloat width = (SCREEN_WIDTH - 24 - 8 * (count-1)) / count;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(12 + (index%count)*(width + 8), 9+(index/count)*(width+7), width, width)];
        button.tag = index;
        CGRect bFrame = button.frame;
        [button addTarget:self action:@selector(clickMermerAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = bFrame;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView.layer setMasksToBounds:YES];
        [imageView.layer setCornerRadius:imageView.frame.size.width/2];
        if (![memberInfo.smallAvatarUrl isEqual:[NSNull null]]) {
            [imageView sd_setImageWithURL:memberInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
        }else{
            [imageView sd_setImageWithURL:nil];
            [imageView setImage:[UIImage imageNamed:@"netbar_load_icon"]];
        }
        [self.membersView addSubview:button];
        [self.membersView addSubview:imageView];
        if (index > 15) {
            frame.size.height = 100 + (index/count - 1)*(width+7);
            self.membersView.frame = frame;
        }
        if (index == 23) {
            break;
        }
        index ++;
    }
    frame = self.footerView.frame;
    frame.size.height = 49 + self.membersView.frame.size.height + 40;
    self.footerView.frame = frame;
    self.matchTableView.tableFooterView = self.footerView;
}

- (void)clickMermerAction:(id)sender {
    //NSLog(@"===========");
}

-(void)getCacheActivityInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
     [[WYEngine shareInstance] getActivityDetailWithUid:[WYEngine shareInstance].uid activityId:self.activityInfo.aId pageSize:MemberCount tag:tag];
    
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            NSDictionary *dic = [jsonRet objectForKey:@"object"];
            [weakSelf.activityInfo setActivityInfoByJsonDic:dic];
            [weakSelf refreshHeaderView];
            [weakSelf refreshFooterView];
            [weakSelf.matchTableView reloadData];
        }
    }];
}

- (void)getActivityInfo {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getActivityDetailWithUid:[WYEngine shareInstance].uid activityId:self.activityInfo.aId pageSize:MemberCount tag:tag];
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
        NSDictionary *dic = [jsonRet objectForKey:@"object"];
        [weakSelf.activityInfo setActivityInfoByJsonDic:dic];
        [weakSelf refreshHeaderView];
        [weakSelf refreshFooterView];
        [weakSelf.matchTableView reloadData];
    }tag:tag];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 2;
    }
    return 1;
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
    static NSString *CellIdentifier = @"MatchDetailCell";
    MatchDetailCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0){
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_time_icon"];
                NSString *startString = self.activityInfo.startTime;
                if (startString.length > 10) {
                    startString = [startString substringToIndex:10];
                }
                NSString *endString = self.activityInfo.endTime;
                if (endString.length > 10) {
                    endString = [endString substringToIndex:10];
                }
                NSString *strTime = [NSString stringWithFormat:@"%@ ～ %@",startString,endString];
                if (strTime.length > 1) {
                    cell.titleLabel.text = strTime;
                }else {
                    cell.titleLabel.text = @"暂无时间";
                }
                cell.indicatorImage.hidden = YES;
                [cell setbottomLineWithType:0];
                break;
            }else if (indexPath.row == 1){
                cell.avatarImageView.image = [UIImage imageNamed:@"netbar_detail_location_icon"];
                cell.titleLabel.text = @"比赛地点";
                cell.indicatorImage.hidden = NO;
                cell.topline.hidden = YES;
                [cell setbottomLineWithType:1];
                break;
            }
//            else if (indexPath.row == 2){
//                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_schedule_icon"];
//                cell.titleLabel.text = @"赛事赛程";
//                cell.indicatorImage.hidden = NO;
//                cell.topline.hidden = YES;
//                [cell setbottomLineWithType:0];
//                break;
//            }else if (indexPath.row == 3){
//                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_award_icon"];
//                cell.titleLabel.text = @"赛事奖品";
//                cell.indicatorImage.hidden = NO;
//                cell.topline.hidden = YES;
//                [cell setbottomLineWithType:1];
//                break;
//            }
        }
        case 1:{
            if (indexPath.row == 0) {
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_advance_icon"];
                cell.titleLabel.text = @"赛事详情";
                cell.indicatorImage.hidden = NO;
                [cell setbottomLineWithType:0];
                break;
            }else if (indexPath.row == 1) {
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_joined_icon"];
                cell.titleLabel.text = @"已报战队";
                cell.indicatorImage.hidden = NO;
                cell.topline.hidden = YES;
                [cell setbottomLineWithType:1];
                break;
            }
        }
        default:
            break;
    }
    
    if (indexPath.row == 0) {
         cell.topline.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0){
                break;
            }else if (indexPath.row == 1){
                MatchPlaceViewController *mpVc = [[MatchPlaceViewController alloc] init];
                mpVc.activityId = self.activityInfo.aId;
                [self.navigationController pushViewController:mpVc animated:YES];
                break;
            }
//            else if (indexPath.row == 2){
//                id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/web/detail?id=%@", [WYEngine shareInstance].baseUrl ,self.activityInfo.aId] From:self.navigationController];
//                if (vc) {
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//                break;
//            }else if (indexPath.row == 3){
//                id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/web/detail?id=%@", [WYEngine shareInstance].baseUrl ,self.activityInfo.aId] From:self.navigationController];
//                if (vc) {
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//                break;
//            }
        }
        case 1:{
            if (indexPath.row == 0) {
                id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/web/detail?id=%@", [WYEngine shareInstance].baseUrl ,self.activityInfo.aId] From:self.navigationController];
                if (vc) {
                    [self.navigationController pushViewController:vc animated:YES];
                }
                break;
            }else if (indexPath.row == 1) {
                MatchTeamsViewController *mtVc = [[MatchTeamsViewController alloc] init];
                mtVc.activityId = self.activityInfo.aId;
                mtVc.showFilter = YES;
                [self.navigationController pushViewController:mtVc animated:YES];
            }
        }
        default:
            break;
    }

    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (IBAction)showMatchAction:(id)sender {
    if ([self.activityInfo.newsId isEqualToString:@"0"]) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"" message:@"暂无赛事资讯" cancelButtonTitle:@"确定"];
        [alertView show];
        return;
    }
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/info/web/detail?id=%@", [WYEngine shareInstance].baseUrl, self.activityInfo.newsId] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)collectAction:(id)sender {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];

    [[WYEngine shareInstance] collectionActivityWithUid:[WYEngine shareInstance].uid activityId:self.activityInfo.aId tag:tag];
    
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [WYProgressHUD AlertLoadDone];
        self.collectButton.enabled = YES;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        bFavor = [[jsonRet objectForKey:@"object"] boolValueForKey:@"is_favor"];
        if (bFavor) {
            weakSelf.activityInfo.favored = 1;
            [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromBottom ForView:self.collectButton];
            [WYProgressHUD AlertSuccess:@"收藏成功" At:weakSelf.view];
        }else {
            weakSelf.activityInfo.favored = 0;
            [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromTop ForView:self.collectButton];
            [WYProgressHUD AlertSuccess:@"取消收藏成功" At:weakSelf.view];
        }
        [weakSelf refreshFloatView];
    }tag:tag];
}

- (IBAction)shareAction:(id)sender {
    _shareAction = [[WYShareActionSheet alloc] init];
    _shareAction.activityInfo = self.activityInfo;
    _shareAction.owner = self;
    [_shareAction showShareAction];
}

- (IBAction)joinAction:(id)sender {
    MatchPlaceViewController *mpVc = [[MatchPlaceViewController alloc] init];
    mpVc.activityId = self.activityInfo.aId;
    mpVc.delegate = self;
    [self.navigationController pushViewController:mpVc animated:YES];
}

#pragma mark - MatchPlaceViewDelegate
- (void)refreshMatchDetailInfo{
    [self getActivityInfo];
}

- (void)dealloc{
    WYLog(@"MatchDetailViewController dealloc!!!");
    _matchTableView.delegate = nil;
    _matchTableView.dataSource = nil;
}

@end
