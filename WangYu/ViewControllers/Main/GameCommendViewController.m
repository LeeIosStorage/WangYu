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
#import "AppDelegate.h"
#import "WYUserGuideConfig.h"
#import "UIView+Genie.h"

@interface GameCommendViewController () <ZLSwipeableViewDataSource,
ZLSwipeableViewDelegate,GameCommendCardViewDelegate,WYTabBarControllerDelegate>
{
    WYGameInfo *_selectedGameInfo;
}
@property (nonatomic, weak) IBOutlet ZLSwipeableView *swipeableView;
@property (nonatomic, strong) IBOutlet UIView *handleView;
@property (nonatomic, strong) IBOutlet UIButton *collectButton;
@property (nonatomic, strong) IBOutlet UILabel *collectLabel;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) IBOutlet UILabel *downloadLabel;
@property (nonatomic, strong) IBOutlet UIView *likeAnimationView;

@property (nonatomic, strong) NSMutableArray *gameCommendInfos;
@property (nonatomic, assign) NSUInteger gameIndex;
@property (nonatomic, assign) NSInteger currentIndex;

@property (strong, nonatomic) IBOutlet UIView *guideView;
@property (strong, nonatomic) IBOutlet UIView *guideImageView;

@property(assign, nonatomic) BOOL disappearForTabSwitch;//用于判断是否是因为tab切换导致的页面Disappear

- (IBAction)downloadAction:(id)sender;
- (IBAction)collectAction:(id)sender;
- (IBAction)newGuideAction:(id)sender;

@end

@implementation GameCommendViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (self.swipeableView) {
//        if (self.gameCommendInfos.count > 0) {
//            int random = arc4random()%4;
//            WYLog(@"random=%d",random);
//            if (random == 0) {
//                [self.swipeableView swipeTopViewToLeft];
//            }else if (random == 1){
//                [self.swipeableView swipeTopViewToRight];
//            }else if (random == 2){
//                [self.swipeableView swipeTopViewToUp];
//            }else if (random == 3){
//                [self.swipeableView swipeTopViewToDown];
//            }
//        }
//    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
//    if (self.swipeableView && self.disappearForTabSwitch) {
//        if (self.gameCommendInfos.count > 0) {
//            int random = arc4random()%2;
//            WYLog(@"random=%d",random);
//            if (random == 0) {
//                [self.swipeableView swipeTopViewToLeft];
//            }else if (random == 1){
//                [self.swipeableView swipeTopViewToRight];
//            }
//        }
//    }
//    
//    self.disappearForTabSwitch = NO;
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.mainTabViewController.selectedViewController != self) {
        self.disappearForTabSwitch = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gameIndex = 0;
    self.currentIndex = 0;
    [self refreshNewGuideView:NO];

    self.disappearForTabSwitch = YES;
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    appDelegate.mainTabViewController.delegate = self;
    
    [self getCacheGameList];
    [self refreshGameInfos];
    
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

- (void)refreshNewGuideView:(BOOL)isNext {
    self.guideView.frame = [UIScreen mainScreen].bounds;
    BOOL isShow = [[WYUserGuideConfig shareInstance] newPeopleGuideShowForVcType:@"gameCommendView"];
    if (isShow) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:self.guideView];
        UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
        [self.guideImageView addGestureRecognizer:gestureRecongnizer];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.guideView.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.guideView.superview) {
                [self.guideView removeFromSuperview];
                if (isNext) {
                    //...
                }
            }
        }];
    }
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"gameCommendView"];
    [self refreshNewGuideView:NO];
}

- (IBAction)newGuideAction:(id)sender {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"gameCommendView"];
    [self refreshNewGuideView:NO];
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
    [[WYEngine shareInstance] getGameListWithUid:[WYEngine shareInstance].uid page:1 pageSize:20 tag:tag];
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
    [[WYEngine shareInstance] getGameListWithUid:[WYEngine shareInstance].uid page:1 pageSize:20 tag:tag];
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

-(BOOL)isIphone4Device{
    if (SCREEN_HEIGHT == 480) {
        return YES;
    }
    return NO;
}

-(void)refreshUI{
    
    [self.view insertSubview:self.handleView belowSubview:self.swipeableView];
    self.collectLabel.font = SKIN_FONT_FROMNAME(14);
    self.collectLabel.textColor = SKIN_TEXT_COLOR1;
    self.downloadLabel.font = SKIN_FONT_FROMNAME(14);
    self.downloadLabel.textColor = SKIN_TEXT_COLOR1;
    
    
    CGRect frame = self.swipeableView.frame;
    frame.size.width = SCREEN_WIDTH- 20*2;
    frame.size.height = frame.size.width;
    if ([self isIphone4Device]) {
        frame.size.height = 250;
    }
    self.swipeableView.frame = frame;
    
    //handleView frame
    CGSize buttonSize = CGSizeMake(60, 60);
    if ([self isIphone4Device]) {
        buttonSize = CGSizeMake(49, 49);
    }
    float spaceWidth = (SCREEN_WIDTH - buttonSize.width*2)/3;
    self.collectButton.frame = CGRectMake(spaceWidth, 0, buttonSize.width, buttonSize.height);
    self.downloadButton.frame = CGRectMake(spaceWidth*2 + buttonSize.width, 0, buttonSize.width, buttonSize.height);
    self.collectLabel.center = CGPointMake(self.collectButton.center.x, buttonSize.height + 4 + self.collectLabel.frame.size.height/2);
    self.downloadLabel.center = CGPointMake(self.downloadButton.center.x, buttonSize.height + 4 + self.downloadLabel.frame.size.height/2);
    
    float bottomSpace = SCREEN_HEIGHT-self.swipeableView.frame.origin.y-self.swipeableView.frame.size.height-50;
    frame = self.handleView.frame;
    frame.origin.y = self.swipeableView.frame.origin.y+self.swipeableView.frame.size.height+(bottomSpace - frame.size.height)/2;
    if ([self isIphone4Device]) {
        frame.origin.y += 10;
    }
    self.handleView.frame = frame;
}

-(void)refreshGameCardViewUI{
    for (UIView *subViews in self.swipeableView.subviews) {
        for (UIView *subView in subViews.subviews) {
            if ([subView isKindOfClass:[GameCommendCardView class]]) {
                GameCommendCardView *gameCardView = (GameCommendCardView*)subView;
                NSInteger index = gameCardView.tag;
                if (index<0 || index >=self.gameCommendInfos.count) {
                    continue;
                }
                WYGameInfo *gameInfo = [self.gameCommendInfos objectAtIndex:index];
                gameCardView.likeLabel.text = [NSString stringWithFormat:@"%d",gameInfo.favorCount];
                if (gameInfo.isFavor == 1) {
                    gameCardView.likeIconImgView.image = [UIImage imageNamed:@"game_like_icon_selected"];
                }else{
                    gameCardView.likeIconImgView.image = [UIImage imageNamed:@"game_like_icon_selected_not"];
                }
            }
        }
    }

}

-(void)likeViewAnimation:(BOOL)animation{
    if (animation) {
        CGSize likeSize = CGSizeMake(14, 14);
        CGRect startRect = CGRectMake(self.collectButton.frame.origin.x + self.collectButton.frame.size.width/2-likeSize.width/2, self.handleView.frame.origin.y, likeSize.width, likeSize.height);
        UIView *likeView = [[UIView alloc] initWithFrame:startRect];
        likeView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, likeSize.width, likeSize.height)];
        imageView.image = [UIImage imageNamed:@"game_like_icon_selected"];
        [likeView addSubview:imageView];
        
        likeView.hidden = NO;
        [self.view addSubview:likeView];
        
        CGRect endRect = CGRectMake(SCREEN_WIDTH - 60 - 14, self.titleNavBar.frame.origin.y + self.titleNavBar.frame.size.height + 12 + 54, 14,14);
        [likeView genieInTransitionWithDuration:1.0 destinationRect:endRect destinationEdge:BCRectEdgeBottom completion:^{
//            likeView.transform = CGAffineTransformMakeRotation(360 *M_PI / 180.0);
            [self refreshGameCardViewUI];
            [likeView removeFromSuperview];
        }];
    }else{
        
    }
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
            for (WYGameInfo *gameInfo in self.gameCommendInfos) {
                if ([gameInfo.gameId isEqualToString:_selectedGameInfo.gameId]) {
                    gameInfo.favorCount ++;
                    gameInfo.isFavor = 1;
                    break;
                }
            }
            [WYProgressHUD AlertSuccess:@"游戏收藏成功" At:weakSelf.view];
            [weakSelf likeViewAnimation:YES];
        }else{
            for (WYGameInfo *gameInfo in self.gameCommendInfos) {
                if ([gameInfo.gameId isEqualToString:_selectedGameInfo.gameId]) {
                    gameInfo.favorCount --;
                    gameInfo.isFavor = 0;
                    break;
                }
            }
            [WYProgressHUD AlertSuccess:@"游戏取消收藏成功" At:weakSelf.view];
            [weakSelf refreshGameCardViewUI];
        }
        //蛋疼的刷新
//        [weakSelf refreshGameCardViewUI];
    }tag:tag];
    
}
-(void)getGameDownloadUrl{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getGameDownloadUrlWithGameId:_selectedGameInfo.gameId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"数据请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        NSString *iosDownloadUrl = [object stringObjectForKey:@"url_ios"];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:iosDownloadUrl]];
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
    [self getGameDownloadUrl];
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
        
        WYLog(@"-------------%f",CGRectGetHeight(swipeableView.bounds));
//        GameCommendCardView *view = [[[NSBundle mainBundle] loadNibNamed:@"GameCommendCardView" owner:nil options:nil] objectAtIndex:0];
        GameCommendCardView *view = [[GameCommendCardView alloc] init];
        view.delegate = self;
        view.frame = swipeableView.bounds;
        view.tag = self.gameIndex;
        
        if ([self isIphone4Device]) {
            CGRect frame = view.gameImageView.frame;
            frame.size.height = 159;
            view.gameImageView.frame = frame;
            
            frame = view.bottomLineImgView.frame;
            frame.origin.y = view.gameImageView.frame.origin.y + view.gameImageView.frame.size.height;
            view.bottomLineImgView.frame = frame;
            
            frame = view.gameDesLabel.frame;
            frame.origin.y = view.gameImageView.frame.origin.y + view.gameImageView.frame.size.height + 7;
            frame.size.height = 35;
            view.gameDesLabel.frame = frame;
        }
        
        
        WYGameInfo *gameInfo = self.gameCommendInfos[self.gameIndex];
        view.gameNameLabel.text = gameInfo.gameName;
        view.gameDesLabel.text = gameInfo.gameDes;
        view.gameVersionLabel.text = [NSString stringWithFormat:@"版本%@",gameInfo.version];
        view.likeLabel.text = [NSString stringWithFormat:@"%d",gameInfo.favorCount];
        [view.gameImageView sd_setImageWithURL:gameInfo.gameCoverUrl placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
        if (gameInfo.isFavor == 1) {
            view.likeIconImgView.image = [UIImage imageNamed:@"game_like_icon_selected"];
        }else{
            view.likeIconImgView.image = [UIImage imageNamed:@"game_like_icon_selected_not"];
        }
        
        
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

//#pragma mark - WYTabBarControllerDelegate
//-(void) tabBarController:(WYTabBarViewController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    if ([viewController isKindOfClass:[GameCommendViewController class]]) {

//        if (self.swipeableView) {
//            if (self.gameCommendInfos.count > 0) {
//                int random = arc4random()%2;
//                WYLog(@"random=%d",random);
//                if (random == 0) {
//                    [self.swipeableView swipeTopViewToLeft];
//                }else if (random == 1){
//                    [self.swipeableView swipeTopViewToRight];
//                }
//            }
//        }
//
//    }
//}

@end
