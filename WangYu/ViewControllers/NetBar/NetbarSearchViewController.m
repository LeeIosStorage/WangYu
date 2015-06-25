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
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYNavigationController.h"
#import "WYAlertView.h"

#define price_type @"price"
#define price_name @"price_name"

@interface NetbarSearchViewController ()<UITableViewDataSource,UITableViewDelegate,NetbarTabCellDelegate>
{
    BOOL _searchBarIsEditing;
    
    int _filterType;
    NSString *_filterAreaName;
    NSString *_filterAreaCode;
    NSString *_filterPriceName;
    
}

@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (nonatomic, strong) IBOutlet WYSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *netBarTable;
@property (nonatomic, strong) NSMutableArray *netBarInfos;
@property (assign, nonatomic) SInt64  netBarNextCursor;
@property (assign, nonatomic) BOOL netBarCanLoadMore;

@property (nonatomic, strong) NSString *filterPriceType;
@property (nonatomic, strong) NSMutableArray *filterAreaArray;
@property (nonatomic, strong) NSMutableArray *filterPriceArray;
@property (nonatomic, strong) IBOutlet UIView *filterTableContainerView;
@property (nonatomic, strong) IBOutlet UITableView *filterTableView;
@property (nonatomic, strong) UIButton *bgMarkButtonView;

@property (nonatomic, strong) IBOutlet UIView *filterContainerView;
@property (nonatomic, strong) IBOutlet UIImageView *filterBottomImgView;
@property (nonatomic, strong) IBOutlet UIImageView *filterMiddleImgView;
@property (nonatomic, strong) IBOutlet UILabel *filterAreaLabel;
@property (nonatomic, strong) IBOutlet UIImageView *filterAreaIconImgView;
@property (nonatomic, strong) IBOutlet UILabel *filterPriceLabel;
@property (nonatomic, strong) IBOutlet UIImageView *filterPriceIconImgView;
@property (nonatomic, strong) IBOutlet UIButton *filterAreaButton;
@property (nonatomic, strong) IBOutlet UIButton *filterPriceButton;

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

@property (strong, nonatomic) IBOutlet UIView *searchBlankTipView;
@property (strong, nonatomic) IBOutlet UILabel *searchBlankTipLabel;

-(IBAction)removeSearchRecordAction:(id)sender;
-(IBAction)filterAreaAction:(id)sender;
-(IBAction)filterPriceAction:(id)sender;

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
    
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.netBarTable];
    self.pullRefreshView.delegate = self;
    [self.netBarTable addSubview:self.pullRefreshView];
    
    
    self.filterContainerView.hidden = YES;
    if (_showFilter) {
        _filterAreaArray = [[NSMutableArray alloc] init];
        _filterPriceArray = [[NSMutableArray alloc] init];
        _filterType = 0;
        _filterAreaName = @"区域";
        _filterAreaCode = _areaCode;
        _filterPriceName = @"排序";
        _filterPriceType = @"";
        self.filterContainerView.hidden = NO;
        CGRect frame = self.netBarTable.frame;
        frame.origin.y = self.filterContainerView.frame.origin.y + self.filterContainerView.frame.size.height;
        frame.size.height = self.view.bounds.size.height - frame.origin.y;
        self.netBarTable.frame = frame;
        
        [self refreshFilterAreaData];
        [self refreshFilterPriceData];
    }
    
    
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
    
    [self.netBarTable addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.netBarCanLoadMore) {
            [weakSelf.netBarTable.infiniteScrollingView stopAnimating];
            weakSelf.netBarTable.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getNetbarAllListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.netBarNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude areaCode:weakSelf.areaCode type:[weakSelf.filterPriceType intValue] tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.netBarTable.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *netbarDicArray = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in netbarDicArray) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
                [netbarInfo setNetbarInfoByJsonDic:dic];
                [weakSelf.netBarInfos addObject:netbarInfo];
            }
            
            weakSelf.netBarCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.netBarCanLoadMore) {
                weakSelf.netBarTable.showsInfiniteScrolling = NO;
            }else{
                weakSelf.netBarTable.showsInfiniteScrolling = YES;
                weakSelf.netBarNextCursor ++;
            }
            
            [weakSelf.netBarTable reloadData];
            
        } tag:tag];
    }];
    weakSelf.netBarTable.showsInfiniteScrolling = NO;
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
    
    self.searchContainerView.backgroundColor = self.view.backgroundColor;
    self.searchTableView.backgroundColor = self.view.backgroundColor;
    
    self.filterTableContainerView.backgroundColor = self.view.backgroundColor;
    self.filterBottomImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
    self.filterMiddleImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
    CGRect frame = self.filterBottomImgView.frame;
    frame.size.height = 0.5;
    self.filterBottomImgView.frame = frame;
    frame = self.filterMiddleImgView.frame;
    frame.size.width = 0.5;
    self.filterMiddleImgView.frame = frame;
    
    self.filterAreaLabel.textColor = SKIN_TEXT_COLOR1;
    self.filterAreaLabel.font = SKIN_FONT_FROMNAME(14);
    self.filterPriceLabel.textColor = SKIN_TEXT_COLOR1;
    self.filterPriceLabel.font = SKIN_FONT_FROMNAME(14);
    [self refreshFilterViewShowUI];
}

- (void)refreshFilterViewShowUI{
    self.filterAreaLabel.text = _filterAreaName;
    self.filterPriceLabel.text = _filterPriceName;
    CGFloat textWidth = [WYCommonUtils widthWithText:_filterAreaName font:self.filterAreaLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = self.filterAreaLabel.frame;
    frame.origin.x = SCREEN_WIDTH/4-textWidth/2-7;
    frame.size.width = textWidth;
    self.filterAreaLabel.frame = frame;
    frame = self.filterAreaIconImgView.frame;
    frame.origin.x = self.filterAreaLabel.frame.origin.x + self.filterAreaLabel.frame.size.width + 5;
    self.filterAreaIconImgView.frame = frame;
    
    textWidth = [WYCommonUtils widthWithText:_filterPriceName font:self.filterPriceLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.filterPriceLabel.frame;
    frame.origin.x = SCREEN_WIDTH/4-textWidth/2-7;
    frame.size.width = textWidth;
    self.filterPriceLabel.frame = frame;
    frame = self.filterPriceIconImgView.frame;
    frame.origin.x = self.filterPriceLabel.frame.origin.x + self.filterPriceLabel.frame.size.width + 5;
    self.filterPriceIconImgView.frame = frame;
    
    
}

- (void)refreshSearchBlankShowUI:(int)type{
    if (type == 1) {
        [self.searchBlankTipView removeFromSuperview];
        return;
    }
    self.searchBlankTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.searchBlankTipLabel.textColor = SKIN_TEXT_COLOR2;
    if (self.searchNetBarInfos && self.searchNetBarInfos.count == 0) {
        CGRect frame = self.searchBlankTipView.frame;
        frame.origin.y = 0;
        frame.size.width = SCREEN_WIDTH;
        self.searchBlankTipView.frame = frame;
        [self.searchTableView addSubview:self.searchBlankTipView];
        
    }else{
        if (self.searchBlankTipView.superview) {
            [self.searchBlankTipView removeFromSuperview];
        }
    }
}

- (void)showFilterViewWith:(BOOL)showOpen{
    
    if (showOpen) {
        
        if (_bgMarkButtonView.superview) {
            [_bgMarkButtonView removeFromSuperview];
        }
        
        CGRect frame = self.filterTableContainerView.frame;
        frame.origin.y = self.filterContainerView.frame.origin.y + self.filterContainerView.frame.size.height;
        frame.size.width = self.view.bounds.size.width;
        frame.size.height = 0;
        self.filterTableContainerView.frame = frame;
        [self.view addSubview:self.filterTableContainerView];
        [self.view insertSubview:self.filterTableContainerView belowSubview:self.filterContainerView];
        
        CGFloat filterContainerViewHeight = 250;
        if (self.filterAreaButton.selected) {
            filterContainerViewHeight = self.filterAreaArray.count*36+1;
        }else if (self.filterPriceButton.selected){
            filterContainerViewHeight = self.filterPriceArray.count*36+1;
        }
        if (filterContainerViewHeight>250) {
            filterContainerViewHeight = 250;
        }
        if (filterContainerViewHeight < 144) {
            filterContainerViewHeight = 144;
        }
        
        [self.filterTableView reloadData];
        
        _bgMarkButtonView = [UIButton buttonWithType:UIButtonTypeCustom];
        _bgMarkButtonView.frame = self.view.bounds;
        [_bgMarkButtonView addTarget:self action:@selector(hiddenFilterViewAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bgMarkButtonView];
        [self.view insertSubview:_bgMarkButtonView belowSubview:self.filterTableContainerView];
        _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        if (_filterType == 0) {
            _filterPriceIconImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        }else if (_filterType == 1){
            _filterAreaIconImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
        }
        [UIView animateWithDuration:0.2 animations:^{
            CGRect frame = self.filterTableContainerView.frame;
            frame.size.height = filterContainerViewHeight;
            self.filterTableContainerView.frame = frame;
            _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
            if (_filterType == 0) {
                _filterAreaIconImgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            }else if (_filterType == 1){
                _filterPriceIconImgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
            }
        } completion:^(BOOL finished) {
            _filterAreaIconImgView.highlighted = _filterAreaButton.selected;
            _filterPriceIconImgView.highlighted = _filterPriceButton.selected;
        }];
    }else{
        self.filterAreaButton.selected = NO;
        self.filterPriceButton.selected = NO;
        if (self.filterTableContainerView.superview) {
            [UIView animateWithDuration:0.2 animations:^{
                CGRect frame = self.filterTableContainerView.frame;
                frame.size.height = 0;
                self.filterTableContainerView.frame = frame;
                _bgMarkButtonView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                if (_filterType == 0) {
                    _filterAreaIconImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
                }else if (_filterType == 1){
                    _filterPriceIconImgView.transform = CGAffineTransformMakeRotation(0 *M_PI / 180.0);
                }
            } completion:^(BOOL finished) {
                _filterAreaIconImgView.highlighted = _filterAreaButton.selected;
                _filterPriceIconImgView.highlighted = _filterPriceButton.selected;
                [self.filterTableContainerView removeFromSuperview];
                [_bgMarkButtonView removeFromSuperview];
            }];
        }
    }
}

-(void)hiddenFilterViewAction{
    [self showFilterViewWith:NO];
}

#pragma mark - request
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

-(void)refreshFilterPriceData{
    if (_filterPriceArray == nil) {
        _filterPriceArray = [[NSMutableArray alloc] init];
    }
    [_filterPriceArray addObject:@{price_name:@"按距离",price_type:@"1"}];
    [_filterPriceArray addObject:@{price_name:@"按推荐",price_type:@"2"}];
    [_filterPriceArray addObject:@{price_name:@"按热度",price_type:@"3"}];
    
}

-(void)refreshFilterAreaData{
    if (_areaCode.length == 0) {
        return;
    }
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getValidChildrenListWithCode:_areaCode tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            return;
        }
        weakSelf.filterAreaArray = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in object) {
            [weakSelf.filterAreaArray addObject:dic];
        }
        
    }tag:tag];
}

-(void)getCacheNetbarInfos{
    
    NSArray *allCacheNetbars = [[WYNetBarManager shareInstance] getAllCacheNetbars];
    if (allCacheNetbars.count > 0) {
        
        self.netBarInfos = [[NSMutableArray alloc] initWithArray:allCacheNetbars];
        [self.netBarTable reloadData];
        return;
    }
    
    __weak NetbarSearchViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getNetbarAllListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude areaCode:_areaCode type:[_filterPriceType intValue] tag:tag];
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
    [[WYEngine shareInstance] getNetbarAllListWithUid:[WYEngine shareInstance].uid page:(int)_netBarNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT latitude:weakSelf.currentLocation.latitude longitude:weakSelf.currentLocation.longitude areaCode:_areaCode type:[_filterPriceType intValue] tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [weakSelf.pullRefreshView finishedLoading];
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
        
        weakSelf.netBarCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"] objectForKey:@"isLast"] boolValue];
        if (weakSelf.netBarCanLoadMore) {
            weakSelf.netBarTable.showsInfiniteScrolling = NO;
        }else{
            weakSelf.netBarTable.showsInfiniteScrolling = YES;
            weakSelf.netBarNextCursor ++;
        }
        
        [weakSelf.netBarTable reloadData];
        
        [[WYNetBarManager shareInstance] saveAllCacheNetbars:weakSelf.netBarInfos];
        
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
    if (self.searchContent.length == 0) {
        [WYProgressHUD lightAlert:@"请输入网吧名称"];
        [self.searchBar becomeFirstResponder];
        return;
    }
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

#pragma mark - custom
-(void)refreshSearchTableView{
    [self refreshSearchBlankShowUI:0];
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
        self.searchContainerView.hidden = NO;
    }else{
        self.searchContainerView.hidden = NO;
    }
    self.searchTableView.hidden = NO;
    [self.searchTableView reloadData];
}

-(void)mapAction:(id)sender{
    if (_searchBarIsEditing) {
        [self doSearchBarEndEditing];
        return;
    }
    
    NetbarMapViewController *mapVc = [[NetbarMapViewController alloc] init];
    WYNavigationController* navigationController = [[WYNavigationController alloc] initWithRootViewController:mapVc];
    navigationController.navigationBarHidden = YES;
    mapVc.location = self.currentLocation;
    mapVc.isPresent = YES;
    mapVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
        
    }];
}
-(IBAction)removeSearchRecordAction:(id)sender{
    [[WYNetBarManager shareInstance] removeHistorySearchRecord];
    [self refreshHistorySearchData:YES];
}
-(IBAction)filterAreaAction:(id)sender{
    _filterType = 0;
    self.filterAreaButton.selected = !self.filterAreaButton.selected;
    BOOL showOpen = self.filterAreaButton.selected;
    if (self.filterPriceButton.selected) {
        showOpen = YES;
        self.filterPriceButton.selected = !self.filterPriceButton.selected;
    }
    [self showFilterViewWith:showOpen];
}
-(IBAction)filterPriceAction:(id)sender{
    _filterType = 1;
    self.filterPriceButton.selected = !self.filterPriceButton.selected;
    BOOL showOpen = self.filterPriceButton.selected;
    if (self.filterAreaButton.selected) {
        showOpen = YES;
        self.filterAreaButton.selected = !self.filterAreaButton.selected;
    }
    [self showFilterViewWith:showOpen];
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
    if (_showFilter) {
        self.filterContainerView.hidden = NO;
    }
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
    self.filterContainerView.hidden = YES;
    
    CGRect frame = self.historyContainerView.frame;
    frame.origin.y = self.titleNavBar.frame.size.height;
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = self.view.bounds.size.height - self.titleNavBar.frame.size.height;
    self.historyContainerView.frame = frame;
    [self.view addSubview:self.historyContainerView];
    self.historyContainerView.hidden = NO;
    [self refreshHistorySearchData:NO];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    if (searchBar == self.searchBar) {
        self.searchContent = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (self.searchContent.length == 0) {
            [self doSearchBarBeginEditing];
        }
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
        [self refreshSearchBlankShowUI:1];
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

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    if (view == self.pullRefreshView) {
        [self refreshNetbarInfos];
    }
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
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
    }else if (tableView == self.filterTableView){
        if (_filterType == 0) {
            return self.filterAreaArray.count;
        }else if (_filterType == 1){
            return self.filterPriceArray.count;
        }else{
            return 0;
        }
    }
    return self.netBarInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.historyTable) {
        return 44;
    }else if (tableView == self.filterTableView){
        return 36;
    }
    return 94;
}

static int historyLabel_Tag = 201, filterLabel_Tag = 202, filterLineImg_Tag = 203;
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
    }else if (tableView == self.filterTableView){
        static NSString *CellIdentifier = @"filterTableViewCellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            UIImageView *botLineImgView = [[UIImageView alloc] init];
            botLineImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
            botLineImgView.frame = CGRectMake(12, 35, self.view.bounds.size.width-24, 0.5);
            botLineImgView.tag = filterLineImg_Tag;
            [cell addSubview:botLineImgView];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, self.view.bounds.size.width-12*2, 36)];
            nameLabel.tag = filterLabel_Tag;
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.numberOfLines = 1;
            nameLabel.textAlignment = NSTextAlignmentLeft;
            nameLabel.font = SKIN_FONT_FROMNAME(12);
            [cell addSubview:nameLabel];
            cell.backgroundColor = [UIColor clearColor];
        }
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:filterLabel_Tag];
        UIImageView *botImgView = (UIImageView *)[cell viewWithTag:filterLineImg_Tag];
        if (_filterType == 0) {
            NSDictionary *infoDic = _filterAreaArray[indexPath.row];
            nameLabel.text = [infoDic stringObjectForKey:@"name"];
            if ([[infoDic stringObjectForKey:@"areaCode"] isEqualToString:_filterAreaCode]) {
                nameLabel.textColor = UIColorToRGB(0xa58600);
                botImgView.backgroundColor = UIColorToRGB(0xa58600);
            }else{
                nameLabel.textColor = SKIN_TEXT_COLOR2;
                botImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
            }
        }else if (_filterType == 1){
            NSDictionary *infoDic = _filterPriceArray[indexPath.row];
            nameLabel.text = [infoDic stringObjectForKey:price_name];
            if ([[infoDic stringObjectForKey:price_type] isEqualToString:_filterPriceType]) {
                nameLabel.textColor = UIColorToRGB(0xa58600);
                botImgView.backgroundColor = UIColorToRGB(0xa58600);
            }else{
                nameLabel.textColor = SKIN_TEXT_COLOR2;
                botImgView.backgroundColor = UIColorToRGB(0xe4e4e4);
            }
        }
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
    }else if (tableView == self.filterTableView){
        [self.netBarTable setContentOffset:CGPointMake(0, 0 - self.netBarTable.contentInset.top) animated:NO];
        if (_filterType == 0) {
            NSDictionary *infoDic = _filterAreaArray[indexPath.row];
            _filterAreaName = [infoDic stringObjectForKey:@"name"];
            _filterAreaCode = [infoDic stringObjectForKey:@"areaCode"];
            _areaCode = _filterAreaCode;
            [self showFilterViewWith:NO];
            [self refreshFilterViewShowUI];
            [self refreshNetbarInfos];
            
        }else if (_filterType == 1){
            NSDictionary *infoDic = _filterPriceArray[indexPath.row];
            _filterPriceName = [infoDic stringObjectForKey:price_name];
            _filterPriceType = [infoDic stringObjectForKey:price_type];
            [self showFilterViewWith:NO];
            [self refreshFilterViewShowUI];
            [self refreshNetbarInfos];
        }
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
    
    if (netbarInfo.latitude.length == 0 || netbarInfo.longitude == 0 || [netbarInfo.latitude intValue] == 0 || [netbarInfo.longitude intValue] == 0) {
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"该网吧暂无数据" cancelButtonTitle:@"好的"];
        [alertView show];
        return;
    }
    
    NetbarMapViewController *nmVc = [[NetbarMapViewController alloc] init];
    nmVc.netbarInfo = netbarInfo;
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [netbarInfo.latitude doubleValue];
    coordinate.longitude = [netbarInfo.longitude doubleValue];
    [nmVc setShowLocation:coordinate.latitude longitute:coordinate.longitude];
    [self.navigationController pushViewController:nmVc animated:YES];
//    nmVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//    [self.navigationController presentViewController:nmVc animated:YES completion:^{
//        
//    }];
}

@end
