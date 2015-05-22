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
#import "WYNetBarManager.h"
#import "NetbarMapViewController.h"

@interface NetbarSearchViewController ()<UITableViewDataSource,UITableViewDelegate,NetbarTabCellDelegate>
{
    BOOL _searchBarIsEditing;
}

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (nonatomic, strong) IBOutlet WYSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *netBarTable;
@property (nonatomic, strong) NSMutableArray *netBarInfos;
@property (assign, nonatomic) SInt64  netBarNextCursor;
@property (assign, nonatomic) BOOL netBarCanLoadMore;

@property (strong, nonatomic) IBOutlet UIView *historyContainerView;
@property (strong, nonatomic) IBOutlet UIView *historyFooterView;
@property (strong, nonatomic) IBOutlet UIButton *clearHistoryButton;
@property (strong, nonatomic) IBOutlet UITableView *historyTable;

@property (nonatomic, assign) BOOL havHistorySearchRecord;
@property (nonatomic, strong) NSMutableArray *groupDataSource;
@property (nonatomic, strong) NSMutableArray *historyInfos;
@property (nonatomic, strong) NSMutableArray *nearbyNetBarInfos;

//搜索
@property (nonatomic, strong) NSString *searchContent;
@property (strong, nonatomic) IBOutlet UIView *searchContainerView;
@property (strong, nonatomic) IBOutlet UITableView *searchTableView;
@property (nonatomic, strong) NSMutableArray *searchNetBarInfos;

-(IBAction)removeSearchRecordAction:(id)sender;
@end

@implementation NetbarSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _netBarInfos = [[NSMutableArray alloc] init];
    _groupDataSource = [[NSMutableArray alloc] init];
    _historyInfos = [[NSMutableArray alloc] init];
    _nearbyNetBarInfos = [[NSMutableArray alloc] init];
    
    self.currentLocation = [WYLocationServiceUtil getLastRecordLocation];
    
    [self initControlUI];
    [self refreshHistorySearchData:NO];
    
    _searchBarIsEditing = NO;
    [self getCacheNetbarInfos];
    [self refreshNetbarInfos];
    
    __weak NetbarSearchViewController *weakSelf = self;
    //获取用户位置
    [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
        
    } location:^(CLLocation *location) {
        weakSelf.currentLocation = [location coordinate];//当前经纬
        [weakSelf refreshNetbarInfos];
        [weakSelf getNearbyNetBars];
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


-(void)initControlUI{
    [self.clearHistoryButton.layer setMasksToBounds:YES];
    [self.clearHistoryButton.layer setCornerRadius:4.0];
    [self.clearHistoryButton.layer setBorderWidth:0.5]; //边框宽度
    [self.clearHistoryButton.layer setBorderColor:SKIN_TEXT_COLOR1.CGColor];//边框颜色
    self.clearHistoryButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
}

#pragma mark - custom
-(void)refreshHistorySearchData:(BOOL)lose{
    //搜索历史记录
    [_historyInfos removeAllObjects];
    if (!lose) {
        NSArray *searchRecordArray = [[WYNetBarManager shareInstance] getHistorySearchRecord];
        for (NSString *info in searchRecordArray) {
            [_historyInfos addObject:info];
        }
    }
    
    //历史搜索and附近网吧
    _groupDataSource = [[NSMutableArray alloc] init];
    if (_historyInfos.count > 0) {
        [_groupDataSource addObject:_historyInfos];
        _havHistorySearchRecord = YES;
    }else{
        _havHistorySearchRecord = NO;
    }
    if (_nearbyNetBarInfos.count > 0) {
        [_groupDataSource addObject:_nearbyNetBarInfos];
    }
    [self.historyTable reloadData];
}

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
            
            NSArray *netbarDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
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
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.netBarInfos = [[NSMutableArray alloc] init];
        
        NSArray *netbarDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
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

-(void)getNearbyNetBars{
    
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] searchLocalNetbarWithUid:[WYEngine shareInstance].uid latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.nearbyNetBarInfos = [[NSMutableArray alloc] init];
        NSArray *netbarDicArray = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in netbarDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf.nearbyNetBarInfos addObject:netbarInfo];
        }
        
        [weakSelf refreshHistorySearchData:NO];
        
//        [weakSelf.historyTable reloadData];
        
    }tag:tag];
}

-(void)doSearchAction{
    
    self.searchContent = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[WYNetBarManager shareInstance] addSaveHistorySearchRecord:self.searchContent];
    
    [WYProgressHUD AlertLoading:@"搜索中,请稍等."];
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] searchNetbarWithUid:[WYEngine shareInstance].uid netbarName:self.searchContent latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        weakSelf.searchNetBarInfos = [[NSMutableArray alloc] init];
        NSArray *netbarDicArray = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in netbarDicArray) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
            [netbarInfo setNetbarInfoByJsonDic:dic];
            [weakSelf.searchNetBarInfos addObject:netbarInfo];
        }
        
        [weakSelf refreshSearchTableView];
        
        [weakSelf.searchTableView reloadData];
        
    }tag:tag];
    
}

-(void)refreshSearchTableView{
    if (self.searchNetBarInfos.count == 0) {
        [WYProgressHUD AlertSuccess:@"搜索结果为空" At:self.view];
    }else{
        [WYProgressHUD AlertSuccess:@"搜索成功" At:self.view];
    }
    
    self.historyContainerView.hidden = YES;
    
    if (!self.searchContainerView.superview) {
        CGRect frame = self.searchContainerView.frame;
        frame.origin.y = self.titleNavBar.frame.size.height;
        frame.size.width = self.view.bounds.size.width;
        frame.size.height = self.view.bounds.size.height - self.titleNavBar.frame.size.height;
        self.searchContainerView.frame = frame;
        [self.view addSubview:self.searchContainerView];
    }else{
        self.searchContainerView.hidden = NO;
    }
    
    [self.searchTableView reloadData];
}

-(void)mapAction:(id)sender{
    if (_searchBarIsEditing) {
        [self doSearchBarEndEditing];
        return;
    }
    NetbarMapViewController *mapVc = [[NetbarMapViewController alloc] init];
    CLLocationCoordinate2D location;
    location.latitude = 30.19185;
    location.longitude = 120.14598;
    mapVc.location = location;
    mapVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:mapVc animated:YES completion:^{
        
    }];
}
-(IBAction)removeSearchRecordAction:(id)sender{
    [[WYNetBarManager shareInstance] removeHistorySearchRecord];
    [self refreshHistorySearchData:YES];
}

- (void)doSearchBarEndEditing{
    [self.searchBar resignFirstResponder];
    self.searchBar.text = nil;
    _searchBarIsEditing = NO;
    [self setTilteLeftViewHide:NO];
    [self.titleNavBarRightBtn setImage:[UIImage imageNamed:@"netbar_map_icon"] forState:0];
    [self.titleNavBarRightBtn setTitle:nil forState:0];
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBar.frame = CGRectMake(42, 20, SCREEN_WIDTH - 42-47, 44);
    } completion:^(BOOL finished) {
        
    }];
    self.netBarTable.hidden = NO;
    if (self.historyContainerView.superview) {
        [self.historyContainerView removeFromSuperview];
    }
    if (self.searchContainerView.superview) {
        [self.searchContainerView removeFromSuperview];
    }
}

-(void)doSearchBarBeginEditing{
    _searchBarIsEditing = YES;
    [self setTilteLeftViewHide:YES];
    [self.titleNavBarRightBtn setImage:nil forState:0];
    [self.titleNavBarRightBtn setTitle:@"取消" forState:0];
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBar.frame = CGRectMake(12, 20, SCREEN_WIDTH - 12-47, 44);
    } completion:^(BOOL finished) {
        
    }];
    
    self.netBarTable.hidden = YES;
    CGRect frame = self.historyContainerView.frame;
    frame.origin.y = self.titleNavBar.frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - self.titleNavBar.frame.size.height;
    self.historyContainerView.frame = frame;
    [self.view addSubview:self.historyContainerView];
    [self.historyTable reloadData];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (searchBar == self.searchBar) {
        [self doSearchBarBeginEditing];
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
        self.searchContent = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([self.searchContent length] == 0) {
            [self.searchTableView reloadData];
            self.searchContainerView.hidden = YES;
            self.historyContainerView.hidden = NO;
            [self refreshHistorySearchData:NO];
        }else{
            self.searchTableView.hidden = NO;
            self.historyContainerView.hidden = YES;
        }
    }
//    if (!searchText.length && !searchBar.isFirstResponder) {
//        [searchBar performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.1];
//    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.netBarTable == scrollView) {
        [self doSearchBarEndEditing];
    }else{
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.historyTable) {
        return _groupDataSource.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.historyTable) {
        return 39;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == self.historyTable) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 39)];
        view.backgroundColor = [UIColor whiteColor];
        
        
        UIImageView *topLineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_n_set_line"]];
        topLineImgView.frame = CGRectMake(0, 0, view.frame.size.width, 1);
        [view addSubview:topLineImgView];
        
        UIImageView *botLineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_n_set_line"]];
        botLineImgView.frame = CGRectMake(0, view.frame.size.height, view.frame.size.width, 1);
        [view addSubview:botLineImgView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, view.frame.size.width-12*2, 44)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.numberOfLines = 1;
        nameLabel.textAlignment = NSTextAlignmentLeft;
        nameLabel.textColor = SKIN_TEXT_COLOR2;
        nameLabel.font = SKIN_FONT_FROMNAME(12);
        if (section == 0) {
            if (_havHistorySearchRecord) {
                nameLabel.text = @"搜索历史";
            }else{
                nameLabel.text = @"附近网吧";
            }
        }else if (section == 1){
            nameLabel.text = @"附近网吧";
        }
        [view addSubview:nameLabel];
        
        return view;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (tableView == self.historyTable) {
        if (section == 0 && _havHistorySearchRecord) {
            return self.historyFooterView.frame.size.height;
        }
        return 0;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView == self.historyTable) {
        if (section == 0 && _havHistorySearchRecord) {
            self.historyFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 49);
            return self.historyFooterView;
        }
        return nil;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.historyTable) {
        NSArray *rows = [_groupDataSource objectAtIndex:section];
        return rows.count;
    }else if (tableView == self.searchTableView){
        return self.searchNetBarInfos.count;
    }
    return self.netBarInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyTable) {
        return 44;
    }
    return 94;
}

static int historyLabel_Tag = 201;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyTable) {
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIImageView *botLineImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_n_set_line"]];
            botLineImgView.frame = CGRectMake(0, 43, self.view.bounds.size.width, 1);
            [cell addSubview:botLineImgView];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width-12*2, 44)];
            nameLabel.tag = historyLabel_Tag;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.numberOfLines = 1;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.textColor = SKIN_TEXT_COLOR1;
            nameLabel.font = SKIN_FONT_FROMNAME(14);
            [cell addSubview:nameLabel];
        }
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:historyLabel_Tag];
        NSArray *rowArray = [_groupDataSource objectAtIndex:indexPath.section];
        id rowData = [rowArray objectAtIndex:indexPath.row];
        if ([rowData isKindOfClass:[NSString class]]) {
            nameLabel.text = [rowData description];
        }else if ([rowData isKindOfClass:[WYNetbarInfo class]]){
            WYNetbarInfo *netbarInfo = rowData;
            nameLabel.text = netbarInfo.netbarName;
        }
        
        return cell;
        
    }else if (tableView == self.netBarTable){
        static NSString *CellIdentifier = @"NetbarTabCell";
        NetbarTabCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        cell.delegate = self;
        WYNetbarInfo *netbarInfo = _netBarInfos[indexPath.row];
        cell.netbarInfo = netbarInfo;
        cell.isSearchCell = NO;
        return cell;
    }else if (tableView == self.searchTableView){
        static NSString *CellIdentifier = @"NetbarTabCell";
        NetbarTabCell *cell;
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
        }
        cell.delegate = self;
        cell.isSearchCell = YES;
        WYNetbarInfo *netbarInfo = _searchNetBarInfos[indexPath.row];
        cell.netbarInfo = netbarInfo;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    if (tableView == self.historyTable) {
        NSArray *rowArray = [_groupDataSource objectAtIndex:indexPath.section];
        id rowData = [rowArray objectAtIndex:indexPath.row];
        if ([rowData isKindOfClass:[NSString class]]) {
            self.searchBar.text = [rowData description];
            [self.searchBar becomeFirstResponder];
            [self doSearchAction];
            
        }else if ([rowData isKindOfClass:[WYNetbarInfo class]]){
            WYNetbarInfo *netbarInfo = rowData;
            NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
            ndVc.netbarInfo = netbarInfo;
            [self.navigationController pushViewController:ndVc animated:YES];
        }
    }else if (tableView == self.netBarTable){
        
        WYNetbarInfo *netbarInfo = _netBarInfos[indexPath.row];
        NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
        ndVc.netbarInfo = netbarInfo;
        [self.navigationController pushViewController:ndVc animated:YES];
    }else if (tableView == self.searchTableView){
        
        WYNetbarInfo *netbarInfo = _searchNetBarInfos[indexPath.row];
        NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
        ndVc.netbarInfo = netbarInfo;
        [self.navigationController pushViewController:ndVc animated:YES];
    }
}

#pragma mark - NetbarTabCellDelegate
- (void)netbarTabCellMapClickWithCell:(id)cell {
    
    NetbarTabCell *netbarCell = (NetbarTabCell *)cell;
    UITableView *tableView;
    if (netbarCell.isSearchCell) {
        tableView = self.searchTableView;
    }else {
        tableView = self.netBarTable;
    }
    
    NSIndexPath* indexPath = [tableView indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    WYNetbarInfo* netbarInfo;
    if (tableView == self.netBarTable){
        netbarInfo = _netBarInfos[indexPath.row];
    }else if (tableView == self.searchTableView){
        netbarInfo = _searchNetBarInfos[indexPath.row];
    }
    
    if (!netbarInfo || netbarInfo.nid.length == 0) {
        return;
    }
    
    NetbarMapViewController *nmVc = [[NetbarMapViewController alloc] init];
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [netbarInfo.latitude doubleValue];
    coordinate.longitude = [netbarInfo.longitude doubleValue];
    [nmVc setShowLocation:coordinate.latitude longitute:coordinate.longitude];
    nmVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:nmVc animated:YES completion:^{
        
    }];
}

@end
