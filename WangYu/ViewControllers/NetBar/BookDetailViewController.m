//
//  BookDetailViewController.m
//  WangYu
//
//  Created by XuLei on 15/6/25.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "BookDetailViewController.h"
#import "BookDetailCell.h"
#import "WYEngine.h"
#import "UIImageView+WebCache.h"
#import "WYProgressHUD.h"
#import "NetbarDetailViewController.h"

@interface BookDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *bookTableView;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIImageView *netbarImageView;
@property (strong, nonatomic) IBOutlet UILabel *netbarName;

@property (strong, nonatomic) IBOutlet UILabel *reserveLabel;
@property (strong, nonatomic) IBOutlet UIButton *netbarContactBtn;
@property (strong, nonatomic) IBOutlet UIButton *serviceContactBtn;
@property (strong, nonatomic) IBOutlet UILabel *netbarContactLabel;
@property (strong, nonatomic) IBOutlet UILabel *serviceContactLabel;

@property (strong, nonatomic) IBOutlet UIImageView *markerImage1;
@property (strong, nonatomic) IBOutlet UIImageView *markerImage2;
@property (strong, nonatomic) IBOutlet UIImageView *markerImage3;
@property (strong, nonatomic) IBOutlet UIImageView *markerImage4;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage1;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage2;
@property (strong, nonatomic) IBOutlet UIImageView *lineImage3;
@property (strong, nonatomic) IBOutlet UILabel *markerLabel1;
@property (strong, nonatomic) IBOutlet UILabel *markerLabel2;
@property (strong, nonatomic) IBOutlet UILabel *markerLabel3;
@property (strong, nonatomic) IBOutlet UILabel *markerLabel4;

@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (strong, nonatomic) IBOutlet UILabel *sectionLabel;

@property (strong, nonatomic) NSDictionary *moduleDict;

- (IBAction)netbarContactAction:(id)sender;
- (IBAction)serviceContactAction:(id)sender;
- (IBAction)netbarAction:(id)sender;

@end

@implementation BookDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.moduleDict = [self tableDataModule];
    [self refreshUI];
    [self getBookDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"预定订单详情"];
}

- (void)getBookDataSource{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getReserveDetailWithUid:[WYEngine shareInstance].uid reserveId:self.orderInfo.reserveId tag:tag];
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
        [weakSelf.bookTableView reloadData];
    }tag:tag];
}

- (void)refreshUI {
    self.bookTableView.tableHeaderView = self.headerView;
    self.reserveLabel.font = SKIN_FONT_FROMNAME(15);
    self.reserveLabel.textColor = SKIN_TEXT_COLOR1;
    
    self.netbarContactLabel.font = SKIN_FONT_FROMNAME(14);
    self.netbarContactLabel.textColor = SKIN_TEXT_COLOR2;
    self.serviceContactLabel.font = SKIN_FONT_FROMNAME(14);
    self.serviceContactLabel.textColor = SKIN_TEXT_COLOR2;
    
    [self.netbarContactBtn.layer setMasksToBounds:YES];
    [self.netbarContactBtn.layer setCornerRadius:4.0];
    [self.netbarContactBtn.layer setBorderWidth:1];
    [self.netbarContactBtn.layer setBorderColor:SKIN_TEXT_COLOR2.CGColor];
    
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
}

- (NSDictionary *)tableDataModule{
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    NSDictionary *dict0 = @{@"titleLabel":@"机位数量：",@"contentLabel":[NSString stringWithFormat:@"%d台",_orderInfo.seating]};
    NSDictionary *dict1 = @{@"titleLabel":@"时间：",@"contentLabel":[NSString stringWithFormat:@"%@－%@",[WYUIUtils dateYearToMinuteDiscriptionFromDate:_orderInfo.beginTime],[WYUIUtils dateYearToMinuteDiscriptionFromDate:_orderInfo.endTime]]};
    NSDictionary *dict2 = @{@"titleLabel":@"上网时长：",@"contentLabel":[NSString stringWithFormat:@"%d小时",_orderInfo.hours]};
    NSDictionary *dict3 = @{@"titleLabel":@"小费：",@"contentLabel":[NSString stringWithFormat:@"%@元",_orderInfo.amount?_orderInfo.amount:@"0"]};
    NSDictionary *dict4 = @{@"titleLabel":@"下单时间：",@"contentLabel":[WYUIUtils dateYearToMinuteDiscriptionFromDate:_orderInfo.createDate]};
   
    [tmpMutDict setObject:dict0 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict1 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict2 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict3 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict4 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    
    return tmpMutDict;
}

- (void)refreshOrderStatus{
    if (_orderInfo.rStatus < RESERVE_RECEIVE) {
        self.markerImage2.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
        self.markerImage3.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
        self.markerImage4.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
        
        self.lineImage1.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        self.lineImage2.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        self.lineImage3.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        
        self.markerLabel1.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel2.textColor = SKIN_TEXT_COLOR5;
        self.markerLabel3.textColor = SKIN_TEXT_COLOR5;
        self.markerLabel4.textColor = SKIN_TEXT_COLOR5;
    }else if (_orderInfo.rStatus >= RESERVE_RECEIVE && _orderInfo.rStatus < RESERVE_CANCEL) {
        self.markerImage2.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        self.markerImage3.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
        self.markerImage4.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
        
        self.lineImage1.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage2.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        self.lineImage3.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        
        self.markerLabel1.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel2.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel3.textColor = SKIN_TEXT_COLOR5;
        self.markerLabel4.textColor = SKIN_TEXT_COLOR5;
    }else if (_orderInfo.rStatus >= RESERVE_CANCEL && _orderInfo.rStatus < RESERVE_CONFIRM) {
        self.markerImage2.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        self.markerImage3.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
        self.markerImage4.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
       
        self.lineImage1.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage2.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage3.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        
        self.markerLabel1.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel2.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel3.textColor = SKIN_TEXT_COLOR5;
        self.markerLabel4.textColor = SKIN_TEXT_COLOR5;
    }else if (_orderInfo.rStatus >= RESERVE_CONFIRM && _orderInfo.rStatus < RESERVE_FINISH) {
        self.markerImage2.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        self.markerImage3.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        self.markerImage4.image = [UIImage imageNamed:@"detail_marker_hold_icon"];
       
        self.lineImage1.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage2.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage3.image = [UIImage imageNamed:@"detail_line_hold_icon"];
        
        self.markerLabel1.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel2.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel3.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel4.textColor = SKIN_TEXT_COLOR5;
    }else if (_orderInfo.rStatus == RESERVE_FINISH) {
        self.markerImage2.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        self.markerImage3.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        self.markerImage4.image = [UIImage imageNamed:@"detail_marker_finish_icon"];
        
        self.lineImage1.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage2.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        self.lineImage3.image = [UIImage imageNamed:@"detail_line_finish_icon"];
        
        self.markerLabel1.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel2.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel3.textColor = SKIN_TEXT_COLOR1;
        self.markerLabel4.textColor = SKIN_TEXT_COLOR1;
    }
    
    switch (_orderInfo.rStatus) {
        case RESERVE_WAIT:
            self.reserveLabel.text = @"订单待处理";
            break;
        case RESERVE_CANCELLED:
            self.reserveLabel.text = @"订单已取消(网吧未接单)";
            break;
        case RESERVE_RECEIVE:
            self.reserveLabel.text = @"网吧已接单";
            break;
        case RESERVE_REFUSE:
            self.reserveLabel.text = @"网吧已拒单";
            break;
        case RESERVE_FAILURE:
            self.reserveLabel.text = @"订单支付失败";
            break;
        case RESERVE_PAYUP:
            self.reserveLabel.text = @"订单已支付";
            break;
        case RESERVE_CONFIRM:
            self.reserveLabel.text = @"订单已确认";
            break;
        case RESERVE_CANCEL:
            self.reserveLabel.text = @"订单已取消(网吧接单后)";
            break;
        case RESERVE_FINISH:
            self.reserveLabel.text = @"网吧确认用户已到店";
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
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

- (IBAction)netbarContactAction:(id)sender {
    [WYCommonUtils usePhoneNumAction:_orderInfo.netbarTel title:@"联系网吧"];
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
