//
//  MatchTeamsViewController.m
//  WangYu
//
//  Created by XuLei on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchTeamsViewController.h"
#import "MatchTeamsCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYTeamInfo.h"
#import "WYNetbarInfo.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "MatchApplyViewController.h"

@interface MatchTeamsViewController ()<UITableViewDelegate, UITableViewDataSource, MatchTeamsCellDelegate>

@property (nonatomic, strong) NSMutableArray *teamInfos;
@property (nonatomic, strong) NSMutableArray *netbarInfos;
@property (strong, nonatomic) IBOutlet UITableView *teamTableView;
@property (strong, nonatomic) IBOutlet UIView *filterContainerView;
@property (nonatomic, strong) IBOutlet UIImageView *filterBottomImgView;
@property (nonatomic, strong) IBOutlet UIImageView *filterMiddleImgView;
@property (strong, nonatomic) IBOutlet UILabel *filterCityLabel;
@property (strong, nonatomic) IBOutlet UILabel *filterNetbarLabel;
@property (strong, nonatomic) IBOutlet UIImageView *filterCityImgView;
@property (strong, nonatomic) IBOutlet UIImageView *filterNetbarImgView;
@property (strong, nonatomic) IBOutlet UIButton *filterCityButton;
@property (strong, nonatomic) IBOutlet UIButton *filterNetbarButton;

- (IBAction)filterCityAction:(id)sender;
- (IBAction)filterNetbarAction:(id)sender;

@property (assign, nonatomic) SInt32 teamCursor;
@property (assign, nonatomic) BOOL teamLoadMore;

@end

@implementation MatchTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    self.filterBottomImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
    self.filterMiddleImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
    CGRect frame = self.filterBottomImgView.frame;
    frame.size.height = 0.5;
    self.filterBottomImgView.frame = frame;
    frame = self.filterMiddleImgView.frame;
    frame.size.width = 0.5;
    self.filterMiddleImgView.frame = frame;
    
    self.filterCityLabel.textColor = SKIN_TEXT_COLOR1;
    self.filterCityLabel.font = SKIN_FONT_FROMNAME(14);
    self.filterNetbarLabel.textColor = SKIN_TEXT_COLOR1;
    self.filterNetbarLabel.font = SKIN_FONT_FROMNAME(14);
    
    [self getTeamsInfo];
    
    WS(weakSelf);
    [self.teamTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.teamLoadMore) {
            [weakSelf.teamTableView.infiniteScrollingView stopAnimating];
            weakSelf.teamTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMatchJoinedTeamWithUid:[WYEngine shareInstance].uid activityId:@"1" netbarId:nil page:weakSelf.teamCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.teamTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"teams"];
            for (NSDictionary *dic in object) {
                WYTeamInfo *teamInfo = [[WYTeamInfo alloc] init];
                [teamInfo setTeamInfoByJsonDic:dic];
                [weakSelf.teamInfos addObject:teamInfo];
            }
            [weakSelf.teamTableView reloadData];
        
            weakSelf.teamLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.teamLoadMore) {
                weakSelf.teamTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.teamTableView.showsInfiniteScrolling = YES;
                weakSelf.teamCursor ++;
            }
        } tag:tag];
    }];
    weakSelf.teamTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews {
    [self setTitle:@"已报战队"];
}

- (void)getTeamsInfo {
    _teamCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchJoinedTeamWithUid:[WYEngine shareInstance].uid activityId:@"1" netbarId:nil page:_teamCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        weakSelf.teamInfos = [NSMutableArray array];
        weakSelf.netbarInfos = [NSMutableArray array];
        
        NSArray *teamDicArray = [[jsonRet objectForKey:@"object"] objectForKey:@"teams"];
        for (NSDictionary *dic in teamDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYTeamInfo *teamInfo = [[WYTeamInfo alloc] init];
            [teamInfo setTeamInfoByJsonDic:dic];
            [weakSelf.teamInfos addObject:teamInfo];
        }
        [weakSelf.teamTableView reloadData];
        
        NSArray *netbarDicArray = [[jsonRet objectForKey:@"object"] objectForKey:@"condition"];
        for (NSDictionary *dic in netbarDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf.netbarInfos addObject:netbarInfo];
        }
        
        weakSelf.teamLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.teamLoadMore) {
            weakSelf.teamTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.teamTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.teamCursor ++;
        }

    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teamInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchTeamsCell";
    MatchTeamsCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    WYTeamInfo *teamInfo = _teamInfos[indexPath.row];
    cell.teamInfo = teamInfo;
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark - PayOrderViewCellDelegate
- (void)MatchTeamsCellJoinClickWithCell:(id)cell{
    NSIndexPath* indexPath = [self.teamTableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    //WYTeamInfo* teamInfo = _teamInfos[indexPath.row];
    MatchApplyViewController *maVc = [[MatchApplyViewController alloc] init];
    [self.navigationController pushViewController:maVc animated:YES];
}

- (void)dealloc {
    _teamTableView.delegate = nil;
    _teamTableView.dataSource = nil;
}

- (IBAction)filterCityAction:(id)sender {
}

- (IBAction)filterNetbarAction:(id)sender {
}
@end
