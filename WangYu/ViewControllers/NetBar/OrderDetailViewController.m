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


@property (strong, nonatomic) NSDictionary *moduleDict;

- (IBAction)serviceContactAction:(id)sender;

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
    if (self.orderInfo.status == -1) {
        self.statusLabel.text = @"支付失败";
    }else if (self.orderInfo.status == 0) {
        self.statusLabel.text = @"待支付";
    }else if (self.orderInfo.status == 1) {
        self.statusLabel.text = @"支付成功";
    }
}

- (NSDictionary *)tableDataModule{
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    NSDictionary *dict0 = @{@"titleLabel":@"上网金额：",@"contentLabel":[NSString stringWithFormat:@"%d台",_orderInfo.seating]};
    NSDictionary *dict1 = @{@"titleLabel":@"网吧抵扣：",@"contentLabel":[NSString stringWithFormat:@"%@－%@",[WYUIUtils dateYearToMinuteDiscriptionFromDate:_orderInfo.beginTime],[WYUIUtils dateYearToMinuteDiscriptionFromDate:_orderInfo.endTime]]};
    NSDictionary *dict2 = @{@"titleLabel":@"红包抵扣：",@"contentLabel":[NSString stringWithFormat:@"%d小时",_orderInfo.hours]};
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

- (IBAction)serviceContactAction:(id)sender {
     [WYCommonUtils usePhoneNumAction:@"0371-55336615"];
}
@end
