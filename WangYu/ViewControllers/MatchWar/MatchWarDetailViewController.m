//
//  MatchWarDetailViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchWarDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "SettingViewCell.h"
#import "MatchCommentViewCell.h"

#define MATCH_DETAIL_TYPE_INFO          0
#define MATCH_DETAIL_TYPE_COMMENT       1

@interface MatchWarDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *matchInfoTableView;
@property (strong, nonatomic) NSMutableArray *commentInfos;
@property (nonatomic, strong) IBOutlet UITableView *commentTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  commentNextCursor;
@property (assign, nonatomic) BOOL commentCanLoadMore;

@property (nonatomic, strong) IBOutlet UIView *matchHeadContainerView;
@property (nonatomic, strong) UIView   *supInfoHeadView;
@property (nonatomic, strong) UIView   *supCommentHeadView;
@property (nonatomic, strong) IBOutlet UIImageView *bkImageView;
@property (nonatomic, strong) IBOutlet UIView *segmentView;
@property (nonatomic, strong) IBOutlet UIImageView *segmentMoveImageView;
@property (nonatomic, strong) IBOutlet UILabel *infoTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *infoTabButton;
@property (nonatomic, strong) IBOutlet UILabel *commentNumTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *commentTabButton;

-(IBAction)matchInfoAction:(id)sender;
-(IBAction)commentSegmentAction:(id)sender;

@end

@implementation MatchWarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.supInfoHeadView = [[UIView alloc] init];
    self.supInfoHeadView.backgroundColor = [UIColor clearColor];
    self.supCommentHeadView = [[UIView alloc] init];
    self.supCommentHeadView.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setContentInsetForScrollView:self.matchInfoTableView inset:inset];
    [self setContentInsetForScrollView:self.commentTableView inset:inset];
    
    _selectedSegmentIndex = 0;
    [self refreshHeadViewShow];
    
    [self feedsTypeSwitch:MATCH_DETAIL_TYPE_INFO needRefreshFeeds:YES];
    
    
    self.commentTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
//    [self setTitle:@"约战详情"];
    self.titleNavBar.backgroundColor = [UIColor clearColor];
    [self setBarBackgroundColor:[UIColor clearColor] showLine:NO];
    [self.titleNavBarLeftButton setTintColor:[UIColor whiteColor]];
}

-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == MATCH_DETAIL_TYPE_INFO) {
        //减速率
        self.commentTableView.decelerationRate = 0.0f;
        self.matchInfoTableView.decelerationRate = 1.0f;
        self.commentTableView.hidden = YES;
        self.matchInfoTableView.hidden = NO;
        
        if ([self.matchHeadContainerView superview]) {
            [self.matchHeadContainerView removeFromSuperview];
        }
        _supInfoHeadView.frame = self.matchHeadContainerView.frame;
        [_supInfoHeadView addSubview:self.matchHeadContainerView];
        self.matchInfoTableView.tableHeaderView = _supInfoHeadView;
        
        if (needRefresh) {
            [self getCacheMatchWarInfo];
            [self refreshMatchWarInfo];
        }
    }else if (tag == MATCH_DETAIL_TYPE_COMMENT){
        
        self.commentTableView.decelerationRate = 1.0f;
        self.matchInfoTableView.decelerationRate = 0.0f;
        self.matchInfoTableView.hidden = YES;
        self.commentTableView.hidden = NO;
        
        if ([self.matchHeadContainerView superview]) {
            [self.matchHeadContainerView removeFromSuperview];
        }
        _supCommentHeadView.frame = self.matchHeadContainerView.frame;
        [_supCommentHeadView addSubview:self.matchHeadContainerView];
        self.commentTableView.tableHeaderView = _supCommentHeadView;
        
        if (!_commentInfos) {
            [self getCacheCommentInfos];
            [self refreshCommentInfos];
            return;
        }
        if (needRefresh) {
            [self refreshCommentInfos];
        }
    }
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
-(void)refreshHeadViewShow{
    
    [self.bkImageView sd_setImageWithURL:[NSURL URLWithString:@"http://pic.ku.duowan.com/g/1212/246/0g121261408122246_1_600.JPG"] placeholderImage:nil];
    
}

#pragma mark - IBAction
-(IBAction)matchInfoAction:(id)sender{
    if (self.infoTabButton.selected) {
        return;
    }
    self.infoTabButton.selected = YES;
    self.commentTabButton.selected = NO;
    _selectedSegmentIndex = MATCH_DETAIL_TYPE_INFO;
    [self feedsTypeSwitch:(int)_selectedSegmentIndex needRefreshFeeds:NO];
    
    CGPoint center = self.segmentMoveImageView.center;
    center.x = self.infoTabButton.center.x;
    self.segmentMoveImageView.center = center;
}
-(IBAction)commentSegmentAction:(id)sender{
    if (self.commentTabButton.selected) {
        return;
    }
    self.commentTabButton.selected = YES;
    self.infoTabButton.selected = NO;
    _selectedSegmentIndex = MATCH_DETAIL_TYPE_COMMENT;
    [self feedsTypeSwitch:(int)_selectedSegmentIndex needRefreshFeeds:YES];
    
    CGPoint center = self.segmentMoveImageView.center;
    center.x = self.commentTabButton.center.x;
    self.segmentMoveImageView.center = center;
}

#pragma mark - request
-(void)getCacheMatchWarInfo{
    
}
-(void)refreshMatchWarInfo{
    [self.matchInfoTableView reloadData];
}

-(void)getCacheCommentInfos{
    
}
-(void)refreshCommentInfos{
    _commentInfos = [[NSMutableArray alloc] init];
    [_commentInfos addObject:@(0)];
    [_commentInfos addObject:@(0)];
    [_commentInfos addObject:@(0)];
    [self.commentTableView reloadData];
}

#pragma mark - dataModule
-(NSDictionary *)tableDataModule{
    NSDictionary *moduleDict;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    [tmpMutDict setObject:[self matchBasicInfosDict] forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
    moduleDict = tmpMutDict;
    return moduleDict;
}
-(NSDictionary *)matchBasicInfosDict{
    NSDictionary *minfoRows =  nil;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    NSString *intro = _matchWarInfo.itemName;
    NSDictionary *dict00 = @{@"titleLabel": @"竞技项目",
                                 @"icon": @"match_publish_game_icon",
                                 @"intro": intro!=nil?intro:@"",
                                 };
    intro = _matchWarInfo.itemServer;
    NSDictionary *dict01 = @{@"titleLabel": @"服务器",
                             @"icon": @"matchWar_fuwu_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = [WYUIUtils dateDiscriptionFromDate:_matchWarInfo.startTime];
    NSDictionary *dict02 = @{@"titleLabel": @"时间",
                             @"icon": @"match_detail_time_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = nil;
    if (_matchWarInfo.way == 1) {
        intro = @"线上";
    }else if (_matchWarInfo.way ==2){
        intro = [NSString stringWithFormat:@"线下/%@",_matchWarInfo.netbarName];
    }
    NSDictionary *dict03 = @{@"titleLabel": @"地点",
                             @"icon": @"book_wangba",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = _matchWarInfo.spoils;
    NSDictionary *dict04 = @{@"titleLabel": @"联系方式",
                             @"icon": @"match_publish_intro_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = _matchWarInfo.spoils;
    NSDictionary *dict05 = @{@"titleLabel": @"介绍",
                             @"icon": @"match_publish_intro_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    [tmpMutDict setObject:dict00 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict01 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict02 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict03 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict04 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict05 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    
    minfoRows = tmpMutDict;
    return minfoRows;
}

-(NSInteger)newSections{
    
    return [[self tableDataModule] allKeys].count;
}
-(NSInteger)newSectionPolicy:(NSInteger)section{
    
    NSDictionary *rowContentDic = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)section]];
    return [rowContentDic count];
}
-(CGFloat)heightWithRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    NSString *intro = [rowDicts objectForKey:@"intro"];
    UIFont *font = SKIN_FONT_FROMNAME(14);
    CGSize textSize = [WYCommonUtils sizeWithText:intro font:font width:SCREEN_WIDTH-114];
    return textSize.height + 23;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.commentTableView) {
        return 1;
    }
    return [self newSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.commentTableView) {
        return self.commentInfos.count;
    }
    return [self newSectionPolicy:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        return 54;
    }
    return [self heightWithRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        static NSString *CellIdentifier = @"MatchCommentViewCell";
        MatchCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        return cell;
    }
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:0];
    }else if (indexPath.row == [self newSectionPolicy:indexPath.section]-1){
        [cell setLineImageViewWithType:-1];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = NO;
    cell.rightLabel.font = SKIN_FONT_FROMNAME(14);
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = YES;
    
    CGFloat rowHeight = [self heightWithRowAtIndexPath:indexPath];
    CGRect frame = cell.avatarImageView.frame;
    frame.origin.y = (rowHeight-12)/2;
    frame.size.width = 12;
    frame.size.height = 12;
    cell.avatarImageView.frame = frame;
    
    frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 7;
    cell.titleLabel.frame = frame;
    
    //    cell.rightLabel.backgroundColor = [UIColor lightGrayColor];
    cell.rightLabel.autoresizingMask = UIViewAutoresizingNone;
    cell.rightLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    cell.rightLabel.numberOfLines = 0;
    frame = cell.rightLabel.frame;
    frame.origin.x = 102;
    frame.size.width = SCREEN_WIDTH - frame.origin.x - 12;
    cell.rightLabel.frame = frame;
    cell.rightLabel.textAlignment = NSTextAlignmentRight;
    
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    
    cell.titleLabel.text = [rowDicts objectForKey:@"titleLabel"];
    cell.avatarImageView.image = [UIImage imageNamed:[rowDicts objectForKey:@"icon"]];
    
    if (!cell.rightLabel.hidden) {
        NSString *intro = [rowDicts objectForKey:@"intro"];
        cell.rightLabel.text = intro;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        
    }else{
        
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
