//
//  MatchApplyViewController.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchApplyViewController.h"
#import "MatchApplyCell.h"
#import "MatchMemberViewController.h"

@interface MatchApplyViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UIButton *commitButton;
- (IBAction)commitAction:(id)sender;

@end

@implementation MatchApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews {
    [self setTitle:@"创建战队"];
}

-(void)refreshUI{
    self.commitButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.commitButton.backgroundColor = SKIN_COLOR;
    self.commitButton.layer.cornerRadius = 4;
    self.commitButton.layer.masksToBounds = YES;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 5;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1 || section == 2) {
        return 24;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColorToRGB(0xf1f1f1);
    if(section == 0) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    }else{
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 24);
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 100, view.frame.size.height)];
        indexLabel.backgroundColor = [UIColor clearColor];
        indexLabel.textColor = SKIN_TEXT_COLOR2;
        indexLabel.font = SKIN_FONT_FROMNAME(12);
        if (section == 1) {
            indexLabel.text = @"战队资料";
        }else if(section == 2){
            indexLabel.text = @"个人资料";
        }
        [view addSubview:indexLabel];
    }
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchApplyCell";
    MatchApplyCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    cell.rightImageView.hidden = YES;
    
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"参赛网吧";
                [cell setbottomLineWithType:1];
                cell.rightImageView.hidden = NO;
                cell.textField.enabled = NO;
            }
        }
            break;
        case 1:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"战队名";
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 1){
                cell.titleLabel.text = @"大区";
                [cell setbottomLineWithType:1];
            }
        }
            break;
        case 2:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"姓名";
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 1) {
                cell.titleLabel.text = @"身份证";
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 2) {
                cell.titleLabel.text = @"手机";
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 3) {
                cell.titleLabel.text = @"QQ";
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 4) {
                cell.titleLabel.text = @"擅长位置";
                [cell setbottomLineWithType:1];
            }
        }
            break;
        default:
            break;
    }
    
    if (indexPath.row == 0) {
         cell.topline.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (IBAction)commitAction:(id)sender {
    MatchMemberViewController *mmVc = [[MatchMemberViewController alloc] init];
    [self.navigationController pushViewController:mmVc animated:YES];
}

@end
