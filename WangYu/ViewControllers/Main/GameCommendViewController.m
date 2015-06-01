//
//  GameCommendViewController.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameCommendViewController.h"
#import "ZLSwipeableView.h"
#import "GameCommendCardView.h"
#import "UIImageView+WebCache.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYGameInfo.h"
#import "GameDetailsViewController.h"
#import "WYTabBarViewController.h"

@interface GameCommendViewController () <ZLSwipeableViewDataSource,
ZLSwipeableViewDelegate,GameCommendCardViewDelegate>
{
    WYGameInfo *_selectedGameInfo;
}
@property (nonatomic, weak) IBOutlet ZLSwipeableView *swipeableView;
@property (nonatomic, strong) IBOutlet UIView *handleView;
@property (nonatomic, strong) IBOutlet UIButton *collectButton;
@property (nonatomic, strong) IBOutlet UILabel *collectLabel;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) IBOutlet UILabel *downloadLabel;

@property (nonatomic, strong) NSMutableArray *gameCommendInfos;
@property (nonatomic, assign) NSUInteger gameIndex;
@property (nonatomic, assign) NSInteger currentIndex;


- (IBAction)downloadAction:(id)sender;
- (IBAction)collectAction:(id)sender;


@end

@implementation GameCommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gameIndex = 0;
    self.currentIndex = 0;
    
    [self getCacheGameList];
    [self refreshGameInfos];
    
//    self.gameCommendInfos = @[@{@"gameName":@"网娱大师",@"pic":@"http://g.hiphotos.baidu.com/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=b7b1938d6e81800a7ae8815cd05c589f/bba1cd11728b4710dffb97cec1cec3fdfd0323df.jpg",@"des":@"网娱大师欢迎您快来下载吧 我擦我"},
//                    @{@"gameName":@"全民突击",@"pic":@"http://www.fpwap.com/UploadFiles/news/yxgl/2015/01/19/07984252425d6a0664050fdead0fbeb0.jpg",@"des":@"不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我擦不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我"},
//                    @{@"gameName":@"天天酷跑",@"pic":@"http://p3.image.hiapk.com/uploads/allimg/150130/930-150130134155.jpg",@"des":@"不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我擦不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我"},
//                    @{@"gameName":@"美女约",@"pic":@"http://f.hiphotos.baidu.com/image/pic/item/32fa828ba61ea8d3b8462a09950a304e251f5852.jpg",@"des":@"约起来吧 朋友趁还年轻还能约得动 尽情的释放你的激情 哈哈哈哈哈哈哈哈"}
//                    ];
    self.swipeableView.delegate = self;
    
    [self refreshUI];
}
- (void)viewDidLayoutSubviews {
    // Required Data Source
    self.swipeableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"手游"];
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

-(void)getCacheGameList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getGameListWithPage:1 pageSize:10 tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.gameCommendInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
                [gameInfo setGameInfoByJsonDic:dic];
                [weakSelf.gameCommendInfos addObject:gameInfo];
            }
            [weakSelf.swipeableView loadNextSwipeableViewsIfNeeded];
        }
    }];
}
-(void)refreshGameInfos{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getGameListWithPage:1 pageSize:10 tag:tag];
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
        weakSelf.gameCommendInfos = [[NSMutableArray alloc] init];
        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
        for (NSDictionary *dic in object) {
            WYGameInfo *gameInfo = [[WYGameInfo alloc] init];
            [gameInfo setGameInfoByJsonDic:dic];
            [weakSelf.gameCommendInfos addObject:gameInfo];
        }
        [weakSelf.swipeableView loadNextSwipeableViewsIfNeeded];
    }tag:tag];
}

-(void)refreshUI{
    [self.view insertSubview:self.handleView belowSubview:self.swipeableView];
    self.collectLabel.font = SKIN_FONT_FROMNAME(14);
    self.collectLabel.textColor = SKIN_TEXT_COLOR1;
    self.downloadLabel.font = SKIN_FONT_FROMNAME(14);
    self.downloadLabel.textColor = SKIN_TEXT_COLOR1;
    
}

-(void)collectGame{
    
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] collectGameWithUid:[WYEngine shareInstance].uid gameId:_selectedGameInfo.gameId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        BOOL isFavor = [[jsonRet dictionaryObjectForKey:@"object"] boolValueForKey:@"isFavor"];
        if (isFavor) {
            [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromBottom ForView:self.collectButton];
            [WYProgressHUD AlertSuccess:@"游戏收藏成功" At:weakSelf.view];
        }else{
            [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromTop ForView:self.collectButton];
            [WYProgressHUD AlertSuccess:@"游戏取消收藏成功" At:weakSelf.view];
        }
        
    }tag:tag];
    
}

-(void)getSelectedGameInfo{
    _selectedGameInfo = nil;
    if (self.currentIndex >= 0 && self.currentIndex < self.gameCommendInfos.count) {
        _selectedGameInfo = [self.gameCommendInfos objectAtIndex:self.currentIndex];
    }
}

#pragma mark - IBAction
- (IBAction)downloadAction:(id)sender {
    WYLog(@"self.currentIndex = %d",(int)self.currentIndex);
    [self getSelectedGameInfo];
}

- (IBAction)collectAction:(id)sender {
    WYLog(@"self.currentIndex = %d",(int)self.currentIndex);
    [self getSelectedGameInfo];
    [self collectGame];
}

#pragma mark - ZLSwipeableViewDelegate
- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
//    NSLog(@"did swipe in direction: %zd", direction);
    NSInteger viewTag = view.tag + 1;
    if (viewTag == self.gameCommendInfos.count) {
        viewTag = 0;
    }
    self.currentIndex = viewTag;
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
       didCancelSwipe:(UIView *)view {
//    NSLog(@"did cancel swipe");
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
//    NSLog(@"did start swiping at location: x %f, y %f", location.x, location.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
          swipingView:(UIView *)view
           atLocation:(CGPoint)location
          translation:(CGPoint)translation {
//    NSLog(@"swiping at location: x %f, y %f, translation: x %f, y %f",location.x, location.y, translation.x, translation.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
//    NSLog(@"did end swiping at location: x %f, y %f", location.x, location.y );
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    if (self.gameIndex < self.gameCommendInfos.count) {
        
//        GameCommendCardView *view = [[[NSBundle mainBundle] loadNibNamed:@"GameCommendCardView" owner:nil options:nil] objectAtIndex:0];
        GameCommendCardView *view = [[GameCommendCardView alloc] init];
        view.delegate = self;
        view.frame = swipeableView.bounds;
        view.tag = self.gameIndex;
        
        WYGameInfo *gameInfo = self.gameCommendInfos[self.gameIndex];
        view.gameNameLabel.text = gameInfo.gameName;
        view.gameDesLabel.text = gameInfo.gameIntro;
        view.gameVersionLabel.text = [NSString stringWithFormat:@"版本%@",gameInfo.version];
        view.likeLabel.text = [NSString stringWithFormat:@"%d",gameInfo.favorCount];
        [view.gameImageView sd_setImageWithURL:gameInfo.gameCoverUrl placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
        
        
        self.gameIndex++;
        return view;
    }
    self.gameIndex = 0;
    return nil;
}

#pragma mark - GameCommendCardViewDelegate
-(void)gameCommendCardViewClick{
    [self getSelectedGameInfo];
    GameDetailsViewController *gameVc = [[GameDetailsViewController alloc] init];
    gameVc.gameInfo = _selectedGameInfo;
    [self.navigationController pushViewController:gameVc animated:YES];
}

@end
