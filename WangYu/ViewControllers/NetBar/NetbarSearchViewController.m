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
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYNetbarInfo.h"
#import "WYLocationServiceUtil.h"
#import <MapKit/MapKit.h>

@interface NetbarSearchViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL _searchBarIsEditing;
}

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (nonatomic, strong) IBOutlet WYSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *netBarTable;
@property (nonatomic, strong) NSMutableArray *netBarInfos;
@property (assign, nonatomic) SInt64  netBarNextCursor;
@property (assign, nonatomic) BOOL netBarCanLoadMore;

@end

@implementation NetbarSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _netBarInfos = [[NSMutableArray alloc] init];
    _searchBarIsEditing = NO;
    [self getCacheNetbarInfos];
    [self refreshNetbarInfos];
    
    __weak NetbarSearchViewController *weakSelf = self;
    //获取用户位置
    [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
        
    } location:^(CLLocation *location) {
        weakSelf.currentLocation = [location coordinate];//当前经纬
        [weakSelf refreshNetbarInfos];
    }];
    
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
-(void)getCacheNetbarInfos{
    __weak NetbarSearchViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getNetbarAllListWithUid:[WYEngine shareInstance].uid page:1 pageSize:10 latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.netBarInfos = [[NSMutableArray alloc] init];
            
            NSArray *netbarDicArray = [jsonRet arrayObjectForKey:@"object"];
            for (NSDictionary *dic in netbarDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
                [netbarInfo setNetbarInfoByJsonDic:dic];
                [weakSelf.netBarInfos addObject:netbarInfo];
            }
            [weakSelf.netBarTable reloadData];
        }
    }];
}
-(void)refreshNetbarInfos{
    
    _netBarNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getNetbarAllListWithUid:[WYEngine shareInstance].uid page:(int)_netBarNextCursor pageSize:10 latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [WYProgressHUD AlertLoadDone];
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.netBarInfos = [[NSMutableArray alloc] init];
        
        NSArray *netbarDicArray = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in netbarDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf.netBarInfos addObject:netbarInfo];
        }
        
        [weakSelf.netBarTable reloadData];
    }tag:tag];
}

-(void)doSearchAction{
    
}

-(void)mapAction:(id)sender{
    if (_searchBarIsEditing) {
        [self doSearchBarEndEditing];
    }
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
    return self.netBarInfos.count;
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
    WYNetbarInfo *netbarInfo = _netBarInfos[indexPath.row];
    cell.netbarInfo = netbarInfo;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    WYNetbarInfo *netbarInfo = _netBarInfos[indexPath.row];
    NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
    ndVc.netbarInfo = netbarInfo;
    [self.navigationController pushViewController:ndVc animated:YES];
    
}

@end
