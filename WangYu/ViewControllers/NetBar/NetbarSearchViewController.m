//
//  NetbarSearchViewController.m
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarSearchViewController.h"
#import "WYSearchBar.h"
#import "NetbarTabCell.h"
#import "NetbarDetailViewController.h"

@interface NetbarSearchViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _searchBarIsEditing;
}
@property (nonatomic, strong) IBOutlet WYSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *netBarTable;
@property (nonatomic, strong) NSMutableArray *netBarInfos;

@end

@implementation NetbarSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _netBarInfos = [[NSMutableArray alloc] init];
    _searchBarIsEditing = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setRightButtonWithImageName:@"netbar_map_icon" selector:@selector(mapAction:)];
    
    self.searchBar.frame = CGRectMake(42, 20, SCREEN_WIDTH - 42-47, 44);
    [self.titleNavBar addSubview:self.searchBar];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - custom

-(void)doSearchAction{
    
}

-(void)mapAction:(id)sender{
    if (_searchBarIsEditing) {
        [self doSearchBarEndEditing];
    }
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (searchBar == self.searchBar) {
        _searchBarIsEditing = YES;
        [self setTilteLeftViewHide:YES];
        [self.titleNavBarRightBtn setImage:nil forState:0];
        [self.titleNavBarRightBtn setTitle:@"取消" forState:0];
        [UIView animateWithDuration:0.3 animations:^{
            self.searchBar.frame = CGRectMake(12, 20, SCREEN_WIDTH - 12-47, 44);
        } completion:^(BOOL finished) {
            
        }];
    }
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    if (searchBar == self.searchBar) {
//        _searchBarIsEditing = NO;
    }
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self doSearchAction];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchBar == self.searchBar) {
//        self.searchContent = [self.searchBar2.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if ([self.searchContent length] == 0) {
//            [self.searchTableView reloadData];
//            self.noResultTipLabel.hidden = YES;
//            self.searchTableView.hidden = YES;
//            self.searchMaskVew.alpha = 0.5;
//            [self refreshNoResultTipLabel];
//        }else{
//            self.searchMaskVew.alpha = 0;
//            self.searchTableView.hidden = NO;
//        }
    }
//    if (!searchText.length && !searchBar.isFirstResponder) {
//        [searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.1];
//    }
}

- (void)doSearchBarEndEditing{
    [self.searchBar resignFirstResponder];
    _searchBarIsEditing = NO;
    [self setTilteLeftViewHide:NO];
    [self.titleNavBarRightBtn setImage:[UIImage imageNamed:@"netbar_map_icon"] forState:0];
    [self.titleNavBarRightBtn setTitle:nil forState:0];
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBar.frame = CGRectMake(42, 20, SCREEN_WIDTH - 42-47, 44);
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.netBarTable == scrollView) {
        [self doSearchBarEndEditing];
    }else{
        [self.searchBar resignFirstResponder];
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
    [self.navigationController pushViewController:ndVc animated:YES];
    
}

@end
