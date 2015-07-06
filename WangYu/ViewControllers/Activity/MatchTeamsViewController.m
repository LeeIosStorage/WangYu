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

@interface MatchTeamsViewController ()<UITableViewDelegate, UITableViewDataSource, MatchTeamsCellDelegate>{
    int _filterType;
    NSString *_filterAreaName;
    NSString *_filterNetbarName;
}

@property (nonatomic, strong) NSString *filterAreaCode;   //选择城市code
@property (nonatomic, strong) NSString *filterNetbarId;   //选择netbarId

@property (nonatomic, strong) NSMutableArray *teamInfos;
@property (nonatomic, strong) NSMutableArray *netbarInfos;
@property (strong, nonatomic) IBOutlet UITableView *teamTableView;

@property (nonatomic, strong) NSString *filterPriceType;
@property (nonatomic, strong) NSMutableArray *filterAreaArray;
@property (nonatomic, strong) NSMutableArray *filterNetbarArray;
@property (nonatomic, strong) IBOutlet UIView *filterTableContainerView;
@property (nonatomic, strong) IBOutlet UITableView *filterTableView;
@property (nonatomic, strong) UIButton *bgMarkButtonView;

@property (strong, nonatomic) IBOutlet UIView *filterContainerView;
@property (nonatomic, strong) IBOutlet UIImageView *filterBottomImgView;
@property (nonatomic, strong) IBOutlet UIImageView *filterMiddleImgView;

@property (strong, nonatomic) IBOutlet UILabel *filterAreaLabel;
@property (strong, nonatomic) IBOutlet UILabel *filterNetbarLabel;
@property (strong, nonatomic) IBOutlet UIImageView *filterAreaImgView;
@property (strong, nonatomic) IBOutlet UIImageView *filterNetbarImgView;
@property (strong, nonatomic) IBOutlet UIButton *filterAreaButton;
@property (strong, nonatomic) IBOutlet UIButton *filterNetbarButton;

- (IBAction)filterAreaAction:(id)sender;
- (IBAction)filterNetbarAction:(id)sender;

@property (assign, nonatomic) SInt32 teamCursor;
@property (assign, nonatomic) BOOL teamLoadMore;

@end

@implementation MatchTeamsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filterContainerView.hidden = YES;

    if (_showFilter) {
        _filterAreaArray = [[NSMutableArray alloc] init];
        _filterNetbarArray = [[NSMutableArray alloc] init];
        _filterType = 0;
        _filterAreaName = @"选择市";
        _filterAreaCode = nil;
        _filterNetbarName = @"排序";
        _filterPriceType = nil;
        self.filterContainerView.hidden = NO;
        CGRect frame = self.teamTableView.frame;
        frame.origin.y = self.filterContainerView.frame.origin.y + self.filterContainerView.frame.size.height;
        frame.size.height = self.view.bounds.size.height - frame.origin.y;
        self.teamTableView.frame = frame;
//        [self refreshFilterAreaData];
//        [self refreshFilterPriceData];
    }
    
    [self initControlUI];
    [self refreshTeamInfos];
    
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
        [[WYEngine shareInstance] getMatchJoinedTeamWithUid:[WYEngine shareInstance].uid activityId:weakSelf.activityId netbarId:weakSelf.filterNetbarId areaCode:weakSelf.filterAreaCode page:weakSelf.teamCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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

- (void)initControlUI{
    self.filterBottomImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
    self.filterMiddleImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
    CGRect frame = self.filterBottomImgView.frame;
    frame.size.height = 0.5;
    self.filterBottomImgView.frame = frame;
    frame = self.filterMiddleImgView.frame;
    frame.size.width = 0.5;
    self.filterMiddleImgView.frame = frame;
    
    self.filterAreaLabel.textColor = SKIN_TEXT_COLOR1;
    self.filterAreaLabel.font = SKIN_FONT_FROMNAME(14);
    self.filterNetbarLabel.textColor = SKIN_TEXT_COLOR1;
    self.filterNetbarLabel.font = SKIN_FONT_FROMNAME(14);
    [self refreshFilterViewShowUI];
}

- (void)refreshFilterViewShowUI{
    self.filterAreaLabel.text = _filterAreaName;
    self.filterNetbarLabel.text = _filterNetbarName;
    CGFloat textWidth = [WYCommonUtils widthWithText:_filterAreaName font:self.filterAreaLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = self.filterAreaLabel.frame;
    frame.origin.x = SCREEN_WIDTH/4-textWidth/2-7;
    frame.size.width = textWidth;
    self.filterAreaLabel.frame = frame;
    frame = self.filterAreaImgView.frame;
    frame.origin.x = self.filterAreaLabel.frame.origin.x + self.filterAreaLabel.frame.size.width + 5;
    self.filterAreaImgView.frame = frame;
    
    textWidth = [WYCommonUtils widthWithText:_filterNetbarName font:self.filterNetbarLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.filterNetbarLabel.frame;
    frame.origin.x = SCREEN_WIDTH/4-textWidth/2-7;
    frame.size.width = textWidth;
    self.filterNetbarLabel.frame = frame;
    frame = self.filterNetbarImgView.frame;
    frame.origin.x = self.filterNetbarLabel.frame.origin.x + self.filterNetbarLabel.frame.size.width + 5;
    self.filterNetbarImgView.frame = frame;
}

- (void)refreshTeamInfos {
    _teamCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchJoinedTeamWithUid:[WYEngine shareInstance].uid activityId:_activityId netbarId:_filterNetbarId areaCode:_filterAreaCode page:_teamCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
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
        
        weakSelf.teamLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.teamLoadMore) {
            weakSelf.teamTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.teamTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.teamCursor ++;
        }
        if (weakSelf.filterNetbarArray.count == 0 || weakSelf.filterAreaArray.count == 0) {
            NSArray *netbarDicArray = [[jsonRet objectForKey:@"object"] objectForKey:@"condition"];
            for (NSDictionary *dic in netbarDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
                [netbarInfo setNetbarInfoByJsonDic:dic];
                [weakSelf.netbarInfos addObject:netbarInfo];
            }
            
            [weakSelf refreshFilterDataSource:weakSelf.netbarInfos];
        }
    }tag:tag];
}

- (void)refreshFilterDataSource:(NSArray *)netbarDicArray
{
    //蛋疼的数据
    for (WYNetbarInfo *info in netbarDicArray) {
        NSMutableDictionary *netbarDic = [[NSMutableDictionary alloc] init];
        [netbarDic setValue:info.netbarName forKey:@"netbarName"];
        [netbarDic setValue:info.nid forKey:@"netbarId"];
        [_filterNetbarArray addObject:netbarDic];
        
        if (_filterAreaArray.count == 0) {
            NSMutableDictionary *areaDic = [[NSMutableDictionary alloc] init];
            [areaDic setValue:info.areaCode forKey:@"areaCode"];
            [areaDic setValue:info.city forKey:@"city"];
            [_filterAreaArray addObject:areaDic];
        }else {
            BOOL flag = NO;
            for (NSDictionary *dic in _filterAreaArray) {
                if ([info.city isEqualToString:[dic objectForKey:@"city"]]) {
                    flag = YES;
                }
            }
            if (!flag) {
                NSMutableDictionary *areaDic = [[NSMutableDictionary alloc] init];
                [areaDic setValue:info.areaCode forKey:@"areaCode"];
                [areaDic setValue:info.city forKey:@"city"];
                [_filterAreaArray addObject:areaDic];
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.filterTableView) {
        if (_filterType == 0) {
            return self.filterAreaArray.count;
        }else if (_filterType == 1) {
            return self.filterNetbarArray.count;
        }else {
            return 0;
        }
    }
    return self.teamInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.filterTableView){
        return 36;
    }
    return 108;
}

static int filterLabel_Tag = 202, filterLineImg_Tag = 203;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.teamTableView) {
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
    }else if (tableView == self.filterTableView){
        static NSString *CellIdentifier = @"filterTableViewCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIImageView *botLineImgView = [[UIImageView alloc] init];
            botLineImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
            botLineImgView.frame = CGRectMake(12, 35, self.view.bounds.size.width-24, 0.5);
            botLineImgView.tag = filterLineImg_Tag;
            [cell addSubview:botLineImgView];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width-12*2, 36)];
            nameLabel.tag = filterLabel_Tag;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.numberOfLines = 1;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.font = SKIN_FONT_FROMNAME(12);
            [cell addSubview:nameLabel];
            cell.backgroundColor = [UIColor clearColor];
        }
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:filterLabel_Tag];
        UIImageView *botImgView = (UIImageView *)[cell viewWithTag:filterLineImg_Tag];
        if (_filterType == 0) {
            NSDictionary *infoDic = _filterAreaArray[indexPath.row];
            nameLabel.text = [infoDic stringObjectForKey:@"city"];
            if ([[infoDic stringObjectForKey:@"areaCode"] isEqualToString:_filterAreaCode]) {
                nameLabel.textColor = UIColorToRGB(0xa58600);
                botImgView.backgroundColor = UIColorToRGB(0xa58600);
            }else{
                nameLabel.textColor = SKIN_TEXT_COLOR2;
                botImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
            }
        }else if (_filterType == 1){
            NSDictionary *infoDic = _filterNetbarArray[indexPath.row];
            nameLabel.text = [infoDic stringObjectForKey:@"netbarName"];
            if ([[infoDic stringObjectForKey:@"netbarId"] isEqualToString:_filterNetbarId]) {
                nameLabel.textColor = UIColorToRGB(0xa58600);
                botImgView.backgroundColor = UIColorToRGB(0xa58600);
            }else{
                nameLabel.textColor = SKIN_TEXT_COLOR2;
                botImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
            }
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.filterTableView){
        [self.teamTableView setContentOffset:CGPointMake(0, 0 - self.teamTableView.contentInset.top) animated:NO];
        if (_filterType == 0) {
            NSDictionary *infoDic = _filterAreaArray[indexPath.row];
            _filterAreaName = [infoDic stringObjectForKey:@"city"];
            _filterAreaCode = [infoDic stringObjectForKey:@"areaCode"];
            [self showFilterViewWith:NO];
            [self refreshFilterViewShowUI];
            [self refreshTeamInfos];
        }else if (_filterType == 1){
            NSDictionary *infoDic = _filterNetbarArray[indexPath.row];
            _filterNetbarName = [infoDic stringObjectForKey:@"netbarName"];
            _filterNetbarId = [infoDic stringObjectForKey:@"netbarId"];
            [self showFilterViewWith:NO];
            [self refreshFilterViewShowUI];
            [self refreshTeamInfos];
        }
    }
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
    _filterTableView.delegate = nil;
    _filterTableView.dataSource = nil;
}

- (IBAction)filterAreaAction:(id)sender {
    _filterType = 0;
    self.filterAreaButton.selected = !self.filterAreaButton.selected;
    BOOL showOpen = self.filterAreaButton.selected;
    if (self.filterNetbarButton.selected) {
        showOpen = YES;
        self.filterNetbarButton.selected = !self.filterNetbarButton.selected;
    }
    [self showFilterViewWith:showOpen];
}

- (IBAction)filterNetbarAction:(id)sender {
    _filterType = 1;
    self.filterNetbarButton.selected = !self.filterNetbarButton.selected;
    BOOL showOpen = self.filterNetbarButton.selected;
    if (self.filterAreaButton.selected) {
        showOpen = YES;
        self.filterAreaButton.selected = !self.filterAreaButton.selected;
    }
    [self showFilterViewWith:showOpen];
}

- (void)showFilterViewWith:(BOOL)showOpen {
    if (showOpen) {
        
        if (_bgMarkButtonView.superview) {
            [_bgMarkButtonView removeFromSuperview];
        }
        
        CGRect frame = self.filterTableContainerView.frame;
        frame.origin.y = self.filterContainerView.frame.origin.y + self.filterContainerView.frame.size.height;
        frame.size.width = self.view.bounds.size.width;
        frame.size.height = 0;
        self.filterTableContainerView.frame = frame;
        [self.view addSubview:self.filterTableContainerView];
        [self.view insertSubview:self.filterTableContainerView belowSubview:self.filterContainerView];
        
        CGFloat filterContainerViewHeight = 250;
        if (self.filterAreaButton.selected) {
            filterContainerViewHeight = self.filterAreaArray.count*36+1;
        }else if (self.filterNetbarButton.selected){
            filterContainerViewHeight = self.filterNetbarArray.count*36+1;
        }
        if (filterContainerViewHeight>250) {
            filterContainerViewHeight = 250;
        }
        if (filterContainerViewHeight < 144) {
            filterContainerViewHeight = 144;
        }
        
        [self.filterTableView reloadData];
        
        _bgMarkButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgMarkButtonView.frame = self.view.bounds;
        [_bgMarkButtonView addTarget:self action:@selector(hiddenFilterViewAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bgMarkButtonView];
        [self.view insertSubview:_bgMarkButtonView belowSubview:self.filterTableContainerView];
        _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        if (_filterType == 0) {
            _filterNetbarImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        }else if (_filterType == 1){
            _filterAreaImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        }
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.filterTableContainerView.frame;
            frame.size.height = filterContainerViewHeight;
            self.filterTableContainerView.frame = frame;
            _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
            if (_filterType == 0) {
                _filterAreaImgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            }else if (_filterType == 1){
                _filterNetbarImgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            }
        } completion:^(BOOL finished) {
            _filterAreaImgView.highlighted = _filterAreaButton.selected;
            _filterNetbarImgView.highlighted = _filterNetbarButton.selected;
        }];
    }else{
        self.filterAreaButton.selected = NO;
        self.filterNetbarButton.selected = NO;
        if (self.filterTableContainerView.superview) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.filterTableContainerView.frame;
                frame.size.height = 0;
                self.filterTableContainerView.frame = frame;
                _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                if (_filterType == 0) {
                    _filterAreaImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
                }else if (_filterType == 1){
                    _filterNetbarImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
                }
            } completion:^(BOOL finished) {
                _filterAreaImgView.highlighted = _filterAreaButton.selected;
                _filterNetbarImgView.highlighted = _filterNetbarButton.selected;
                [self.filterTableContainerView removeFromSuperview];
                [_bgMarkButtonView removeFromSuperview];
            }];
        }
    }
}

-(void)hiddenFilterViewAction{
    [self showFilterViewWith:NO];
}

@end
