//
//  QuickBookViewController.m
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "QuickBookViewController.h"
#import "QuickBookCell.h"

@interface QuickBookViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableView *bookTable;
@property (strong, nonatomic) IBOutlet UIButton *bookButton;
@property (strong, nonatomic) IBOutlet UITextField *specialField;

- (IBAction)bookAction:(id)sender;

@end

@implementation QuickBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bookTable.tableFooterView = self.footerView;
    
    [self.bookButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.bookButton.titleLabel.font = SKIN_FONT(18);
    self.bookButton.backgroundColor = SKIN_COLOR;
    self.bookButton.layer.cornerRadius = 4.0;
    self.bookButton.layer.masksToBounds = YES;
    
    self.specialField.textColor = SKIN_TEXT_COLOR2;
    self.specialField.font = SKIN_FONT(12);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"一键预订"];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuickBookCell";
    QuickBookCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    if (indexPath.row == 0) {
        cell.titleName.text = @"预订日期";
        cell.rightLabel.text = @"今天";
    } else if (indexPath.row == 1) {
        cell.titleName.text = @"上网时间";
        cell.rightLabel.text = @"11时00分";
    } else if (indexPath.row == 2) {
        cell.titleName.text = @"上网时长";
        cell.rightLabel.text = @"6小时";
    } else if (indexPath.row == 3) {
        cell.titleName.text = @"座位数量";
        cell.rightLabel.text = @"2个";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (IBAction)bookAction:(id)sender {
    
}

- (void)dealloc {
    
}

@end
