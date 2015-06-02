//
//  GameDetailsViewController.m
//  WangYu
//
//  Created by KID on 15/6/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameDetailsViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridViewCell+Extended.h"
#import "UIImageView+WebCache.h"
#import "WYShareActionSheet.h"
#import "WYCommonUtils.h"

#define ONE_IMAGE_HEIGHT  40
#define item_spacing  15

@interface GameDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,GMGridViewDataSource, GMGridViewActionDelegate,UIScrollViewDelegate,WYShareActionSheetDelegate>
{
    WYShareActionSheet *_shareAction;
    BOOL _isMore;
}
@property (nonatomic, strong) NSMutableArray *likeImages;
@property (nonatomic, strong) NSMutableArray *coverImages;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *headContainerView;
@property (strong, nonatomic) IBOutlet GMGridView *coverGridView;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UIView *basicContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *gameIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDowloadCounLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDowloadTipLabel;
@property (strong, nonatomic) IBOutlet UIView *gameContentContainerView;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel1;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel2;
@property (strong, nonatomic) IBOutlet UILabel *contentTipLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameContentLabel;
@property (strong, nonatomic) IBOutlet UIView *likeContainerView;
@property (strong, nonatomic) IBOutlet UILabel *likeTipLabel;
@property (strong, nonatomic) IBOutlet GMGridView *likeImageGridView;

@property (strong, nonatomic) IBOutlet UIButton *collectButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *downloadButton;

- (IBAction)collectAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)downloadAction:(id)sender;
- (IBAction)moreContentAction:(id)sender;

@end

@implementation GameDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _likeImages = [[NSMutableArray alloc] init];
    _coverImages = [[NSMutableArray alloc] init];
    
    self.gameIconImageView.clipsToBounds = YES;
    self.gameIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.gameNameLabel.textColor = SKIN_TEXT_COLOR1;
    self.gameNameLabel.font = SKIN_FONT_FROMNAME(15);
    self.gameSizeLabel.textColor = SKIN_TEXT_COLOR2;
    self.gameSizeLabel.font = SKIN_FONT_FROMNAME(12);
    self.gameDowloadCounLabel.textColor = UIColorToRGB(0xf03f3f);
    self.gameDowloadCounLabel.font = SKIN_FONT_FROMNAME(12);
    self.gameDowloadTipLabel.textColor = SKIN_TEXT_COLOR2;
    self.gameDowloadTipLabel.font = SKIN_FONT_FROMNAME(12);
    self.contentTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.contentTipLabel.font = SKIN_FONT_FROMNAME(15);
    self.likeTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.likeTipLabel.font = SKIN_FONT_FROMNAME(15);
    self.gameContentLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.colorLabel1.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel1.layer.cornerRadius = 1.0;
    self.colorLabel1.layer.masksToBounds = YES;
    self.colorLabel2.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel2.layer.cornerRadius = 1.0;
    self.colorLabel2.layer.masksToBounds = YES;
    
    [self.downloadButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.downloadButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.downloadButton.backgroundColor = SKIN_COLOR;
    self.downloadButton.layer.cornerRadius = 4.0;
    self.downloadButton.layer.masksToBounds = YES;
    
    self.pageControl.currentPageIndicatorTintColor = SKIN_COLOR;
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    
    NSInteger spacing = item_spacing;
    _likeImageGridView.style = GMGridViewStyleSwap;
    _likeImageGridView.itemSpacing = spacing;
    _likeImageGridView.minEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    _likeImageGridView.centerGrid = NO;
    _likeImageGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontal];
    _likeImageGridView.actionDelegate = self;
    _likeImageGridView.showsHorizontalScrollIndicator = NO;
    _likeImageGridView.showsVerticalScrollIndicator = NO;
    _likeImageGridView.dataSource = self;
    _likeImageGridView.scrollsToTop = NO;
    _likeImageGridView.delegate = self;
    
    
    _coverGridView.style = GMGridViewStyleSwap;
    _coverGridView.itemSpacing = 0;
    _coverGridView.minEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _coverGridView.centerGrid = NO;
    _coverGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutHorizontalPagedLTR];
    _coverGridView.actionDelegate = self;
    _coverGridView.showsHorizontalScrollIndicator = NO;
    _coverGridView.showsVerticalScrollIndicator = NO;
    _coverGridView.dataSource = self;
    _coverGridView.scrollsToTop = NO;
    _coverGridView.delegate = self;
    
    
    [self getCacheGameInfo];
    [self refreshGameInfo];
    
    [self refreshGameHeadViewShow];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"游戏详情"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getCacheGameInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getGameDetailsWithGameId:_gameInfo.gameId uid:[WYEngine shareInstance].uid tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.gameInfo = [[WYGameInfo alloc] init];
            NSDictionary *object = [[jsonRet dictionaryObjectForKey:@"object"] dictionaryObjectForKey:@"game"];
            [weakSelf.gameInfo setGameInfoByJsonDic:object];
            
            [weakSelf setCoverImageURLs];
            
            weakSelf.likeImages = [[NSMutableArray alloc] init];
            NSArray *likes = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"recommendations"];
            for (NSDictionary *dic in likes) {
                [weakSelf.likeImages addObject:dic];
            }
            
            [weakSelf refreshGameHeadViewShow];
        }
    }];
}
-(void)refreshGameInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getGameDetailsWithGameId:_gameInfo.gameId uid:[WYEngine shareInstance].uid tag:tag];
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
        
        weakSelf.gameInfo = [[WYGameInfo alloc] init];
        NSDictionary *object = [[jsonRet dictionaryObjectForKey:@"object"] dictionaryObjectForKey:@"game"];
        [weakSelf.gameInfo setGameInfoByJsonDic:object];
        
        [weakSelf setCoverImageURLs];
        
        weakSelf.likeImages = [[NSMutableArray alloc] init];
        NSArray *likes = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"recommendations"];
        for (NSDictionary *dic in likes) {
            [weakSelf.likeImages addObject:dic];
        }
        
        [weakSelf refreshGameHeadViewShow];
        
    }tag:tag];
}

-(void)setCoverImageURLs{
    _coverImages = [[NSMutableArray alloc] init];
    self.coverImages = [[NSMutableArray alloc] initWithArray:_gameInfo.coverURLs];
}

-(void)collectGame{
    
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] collectGameWithUid:[WYEngine shareInstance].uid gameId:_gameInfo.gameId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        self.collectButton.enabled = YES;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        int isFavor = [[jsonRet dictionaryObjectForKey:@"object"] intValueForKey:@"isFavor"];
        weakSelf.gameInfo.isFavor = isFavor;
        if (isFavor == 1) {
//            weakSelf.gameInfo.favorCount ++;
            [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromBottom ForView:self.collectButton];
            [WYProgressHUD AlertSuccess:@"游戏收藏成功" At:weakSelf.view];
        }else{
//            weakSelf.gameInfo.favorCount --;
            [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromTop ForView:self.collectButton];
            [WYProgressHUD AlertSuccess:@"游戏取消收藏成功" At:weakSelf.view];
        }
        [weakSelf refreshGameHeadViewShow];
        
    }tag:tag];
    
}

#pragma mark - custom
-(void)refreshGameHeadViewShow{
    
    [self.gameIconImageView sd_setImageWithURL:_gameInfo.gameIconUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    self.gameNameLabel.text = _gameInfo.gameName;
    self.gameSizeLabel.text = [NSString stringWithFormat:@"大小：%dM",_gameInfo.iosFileSize];
    self.gameDowloadCounLabel.text = [NSString stringWithFormat:@"%d",_gameInfo.downloadCount];
    self.gameContentLabel.text = _gameInfo.gameIntro;
    if (self.gameInfo.isFavor == 1) {
        [self.collectButton setImage:[UIImage imageNamed:@"netbar_detail_collect_icon"] forState:UIControlStateNormal];
    }else {
        [self.collectButton setImage:[UIImage imageNamed:@"netbar_detail_uncollect_icon"] forState:UIControlStateNormal];
    }
    
    [self.coverGridView reloadData];
    [self.likeImageGridView reloadData];
    
    self.pageControl.hidden = YES;
    if (_coverImages.count > 1) {
        self.pageControl.hidden = NO;
    }
    self.pageControl.numberOfPages = _coverImages.count;
    CGRect frame = self.pageControl.frame;
    frame.size.width = _coverImages.count*13;
    frame.origin.x = SCREEN_WIDTH-frame.size.width-24;
    self.pageControl.frame = frame;
    
    CGSize textSize = [WYCommonUtils sizeWithText:_gameInfo.gameIntro font:self.gameContentLabel.font width:SCREEN_WIDTH-15*2];
    if (!_isMore) {
        if (textSize.height > 43) {
            textSize.height = 43;
        }
    }
    frame = self.gameContentLabel.frame;
    frame.size.height = textSize.height;
    self.gameContentLabel.frame = frame;
    
    
    frame = self.gameContentContainerView.frame;
    frame.size.height = self.gameContentLabel.frame.origin.y + self.gameContentLabel.frame.size.height + 12;
    self.gameContentContainerView.frame = frame;
    
    frame = self.likeContainerView.frame;
    frame.origin.y = self.gameContentContainerView.frame.origin.y + self.gameContentContainerView.frame.size.height + 10;
    self.likeContainerView.frame = frame;
    
    frame = self.headContainerView.frame;
    frame.size.height = self.likeContainerView.frame.origin.y + self.likeContainerView.frame.size.height;
    self.headContainerView.frame = frame;
    
    self.headContainerView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = self.headContainerView;
}

#pragma mark - IBAction
- (IBAction)collectAction:(id)sender {
    
    if ([[WYEngine shareInstance] needUserLogin:nil]) {
        return;
    }
    self.collectButton.enabled = NO;
    [self collectGame];
}

- (IBAction)shareAction:(id)sender {
    _shareAction = [[WYShareActionSheet alloc] init];
    _shareAction.gameInfo = _gameInfo;
    _shareAction.owner = self;
    [_shareAction showShareAction];
}

- (IBAction)downloadAction:(id)sender {
    
}

- (IBAction)moreContentAction:(id)sender{
    _isMore = !_isMore;
    [self refreshGameHeadViewShow];
}
#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    if (_coverGridView == gridView) {
        return _coverImages.count;
    }
    return _likeImages.count;
    
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    if (_coverGridView == gridView) {
        return CGSizeMake(SCREEN_WIDTH, 150);
    }
    return CGSizeMake(ONE_IMAGE_HEIGHT, ONE_IMAGE_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    if (gridView == _coverGridView) {
        if (!cell)
        {
            cell = [[GMGridViewCell alloc] init];
            UIImageView* imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            cell.contentView = imageView;
            
        }
        UIImageView* imageView = (UIImageView* )cell.contentView;
        NSURL *pidUrl = _coverImages[index];
        [imageView sd_setImageWithURL:pidUrl placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
        return cell;
        
    }
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIImageView* imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        cell.contentView = imageView;
        
    }
    UIImageView* imageView = (UIImageView* )cell.contentView;
    NSDictionary *dic = _likeImages[index];
    NSURL *pidUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[[WYEngine shareInstance] baseImgUrl],[dic stringObjectForKey:@"icon"]]];
    [imageView sd_setImageWithURL:pidUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    return cell;
}
#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    WYLog(@"Did tap at index %ld", position);
    if (_coverGridView == gridView) {
        
        return;
    }
    
    NSDictionary *dic = _likeImages[position];
    WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
    gameInfo.gameId = [dic stringObjectForKey:@"id"];
    
    if ([gameInfo.gameId isEqualToString:_gameInfo.gameId]) {
        //当前游戏
        return;
    }
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[GameDetailsViewController class]]) {
            GameDetailsViewController *gameVc = (GameDetailsViewController *)vc;
            if ([gameVc.gameInfo.gameId isEqualToString:gameInfo.gameId]) {
                [self.navigationController popToViewController:gameVc animated:YES];
                return;
            }
        }
    }
    GameDetailsViewController *gameVc = [[GameDetailsViewController alloc] init];
    gameVc.gameInfo = gameInfo;
    [self.navigationController pushViewController:gameVc animated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == _coverGridView) {
        CGFloat pageWidth = _coverGridView.frame.size.width;
        int currentPage = floor((_coverGridView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = currentPage;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
