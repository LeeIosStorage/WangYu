//
//  ActivityDetailViewController.m
//  WangYu
//
//  Created by 许 磊 on 15/5/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchDetailViewController.h"
#import "MatchDetailCell.h"

@interface MatchDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableView *matchTableView;
@end

@implementation MatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.matchTableView.tableHeaderView = self.headerView;
    self.matchTableView.tableFooterView = self.footerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchDetailCell";
    MatchDetailCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0){
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_time_icon"];
                cell.titleLabel.text = @"2015-4-2～2015-4-3 13:00";
                cell.indicatorImage.hidden = YES;
                break;
            }else if (indexPath.row == 1){
                cell.avatarImageView.image = [UIImage imageNamed:@"netbar_detail_location_icon"];
                cell.titleLabel.text = @"比赛地点";
                cell.indicatorImage.hidden = NO;
                break;
            }else if (indexPath.row == 2){
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_schedule_icon"];
                cell.titleLabel.text = @"赛事赛程";
                cell.indicatorImage.hidden = NO;
                break;
            }else if (indexPath.row == 3){
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_award_icon"];
                cell.titleLabel.text = @"赛事奖品";
                cell.indicatorImage.hidden = NO;
                break;
            }
        }
        case 1:{
            if (indexPath.row == 0) {
                cell.avatarImageView.image = [UIImage imageNamed:@"match_detail_advance_icon"];
                cell.titleLabel.text = @"查看赛事进展";
                cell.indicatorImage.hidden = NO;
                break;
            }
        }
        default:
            break;
    }
    
    if (indexPath.row == 0) {
        // cell.topline.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

@end
