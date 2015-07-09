//
//  SelectNetbarViewController.m
//  WangYu
//
//  Created by XuLei on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SelectNetbarViewController.h"
#import "NetbarTabCell.h"

@interface SelectNetbarViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation SelectNetbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews {
    [self setTitle:@"选择网吧"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.netbarInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 94;
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
    WYNetbarInfo *netbarInfo = self.netbarInfos[indexPath.row];
    cell.bSelected = YES;
    cell.netbarInfo = netbarInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    WYNetbarInfo *netbarInfo = self.netbarInfos[indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
    if (_sendNetbarCallBack) {
        _sendNetbarCallBack(netbarInfo);
    }
}

@end
