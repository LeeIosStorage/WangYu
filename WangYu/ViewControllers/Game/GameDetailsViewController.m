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

#define ONE_IMAGE_HEIGHT  40
#define item_spacing  15

@interface GameDetailsViewController ()<UITableViewDataSource,UITableViewDelegate,GMGridViewDataSource, GMGridViewActionDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *likeImages;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIView *headContainerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *basicContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *gameIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameSizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDowloadCounLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameDowloadTipLabel;
@property (strong, nonatomic) IBOutlet UIView *gameContentContainerView;
@property (strong, nonatomic) IBOutlet UILabel *contentTipLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameContentLabel;
@property (strong, nonatomic) IBOutlet UIView *likeContainerView;
@property (strong, nonatomic) IBOutlet UILabel *likeTipLabel;
@property (strong, nonatomic) IBOutlet GMGridView *likeImageGridView;

@end

@implementation GameDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _likeImages = [[NSMutableArray alloc] init];
    
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
    [[WYEngine shareInstance] getGameDetailsWithGameId:_gameInfo.gameId tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.gameInfo = [[WYGameInfo alloc] init];
            NSDictionary *object = [[jsonRet dictionaryObjectForKey:@"object"] dictionaryObjectForKey:@"game"];
            [weakSelf.gameInfo setGameInfoByJsonDic:object];
            
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
    [[WYEngine shareInstance] getGameDetailsWithGameId:_gameInfo.gameId tag:tag];
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
        
        weakSelf.likeImages = [[NSMutableArray alloc] init];
        NSArray *likes = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"recommendations"];
        for (NSDictionary *dic in likes) {
            [weakSelf.likeImages addObject:dic];
        }
        
        [weakSelf refreshGameHeadViewShow];
        
    }tag:tag];
}

#pragma mark - custom
-(void)refreshGameHeadViewShow{
    
    [self.gameIconImageView sd_setImageWithURL:_gameInfo.gameIconUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    self.gameNameLabel.text = _gameInfo.gameName;
    self.gameSizeLabel.text = [NSString stringWithFormat:@"大小：%d",_gameInfo.iosFileSize];
    self.gameDowloadCounLabel.text = [NSString stringWithFormat:@"%d",_gameInfo.downloadCount];
    self.gameContentLabel.text = _gameInfo.gameIntro;
    
    
    [self.likeImageGridView reloadData];
    
    self.headContainerView.backgroundColor = self.view.backgroundColor;
    self.tableView.tableHeaderView = self.headContainerView;
}

#pragma mark - GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _likeImages.count;
    
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    
    return CGSizeMake(ONE_IMAGE_HEIGHT, ONE_IMAGE_HEIGHT);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
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
    NSDictionary *dic = _likeImages[position];
    GameDetailsViewController *gameVc = [[GameDetailsViewController alloc] init];
    WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
    gameInfo.gameId = [dic stringObjectForKey:@"id"];
    gameVc.gameInfo = gameInfo;
    
    [self.navigationController pushViewController:gameVc animated:YES];
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
