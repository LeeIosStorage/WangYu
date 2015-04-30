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

@interface GameCommendViewController () <ZLSwipeableViewDataSource,
ZLSwipeableViewDelegate>

@property (nonatomic, weak) IBOutlet ZLSwipeableView *swipeableView;
@property (nonatomic, strong) IBOutlet UIView *handleView;

@property (nonatomic, strong) NSArray *gameCommendInfos;
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
    self.gameCommendInfos = @[@{@"gameName":@"网娱大师",@"pic":@"http://g.hiphotos.baidu.com/baike/c0%3Dbaike116%2C5%2C5%2C116%2C38/sign=b7b1938d6e81800a7ae8815cd05c589f/bba1cd11728b4710dffb97cec1cec3fdfd0323df.jpg",@"des":@"网娱大师欢迎您快来下载吧 我擦我"},
                    @{@"gameName":@"全民突击",@"pic":@"http://www.fpwap.com/UploadFiles/news/yxgl/2015/01/19/07984252425d6a0664050fdead0fbeb0.jpg",@"des":@"不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我擦不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我"},
                    @{@"gameName":@"天天酷跑",@"pic":@"http://p3.image.hiapk.com/uploads/allimg/150130/930-150130134155.jpg",@"des":@"不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我擦不一样的捕鱼，不一样的欢乐 网娱大师欢迎您快来下载吧 我擦我"},
                    @{@"gameName":@"美女约",@"pic":@"http://f.hiphotos.baidu.com/image/pic/item/32fa828ba61ea8d3b8462a09950a304e251f5852.jpg",@"des":@"约起来吧 朋友趁还年轻还能约得动 尽情的释放你的激情 哈哈哈哈哈哈哈哈"}
                    ];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshUI{
    [self.view insertSubview:self.handleView belowSubview:self.swipeableView];
    
}

#pragma mark - IBAction
- (IBAction)downloadAction:(id)sender {
    WYLog(@"self.currentIndex = %d",(int)self.currentIndex);
}

- (IBAction)collectAction:(id)sender {
    WYLog(@"self.currentIndex = %d",(int)self.currentIndex);
}

#pragma mark - ZLSwipeableViewDelegate
- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    NSLog(@"did swipe in direction: %zd", direction);
    NSInteger viewTag = view.tag + 1;
    if (viewTag == self.gameCommendInfos.count) {
        viewTag = 0;
    }
    self.currentIndex = viewTag;
    
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
       didCancelSwipe:(UIView *)view {
    NSLog(@"did cancel swipe");
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
  didStartSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
    NSLog(@"did start swiping at location: x %f, y %f", location.x, location.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
          swipingView:(UIView *)view
           atLocation:(CGPoint)location
          translation:(CGPoint)translation {
    NSLog(@"swiping at location: x %f, y %f, translation: x %f, y %f",
          location.x, location.y, translation.x, translation.y);
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
    didEndSwipingView:(UIView *)view
           atLocation:(CGPoint)location {
    NSLog(@"did end swiping at location: x %f, y %f", location.x, location.y );
}

#pragma mark - ZLSwipeableViewDataSource

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    if (self.gameIndex < self.gameCommendInfos.count) {
        
        GameCommendCardView *view = [[[NSBundle mainBundle] loadNibNamed:@"GameCommendCardView" owner:nil options:nil] objectAtIndex:0];
        view.frame = swipeableView.bounds;
        view.tag = self.gameIndex;
        NSDictionary *gameDic = self.gameCommendInfos[self.gameIndex];
        
        view.gameNameLabel.text = [[gameDic objectForKey:@"gameName"] description];
        view.gameDesLabel.text = [[gameDic objectForKey:@"des"] description];
        [view.gameImageView sd_setImageWithURL:[NSURL URLWithString:[[gameDic objectForKey:@"pic"] description]] placeholderImage:[UIImage imageNamed:@""]];
        
        
        self.gameIndex++;
        return view;
    }
    self.gameIndex = 0;
    return nil;
}

@end
