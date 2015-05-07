//
//  NetbarTabViewController.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarTabViewController.h"
#import "WYTabBarViewController.h"
#import "WYEngine.h"
#import "NetbarTabCell.h"
#import "SKSplashView.h"
#import "SKSplashIcon.h"

@interface NetbarTabViewController ()<UITableViewDataSource,UITableViewDelegate,SKSplashDelegate>

@property (strong, nonatomic) IBOutlet UILabel *orderLabel;
@property (strong, nonatomic) IBOutlet UILabel *packetLabel;
@property (strong, nonatomic) IBOutlet UILabel *bookLabel;
@property (strong, nonatomic) IBOutlet UILabel *bookDecLabel;
@property (strong, nonatomic) IBOutlet UILabel *hotLabel;

@property (strong, nonatomic) IBOutlet UIView *headView;

@property (strong, nonatomic) IBOutlet UITableView *netBarTable;

@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UILabel *guessLabel;

@property (strong, nonatomic) SKSplashView *splashView;


@end

@implementation NetbarTabViewController

-(void)dealloc{
    WYLog(@"NetbarTabViewController dealloc!!!");
    _splashView.delegate = nil;
    _splashView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.netBarTable.tableHeaderView = self.headView;
    self.orderLabel.font = SKIN_FONT(15);
    self.orderLabel.textColor = SKIN_TEXT_COLOR1;
    self.packetLabel.font = SKIN_FONT(15);
    self.packetLabel.textColor = SKIN_TEXT_COLOR1;
    self.bookLabel.font = SKIN_FONT(15);
    self.bookLabel.textColor = SKIN_TEXT_COLOR1;
    self.bookDecLabel.font = SKIN_FONT(12);
    self.bookDecLabel.textColor = SKIN_TEXT_COLOR2;
    self.guessLabel.font = SKIN_FONT(15);
    self.guessLabel.textColor = SKIN_TEXT_COLOR1;
    self.hotLabel.font = SKIN_FONT(12);
    self.hotLabel.layer.cornerRadius = 2;
    self.hotLabel.clipsToBounds = YES;
}

- (void)viewSplash
{
    //Setting the background
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//        imageView.image = [UIImage imageNamed:@"twitter background.png"];
//        [self.view addSubview:imageView];
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"twitterIcon"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = SKIN_COLOR;
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeNone];
    _splashView.delegate = self;
    _splashView.animationDuration = 2;
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        CGRect frame = self.tabController.tabBar.frame;
        frame.origin.y -= 50.0;
        self.tabController.tabBar.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    CGRect frame = self.tabController.tabBar.frame;
    frame.origin.y += 50.0;
    self.tabController.tabBar.frame = frame;
    [self viewSplash];
    self.titleNavImageView.hidden = NO;
    [self setRightButtonWithImageName:@"netbar_service_icon" selector:@selector(serviceAction)];
}

- (UINavigationController *)navigationController{
    if ([super navigationController]) {
        return [super navigationController];
    }
    return self.tabController.navigationController;
}

- (void)serviceAction {
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 39;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 39)];
    CGRect frame = self.sectionView.frame;
    frame.size.width = SCREEN_WIDTH;
    self.sectionView.frame = frame;
    [view addSubview:self.sectionView];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NetbarTabCell";
    NetbarTabCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}



@end
