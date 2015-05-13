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

@interface NetbarDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *maskView;

@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (strong, nonatomic) IBOutlet UITableView *teamTable;
@property (strong, nonatomic) IBOutlet UIView *sectionView;
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


- (IBAction)bookAction:(id)sender;
- (IBAction)payAction:(id)sender;

@end

@implementation NetbarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUI];
}

- (void)refreshUI {
    self.teamTable.tableHeaderView = self.headerView;
    
    self.netbarImage.layer.cornerRadius = 4.0;
    self.netbarImage.layer.masksToBounds = YES;
    
    self.netbarLabel.textColor = SKIN_TEXT_COLOR1;
    self.netbarLabel.font = SKIN_FONT(15);
    
    self.priceLabel1.textColor = SKIN_TEXT_COLOR2;
    self.priceLabel1.font = SKIN_FONT(12);
    self.priceLabel2.textColor = SKIN_TEXT_COLOR2;
    self.priceLabel2.font = SKIN_FONT(12);
    
    self.addressLabel.textColor = SKIN_TEXT_COLOR1;
    self.addressLabel.font = SKIN_FONT(12);
    self.phoneLabel.textColor = SKIN_TEXT_COLOR1;
    self.phoneLabel.font = SKIN_FONT(12);
    self.descLabel.textColor =SKIN_TEXT_COLOR1;
    self.descLabel.font = SKIN_FONT(12);
    
    self.colorLabel.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel.layer.cornerRadius = 1.0;
    self.colorLabel.layer.masksToBounds = YES;
    
    self.sectionLabel.textColor = SKIN_TEXT_COLOR1;
    self.sectionLabel.font = SKIN_FONT(15);
    
    [self.bookButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.bookButton.titleLabel.font = SKIN_FONT(14);
    self.bookButton.backgroundColor = SKIN_COLOR;
    self.bookButton.layer.cornerRadius = 4.0;
    self.bookButton.layer.masksToBounds = YES;
    
    [self.payButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.payButton.titleLabel.font = SKIN_FONT(14);
    self.payButton.backgroundColor = SKIN_COLOR;
    self.payButton.layer.cornerRadius = 4.0;
    self.payButton.layer.masksToBounds = YES;
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
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 39;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
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
    static NSString *CellIdentifier = @"NetbarDetailCell";
    NetbarDetailCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
//    cell.teamLabel.font = SKIN_FONT(12);
//    cell.teamLabel.textColor = SKIN_TEXT_COLOR1;
//    
//    cell.dateLabel.font = SKIN_FONT(12);
//    cell.dateLabel.textColor = SKIN_TEXT_COLOR2;
//    
//    cell.joinNumLabel.font = SKIN_FONT(12);
//    cell.joinNumLabel.textColor = SKIN_TEXT_COLOR2;
//    
//    cell.nameLabel.font = SKIN_FONT(12);
//    cell.nameLabel.textColor = SKIN_TEXT_COLOR1;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (IBAction)bookAction:(id)sender {
    QuickBookViewController *qbVc = [[QuickBookViewController alloc] init];
    [self.navigationController pushViewController:qbVc animated:YES];
}

- (IBAction)payAction:(id)sender {
    QuickPayViewController *qpVc = [[QuickPayViewController alloc] init];
    [self.navigationController pushViewController:qpVc animated:YES];
}

-(void)dealloc{
    WYLog(@"NetbarDetailViewController dealloc!!!");
    _teamTable.delegate = nil;
    _teamTable.dataSource = nil;
}

@end
