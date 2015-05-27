//
//  MatchPlaceViewController.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchPlaceViewController.h"
#import "MatchPlaceCell.h"

@interface MatchPlaceViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *placeTableView;

@end

@implementation MatchPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"比赛地点"];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 10;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 187;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] init];
////    if (self.netbarInfo.matcheArray.count == 0) {
////        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 93);
////        CGRect frame = self.sectionView2.frame;
////        frame.size.width = SCREEN_WIDTH;
////        self.sectionView2.frame = frame;
////        [view addSubview:self.sectionView2];
////    }else {
////        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 39);
////        CGRect frame = self.sectionView.frame;
////        frame.size.width = SCREEN_WIDTH;
////        self.sectionView.frame = frame;
////        [view addSubview:self.sectionView];
////    }
//    
//    return view;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchPlaceCell";
    MatchPlaceCell *cell;
    
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
