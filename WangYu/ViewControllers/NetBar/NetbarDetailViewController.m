//
//  NetbarDetailViewController.m
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarDetailViewController.h"
#import "NetbarDetailCell.h"
#import "QuickBookViewController.h"
#import "QuickPayViewController.h"
#import "WYNetbarInfo.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "WYShareActionSheet.h"
#import "WeiboSDK.h"
#import "WYPhotoGroup.h"
#import "WYPhotoItem.h"
#import "WYAlertView.h"
#import "WYMatchWarInfo.h"
#import "NetbarMapViewController.h"
#import "WYLinkerHandler.h"

@interface NetbarDetailViewController ()<UITableViewDataSource,UITableViewDelegate,WYShareActionSheetDelegate,WYPhotoGroupDelegate>
{
    WYShareActionSheet *_shareAction;
    BOOL _bHidden;
}
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;

@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (strong, nonatomic) IBOutlet UITableView *teamTable;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UIView *sectionView2;
@property (strong, nonatomic) IBOutlet UIButton *bookButton;
@property (strong, nonatomic) IBOutlet UIButton *payButton;

@property (strong, nonatomic) IBOutlet UILabel *netbarLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (strong, nonatomic) IBOutlet UILabel *sectionLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel1;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel2;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;
@property (strong, nonatomic) IBOutlet UILabel *descLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIButton *collectButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *publicButton;
@property (strong, nonatomic) IBOutlet UILabel *picLabel;

- (IBAction)bookAction:(id)sender;
- (IBAction)payAction:(id)sender;
- (IBAction)collectAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)locationAction:(id)sender;
- (IBAction)phoneAction:(id)sender;
- (IBAction)publicAction:(id)sender;
- (IBAction)detailAction:(id)sender;

@end

@implementation NetbarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUI];
    [self refreshHeaderView];
    [self getCacheNetbarInfo];
    [self getNetbarInfo];
}

- (void)refreshUI {
    self.teamTable.tableHeaderView = self.headerView;
    
    self.netbarImage.layer.cornerRadius = 4.0;
    self.netbarImage.layer.masksToBounds = YES;
    
    self.netbarLabel.textColor = SKIN_TEXT_COLOR1;
    self.netbarLabel.font = SKIN_FONT_FROMNAME(15);

    self.priceLabel1.textColor = SKIN_TEXT_COLOR2;
    self.priceLabel1.font = SKIN_FONT_FROMNAME(12);
    
    self.addressLabel.textColor = SKIN_TEXT_COLOR1;
    self.addressLabel.font = SKIN_FONT_FROMNAME(12);
    self.phoneLabel.textColor = SKIN_TEXT_COLOR1;
    self.phoneLabel.font = SKIN_FONT_FROMNAME(12);
    self.descLabel.textColor =SKIN_TEXT_COLOR1;
    self.descLabel.font = SKIN_FONT_FROMNAME(12);
    self.timeLabel.textColor = SKIN_TEXT_COLOR2;
    self.timeLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.colorLabel.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel.layer.cornerRadius = 1.0;
    self.colorLabel.layer.masksToBounds = YES;
    
    self.sectionLabel.textColor = SKIN_TEXT_COLOR1;
    self.sectionLabel.font = SKIN_FONT_FROMNAME(15);
    
    [self.bookButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.bookButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.bookButton.layer.cornerRadius = 4.0;
    self.bookButton.layer.masksToBounds = YES;
    
    [self.payButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.payButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.payButton.layer.cornerRadius = 4.0;
    self.payButton.layer.masksToBounds = YES;
    
    if (self.netbarInfo.isOrder) {
        self.bookButton.backgroundColor = SKIN_COLOR;
        self.payButton.backgroundColor = SKIN_COLOR;
        self.bookButton.enabled = YES;
        self.payButton.enabled = YES;
    }else {
        self.bookButton.backgroundColor = UIColorToRGB(0xe4e4e4);
        self.payButton.backgroundColor = UIColorToRGB(0xe4e4e4);
        self.bookButton.enabled = NO;
        self.payButton.enabled = NO;
    }
    
    self.publicButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.publicButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.publicButton.layer setMasksToBounds:YES];
    [self.publicButton.layer setCornerRadius:4.0];
    [self.publicButton.layer setBorderWidth:0.5];
    [self.publicButton.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
}

- (void)refreshHeaderView {
    if (![self.netbarInfo.smallImageUrl isEqual:[NSNull null]]) {
        [self.netbarImage sd_setImageWithURL:self.netbarInfo.smallImageUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }else{
        [self.netbarImage sd_setImageWithURL:nil];
        [self.netbarImage setImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }
    if (self.netbarInfo.isFaved) {
        [self.collectButton setBackgroundImage:[UIImage imageNamed:@"netbar_detail_collect_icon"] forState:UIControlStateNormal];
    }else {
        [self.collectButton setBackgroundImage:[UIImage imageNamed:@"netbar_detail_uncollect_icon"] forState:UIControlStateNormal];
    }
    self.phoneLabel.text = self.netbarInfo.telephone;
    self.addressLabel.text = self.netbarInfo.address;
    self.netbarLabel.text = self.netbarInfo.netbarName;
    
    self.priceLabel2.text = [NSString stringWithFormat:@"%d",self.netbarInfo.price];
    
    CGFloat priceLabelWidth = [WYCommonUtils widthWithText:self.priceLabel2.text font:self.priceLabel2.font lineBreakMode:self.priceLabel2.lineBreakMode];
    CGRect frame = self.priceLabel2.frame;
    frame.size.width = priceLabelWidth;
    self.priceLabel2.frame = frame;
    
    frame = self.timeLabel.frame;
    frame.origin.x = self.priceLabel2.frame.size.width + self.priceLabel2.frame.origin.x;
    self.timeLabel.frame = frame;
    self.timeLabel.text = [NSString stringWithFormat:@"/小时"];
    
    [self.imageScrollView removeFromSuperview];
    [self.headerView addSubview:self.imageScrollView];
    if(self.netbarInfo.picIds.count > 0){
        self.picLabel.hidden = YES;
        if(self.netbarInfo.picIds.count > 3){
            [self.imageScrollView setContentSize:CGSizeMake(12 + self.netbarInfo.picIds.count*(80+7), self.imageScrollView.frame.size.height)];
        }
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        
        WYPhotoGroup *photoGroup = [[WYPhotoGroup alloc] init];
        photoGroup.delegate = self;
        NSMutableArray *temp = [NSMutableArray array];
        [self.netbarInfo.picURLs enumerateObjectsUsingBlock:^(NSString *src, NSUInteger idx, BOOL *stop) {
            WYPhotoItem *item = [[WYPhotoItem alloc] init];
            item.thumbnail_pic = src;
            [temp addObject:item];
        }];
        
        photoGroup.photoItemArray = [temp copy];
        [self.imageScrollView addSubview:photoGroup];
    }else {
        self.picLabel.hidden = NO;
    }
}

-(void)getCacheNetbarInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getNetbarDetailWithUid:[WYEngine shareInstance].uid netbarId:self.netbarInfo.nid tag:tag];

    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            NSDictionary *dic = [jsonRet objectForKey:@"object"];
            [weakSelf.netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf refreshHeaderView];
        }
    }];
}

- (void)getNetbarInfo {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getNetbarDetailWithUid:[WYEngine shareInstance].uid netbarId:self.netbarInfo.nid tag:tag];
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
        [weakSelf.netbarInfo setNetbarInfoByJsonDic:dic];
        [weakSelf refreshHeaderView];
    }tag:tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"网吧详情"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.netbarInfo.matches.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.netbarInfo.matches.count == 0) {
        return 93;
    }
    return 39;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    if (self.netbarInfo.matches.count == 0) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 93);
        CGRect frame = self.sectionView2.frame;
        frame.size.width = SCREEN_WIDTH;
        self.sectionView2.frame = frame;
        [view addSubview:self.sectionView2];
    }else {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 39);
        CGRect frame = self.sectionView.frame;
        frame.size.width = SCREEN_WIDTH;
        self.sectionView.frame = frame;
        [view addSubview:self.sectionView];
    }
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NetbarDetailCell";
    NetbarDetailCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    WYMatchWarInfo *matchWarInfo = _netbarInfo.matches[indexPath.row];
    cell.matchWarInfo = matchWarInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (IBAction)bookAction:(id)sender {
    QuickBookViewController *qbVc = [[QuickBookViewController alloc] init];
    qbVc.netbarInfo = self.netbarInfo;
    [self.navigationController pushViewController:qbVc animated:YES];
}

- (IBAction)payAction:(id)sender {
    QuickPayViewController *qpVc = [[QuickPayViewController alloc] init];
    qpVc.netbarInfo = self.netbarInfo;
    [self.navigationController pushViewController:qpVc animated:YES];
}

- (IBAction)collectAction:(id)sender {
    
    self.collectButton.enabled = NO;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    if (weakSelf.netbarInfo.isFaved) {
        [[WYEngine shareInstance] unCollectionNetbarWithUid:[WYEngine shareInstance].uid netbarId:self.netbarInfo.nid tag:tag];
    }else{
        [[WYEngine shareInstance] collectionNetbarWithUid:[WYEngine shareInstance].uid netbarId:self.netbarInfo.nid tag:tag];
    }
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
        int code = [jsonRet intValueForKey:@"code"];
        if (code == 0) {
            if (weakSelf.netbarInfo.isFaved) {
                [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromTop ForView:self.collectButton];
                [WYProgressHUD AlertSuccess:@"取消收藏成功" At:weakSelf.view];
            }else{
                [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromBottom ForView:self.collectButton];
                [WYProgressHUD AlertSuccess:@"收藏成功" At:weakSelf.view];
            }
            weakSelf.netbarInfo.isFaved = !weakSelf.netbarInfo.isFaved;
            [weakSelf refreshHeaderView];
        }
    }tag:tag];
}

- (IBAction)shareAction:(id)sender {
    _shareAction = [[WYShareActionSheet alloc] init];
    _shareAction.netbarInfo = self.netbarInfo;
    _shareAction.owner = self;
    [_shareAction showShareAction];
}

- (IBAction)locationAction:(id)sender {
    NetbarMapViewController *nmVc = [[NetbarMapViewController alloc] init];
    nmVc.netbarInfo = _netbarInfo;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.netbarInfo.latitude doubleValue];
    coordinate.longitude = [self.netbarInfo.longitude doubleValue];
    [nmVc setShowLocation:coordinate.latitude longitute:coordinate.longitude];
    [self.navigationController pushViewController:nmVc animated:YES];
}

- (IBAction)phoneAction:(id)sender {
    if (![self.netbarInfo.telephone isEqualToString:@""]) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"联系网吧" message:self.netbarInfo.telephone cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"呼叫" okBlock:^{
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.netbarInfo.telephone]];
            [[UIApplication sharedApplication] openURL:URL];
        }];
        [alertView show];
    }
}

- (IBAction)publicAction:(id)sender {
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/activity/match/web/release?userId=%@&token=%@", [WYEngine shareInstance].baseUrl, [WYEngine shareInstance].uid,[WYEngine shareInstance].token] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)detailAction:(id)sender {
    id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/netbar/web/detail?id=%@", [WYEngine shareInstance].baseUrl, self.netbarInfo.nid] From:self.navigationController];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)dealloc{
    WYLog(@"NetbarDetailViewController dealloc!!!");
    _teamTable.delegate = nil;
    _teamTable.dataSource = nil;
}

- (void)controllerStatusBarHidden:(BOOL)bHidden{
    _bHidden = bHidden;
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL)prefersStatusBarHidden{
    return _bHidden;
}

@end
