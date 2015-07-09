//
//  OrderDetailViewController.m
//  WangYu
//
//  Created by XuLei on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "BookDetailCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "NetbarDetailViewController.h"

@interface OrderDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *orderTableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UILabel *netbarCollectLabel;
@property (strong, nonatomic) IBOutlet UILabel *serviceContactLabel;
@property (strong, nonatomic) IBOutlet UIButton *netbarCollectBtn;
@property (strong, nonatomic) IBOutlet UIButton *serviceContactBtn;
@property (strong, nonatomic) IBOutlet UILabel *netbarName;
@property (strong, nonatomic) IBOutlet UIImageView *netbarImageView;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *createLabel;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (strong, nonatomic) IBOutlet UILabel *sectionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *netbarCollectImage;


@property (strong, nonatomic) NSDictionary *moduleDict;

- (IBAction)collectNetbarAction:(id)sender;
- (IBAction)serviceContactAction:(id)sender;
- (IBAction)netbarAction:(id)sender;

@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUI];
    [self getOrderDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"支付订单详情"];
}

- (void)refreshUI {
    self.orderTableView.tableHeaderView = self.headerView;
    self.statusLabel.font = SKIN_FONT_FROMNAME(15);
    self.statusLabel.textColor = SKIN_TEXT_COLOR1;
    self.createLabel.font = SKIN_FONT_FROMNAME(12);
    self.createLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.netbarCollectLabel.font = SKIN_FONT_FROMNAME(14);
    self.netbarCollectLabel.textColor = SKIN_TEXT_COLOR2;
    self.serviceContactLabel.font = SKIN_FONT_FROMNAME(14);
    self.serviceContactLabel.textColor = SKIN_TEXT_COLOR2;
    
    [self.netbarCollectBtn.layer setMasksToBounds:YES];
    [self.netbarCollectBtn.layer setCornerRadius:4.0];
    [self.netbarCollectBtn.layer setBorderWidth:1];
    [self.netbarCollectBtn.layer setBorderColor:SKIN_TEXT_COLOR2.CGColor];
    
    [self.serviceContactBtn.layer setMasksToBounds:YES];
    [self.serviceContactBtn.layer setCornerRadius:4.0];
    [self.serviceContactBtn.layer setBorderWidth:1];
    [self.serviceContactBtn.layer setBorderColor:SKIN_TEXT_COLOR2.CGColor];
    
    self.colorLabel.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel.layer.cornerRadius = 1.0;
    self.colorLabel.layer.masksToBounds = YES;
    
    self.sectionLabel.textColor = SKIN_TEXT_COLOR1;
    self.sectionLabel.font = SKIN_FONT_FROMNAME(15);
    
    if (![self.orderInfo.netbarImageUrl isEqual:[NSNull null]]) {
        [self.netbarImageView sd_setImageWithURL:self.orderInfo.netbarImageUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }else{
        [self.netbarImageView sd_setImageWithURL:nil];
        [self.netbarImageView setImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }
    self.netbarImageView.clipsToBounds = YES;
    [self.netbarImageView.layer setMasksToBounds:YES];
    [self.netbarImageView.layer setCornerRadius:self.netbarImageView.frame.size.width/2];
    
    self.netbarName.text = self.orderInfo.netbarName;
    self.createLabel.text = [WYUIUtils dateYearToMinuteDiscriptionFromDate:self.orderInfo.createDate];
}

- (void)getOrderDataSource{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getOrderDetailwithUid:[WYEngine shareInstance].uid orderId:self.orderInfo.orderId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSDictionary *dic = [jsonRet objectForKey:@"object"];
        [weakSelf.orderInfo setOrderInfoByJsonDic:dic];
        weakSelf.moduleDict = [weakSelf tableDataModule];
        [weakSelf refreshOrderStatus];
        [weakSelf.orderTableView reloadData];
    }tag:tag];
}

- (void)refreshOrderStatus{
    if (self.orderInfo.oStatus == -1) {
        self.statusLabel.text = @"支付失败";
    }else if (self.orderInfo.oStatus == 0) {
        self.statusLabel.text = @"待支付";
    }else if (self.orderInfo.oStatus == 1) {
        self.statusLabel.text = @"支付成功";
    }
    if (self.orderInfo.netbarFav) {
        self.netbarCollectImage.image = [UIImage imageNamed:@"detail_netbar_collect_icon"];
    }else {
        self.netbarCollectImage.image = [UIImage imageNamed:@"detail_netbar_uncollect_icon"];
    }
}

- (NSDictionary *)tableDataModule{
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    NSDictionary *dict0 = @{@"titleLabel":@"上网金额：",@"contentLabel":[NSString stringWithFormat:@"%d元",_orderInfo.totalAmount]};
    NSDictionary *dict1 = @{@"titleLabel":@"网吧抵扣：",@"contentLabel":[NSString stringWithFormat:@"%d折",_orderInfo.rebate/10]};
    NSDictionary *dict2 = @{@"titleLabel":@"红包抵扣：",@"contentLabel":[NSString stringWithFormat:@"%@元",[NSNumber numberWithDouble:_orderInfo.redbagAmount]]};
    NSDictionary *dict3 = @{@"titleLabel":@"实际支付：",@"contentLabel":[NSString stringWithFormat:@"%@元",_orderInfo.amount]};
    
    [tmpMutDict setObject:dict0 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict1 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict2 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict3 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    return tmpMutDict;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 39;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    static NSString *CellIdentifier = @"BookDetailCell";
    BookDetailCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    NSDictionary *rowDicts = [self.moduleDict objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    cell.titleLabel.text = [rowDicts objectForKey:@"titleLabel"];
    cell.contentLabel.text = [rowDicts objectForKey:@"contentLabel"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (IBAction)collectNetbarAction:(id)sender {
    self.netbarCollectBtn.enabled = NO;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    if (weakSelf.orderInfo.netbarFav) {
        [[WYEngine shareInstance] unCollectionNetbarWithUid:[WYEngine shareInstance].uid netbarId:self.orderInfo.netbarId tag:tag];
    }else{
        [[WYEngine shareInstance] collectionNetbarWithUid:[WYEngine shareInstance].uid netbarId:self.orderInfo.netbarId tag:tag];
    }
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        //        [WYProgressHUD AlertLoadDone];
        self.netbarCollectBtn.enabled = YES;
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
            if (weakSelf.orderInfo.netbarFav) {
                [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromTop ForView:self.netbarCollectImage];
                [WYProgressHUD AlertSuccess:@"取消收藏成功" At:weakSelf.view];
            }else{
                [WYUIUtils transitionWithType:@"oglFlip" WithSubtype:kCATransitionFromBottom ForView:self.netbarCollectImage];
                [WYProgressHUD AlertSuccess:@"收藏成功" At:weakSelf.view];
            }
            weakSelf.orderInfo.netbarFav = !weakSelf.orderInfo.netbarFav;
            [weakSelf refreshOrderStatus];
        }
    }tag:tag];
}

- (IBAction)serviceContactAction:(id)sender {
    [WYCommonUtils usePhoneNumAction:@"0371-55336615" title:@"联系客服"];
}

- (IBAction)netbarAction:(id)sender {
    NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
    WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
    netbarInfo.nid = self.orderInfo.netbarId;
    ndVc.netbarInfo = netbarInfo;
    [self.navigationController pushViewController:ndVc animated:YES];
}

@end
