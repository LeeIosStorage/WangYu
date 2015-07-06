//
//  MessageListViewController.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MessageListViewController.h"
#import "WYMessageInfo.h"
#import "MessageViewCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "WYSettingConfig.h"
#import "MessageDetailsViewController.h"
#import "DVSwitch.h"
#import "WYBadgeView.h"
#import "WYLinkerHandler.h"

@interface MessageListViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containSwitcher;
@property (weak, nonatomic) IBOutlet UIScrollView *containScroll;
//@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *orderTableView;
@property (weak, nonatomic) IBOutlet UITableView *activityTableView;
@property (weak, nonatomic) IBOutlet UITableView *systemTableView;

@property (strong, nonatomic) DVSwitch *switcher;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (nonatomic, strong) NSMutableArray *orderInfos;
@property (nonatomic, strong) NSMutableArray *activityInfos;
@property (nonatomic, strong) NSMutableArray *systemInfos;
@property (assign, nonatomic) SInt64 orderNextCursor;
@property (assign, nonatomic) SInt64 activityNextCursor;
@property (assign, nonatomic) SInt64 systemNextCursor;
@property (assign, nonatomic) BOOL orderLoadMore;
@property (assign, nonatomic) BOOL activityLoadMore;
@property (assign, nonatomic) BOOL systemLoadMore;

//@property (assign, nonatomic) SInt64 messageNextCursor;
//@property (assign, nonatomic) BOOL messageCanLoadMore;
//
//@property (nonatomic, strong) NSMutableArray *messageInfos;

@property (strong, nonatomic) IBOutlet UIView *messageBlankTipView;
@property (strong, nonatomic) IBOutlet UILabel *messageBlankTipLabel;

@property (strong, nonatomic) WYBadgeView *badgeView1;
@property (strong, nonatomic) WYBadgeView *badgeView2;
@property (strong, nonatomic) WYBadgeView *badgeView3;

@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initSwitchView];
    [self refreshBadgeView];
    [self initContainerScrollView];
    
    _selectedIndex = 1;
    [self refreshMessageWithIndex:_selectedIndex];

    //[self setMessageRead];
    _orderInfos = [[NSMutableArray alloc] init];
    self.pullRefreshView = [[PullToRefreshView alloc] initWithScrollView:self.orderTableView];
    self.pullRefreshView.delegate = self;
    [self.orderTableView addSubview:self.pullRefreshView];
    self.pullRefreshView2 = [[PullToRefreshView alloc] initWithScrollView:self.activityTableView];
    self.pullRefreshView2.delegate = self;
    [self.activityTableView addSubview:self.pullRefreshView2];
    self.pullRefreshView3 = [[PullToRefreshView alloc] initWithScrollView:self.systemTableView];
    self.pullRefreshView3.delegate = self;
    [self.systemTableView addSubview:self.pullRefreshView3];
    
//    [self getCacheMessageList];
//    [self refreshMessageInfos];
    
    WS(weakSelf);
    
    [self.orderTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.orderLoadMore) {
            [weakSelf.orderTableView.infiniteScrollingView stopAnimating];
            weakSelf.orderTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMessageListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.orderNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT type:1 tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.orderTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
                [messageInfo setMessageInfoByJsonDic:dic];
                [weakSelf.orderInfos addObject:messageInfo];
            }
            
            weakSelf.orderLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.orderLoadMore) {
                weakSelf.orderTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.orderTableView.showsInfiniteScrolling = YES;
                weakSelf.orderNextCursor ++;
            }
            
            [weakSelf.orderTableView reloadData];
            
        } tag:tag];
    }];
    [self.activityTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.activityLoadMore) {
            [weakSelf.activityTableView.infiniteScrollingView stopAnimating];
            weakSelf.activityTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMessageListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.activityNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT type:2 tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.activityTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
                [messageInfo setMessageInfoByJsonDic:dic];
                [weakSelf.activityInfos addObject:messageInfo];
            }
            
            weakSelf.activityLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.activityLoadMore) {
                weakSelf.activityTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.activityTableView.showsInfiniteScrolling = YES;
                weakSelf.activityNextCursor ++;
            }
            
            [weakSelf.activityTableView reloadData];
            
        } tag:tag];
    }];

    [self.systemTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.systemLoadMore) {
            [weakSelf.systemTableView.infiniteScrollingView stopAnimating];
            weakSelf.systemTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMessageListWithUid:[WYEngine shareInstance].uid page:(int)weakSelf.systemNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT type:3 tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.systemTableView.infiniteScrollingView stopAnimating];
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
                [messageInfo setMessageInfoByJsonDic:dic];
                [weakSelf.systemInfos addObject:messageInfo];
            }
            
            weakSelf.systemLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.systemLoadMore) {
                weakSelf.systemTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.systemTableView.showsInfiniteScrolling = YES;
                weakSelf.systemNextCursor ++;
            }
            
            [weakSelf.systemTableView reloadData];
            
        } tag:tag];
    }];
    weakSelf.orderTableView.showsInfiniteScrolling = NO;
    weakSelf.activityTableView.showsInfiniteScrolling = NO;
    weakSelf.systemTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"我的消息"];
}

- (void)initSwitchView{
    self.switcher = [DVSwitch switchWithStringsArray:@[@"订单消息", @"活动消息", @"系统消息"]];
    self.switcher.frame = CGRectMake(12, 7, SCREEN_WIDTH - 12 * 2, 30);
    self.switcher.font = SKIN_FONT_FROMNAME(14);
    self.switcher.cornerRadius = 4;
    self.switcher.sliderOffset = 0.5;
    [self.switcher.layer setMasksToBounds:YES];
    [self.switcher.layer setCornerRadius:4.0];
    [self.switcher.layer setBorderWidth:0.5]; //边框宽度
    [self.switcher.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
    
    self.switcher.backgroundColor = [UIColor colorWithRed:241/255.0 green:241/255.0 blue:241/255.0 alpha:1.0];
    self.switcher.sliderColor = [UIColor whiteColor];
    
    self.switcher.labelTextColorInsideSlider = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    self.switcher.labelTextColorOutsideSlider = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    [self.containSwitcher addSubview:self.switcher];
    WS(weakSelf);
    [self.switcher setPressedHandler:^(NSUInteger index) {
        NSLog(@"Did press position on first switch at index: %lu", (unsigned long)index);
        weakSelf.selectedIndex = index + 1;
        [weakSelf refreshMessageWithIndex:index + 1];
    }];
    CGFloat sliderWidth = self.switcher.frame.size.width / 3;
    float width = [WYCommonUtils widthWithText:@"订单消息" font:self.switcher.font lineBreakMode:NSLineBreakByWordWrapping];
    float space = (sliderWidth - width) / 2 - 8;

    CGRect messageIconFrame = CGRectMake(sliderWidth - space, 0, 35, 20);
    _badgeView1 = [[WYBadgeView alloc] initWithFrame:messageIconFrame];
    [self.containSwitcher addSubview:_badgeView1];
    messageIconFrame = CGRectMake(sliderWidth*2 - space, 0, 35, 20);
    _badgeView2 = [[WYBadgeView alloc] initWithFrame:messageIconFrame];
    [self.containSwitcher addSubview:_badgeView2];
    messageIconFrame = CGRectMake(sliderWidth*3 - space, 0, 35, 20);
    _badgeView3 = [[WYBadgeView alloc] initWithFrame:messageIconFrame];
    [self.containSwitcher addSubview:_badgeView3];
}

- (void)initContainerScrollView{
    CGRect frame = _containScroll.frame;
    frame.size.height = SCREEN_HEIGHT - CGRectGetHeight(self.titleNavBar.frame) - CGRectGetHeight(self.containSwitcher.frame);
    _containScroll.frame = frame;
    _containScroll.contentSize = CGSizeMake(SCREEN_WIDTH * 3, _containScroll.frame.size.height);
    
    frame = self.activityTableView.frame;
    frame.origin.x = SCREEN_WIDTH;
    self.activityTableView.frame = frame;
    
    frame = self.systemTableView.frame;
    frame.origin.x = SCREEN_WIDTH*2;
    self.systemTableView.frame = frame;
}

- (void)refreshBadgeView{
    NSDictionary *messageDic = [[WYSettingConfig staticInstance] getMessageDic];
    self.badgeView1.unreadNum = [messageDic intValueForKey:@"order"];
    if ([messageDic intValueForKey:@"order"] == 0) {
        self.badgeView1.hidden = YES;
    }else{
        self.badgeView1.hidden = NO;
    }
    self.badgeView2.unreadNum = [messageDic intValueForKey:@"activity"];
    if ([messageDic intValueForKey:@"activity"] == 0) {
        self.badgeView2.hidden = YES;
    }else{
        self.badgeView2.hidden = NO;
    }
    self.badgeView3.unreadNum = [messageDic intValueForKey:@"sys"];
    if ([messageDic intValueForKey:@"sys"] == 0) {
        self.badgeView3.hidden = YES;
    }else{
        self.badgeView3.hidden = NO;
    }
}

- (void)refreshShowUI{
    self.messageBlankTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.messageBlankTipLabel.textColor = SKIN_TEXT_COLOR2;
    CGRect frame = self.messageBlankTipView.frame;
    frame.size.width = SCREEN_WIDTH;
    frame.origin.y = 0;
    if (_selectedIndex == 1) {
        if (self.orderInfos && self.orderInfos.count == 0) {
            frame.origin.x = 0;
            [self.orderTableView addSubview:self.messageBlankTipView];
        }else {
            if (self.messageBlankTipView.superview) {
                [self.messageBlankTipView removeFromSuperview];
            }
        }
    } else if (_selectedIndex == 2) {
        if (self.activityInfos && self.activityInfos.count == 0) {
            frame.origin.x = SCREEN_WIDTH;
            [self.activityTableView addSubview:self.messageBlankTipView];
        }else {
            if (self.messageBlankTipView.superview) {
                [self.messageBlankTipView removeFromSuperview];
            }
        }
    } else if (_selectedIndex == 3) {
        if (self.systemInfos && self.systemInfos.count == 0) {
            frame.origin.x = 2*SCREEN_WIDTH;
            [self.systemTableView addSubview:self.messageBlankTipView];
        }else {
            if (self.messageBlankTipView.superview) {
                [self.messageBlankTipView removeFromSuperview];
            }
        }
    }
}

- (void)refreshMessageWithIndex:(NSUInteger)index{
    _orderNextCursor = 1;
    __weak MessageListViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMessageListWithUid:[WYEngine shareInstance].uid page:(int)_orderNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT type:(int)index tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        if (index == 1) {
            [weakSelf.pullRefreshView finishedLoading];
        }else if (index == 2) {
            [weakSelf.pullRefreshView2 finishedLoading];
        }else if (index == 3) {
            [weakSelf.pullRefreshView3 finishedLoading];
        }
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        if (index == 1) {
            weakSelf.orderInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
                [messageInfo setMessageInfoByJsonDic:dic];
                [weakSelf.orderInfos addObject:messageInfo];
            }
            [weakSelf refreshShowUI];
            [weakSelf.orderTableView reloadData];
            weakSelf.orderLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.orderLoadMore) {
                weakSelf.orderTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.orderTableView.showsInfiniteScrolling = YES;
                weakSelf.orderNextCursor ++;
            }
        }else if (index == 2) {
            weakSelf.activityInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
                [messageInfo setMessageInfoByJsonDic:dic];
                [weakSelf.activityInfos addObject:messageInfo];
            }
            [weakSelf refreshShowUI];
            [weakSelf.activityTableView reloadData];
            weakSelf.activityLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.activityLoadMore) {
                weakSelf.activityTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.activityTableView.showsInfiniteScrolling = YES;
                weakSelf.activityNextCursor ++;
            }
        }else if (index == 3) {
            weakSelf.systemInfos = [[NSMutableArray alloc] init];
            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
            for (NSDictionary *dic in object) {
                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
                [messageInfo setMessageInfoByJsonDic:dic];
                [weakSelf.systemInfos addObject:messageInfo];
            }
            [weakSelf refreshShowUI];
            [weakSelf.systemTableView reloadData];
            weakSelf.systemLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
            if (weakSelf.systemLoadMore) {
                weakSelf.systemTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.systemTableView.showsInfiniteScrolling = YES;
                weakSelf.systemNextCursor ++;
            }
        }
    }tag:tag];
}

- (void)doRefreshWithRespond:(NSDictionary *)jsonRet{
    
}

#pragma mark - request
- (void)deleteMessage:(WYMessageInfo *)messageInfo tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] deleteMessageWithUid:[WYEngine shareInstance].uid msgId:messageInfo.msgId type:messageInfo.type tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            return;
        }
        if (!messageInfo.isRead) {
            [[WYSettingConfig staticInstance] calculateMessageNum:weakSelf.selectedIndex];
            [weakSelf refreshBadgeView];
        }
        [weakSelf deleteMessageWith:tableView forRowAtIndexPath:indexPath];
    } tag:tag];
}

- (void)setMessageRead:(WYMessageInfo *)messageInfo tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] setMessageReadWithUid:[WYEngine shareInstance].uid msgId:messageInfo.msgId type:messageInfo.type tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            return;
        }
        [[WYSettingConfig staticInstance] calculateMessageNum:weakSelf.selectedIndex];
        [weakSelf refreshBadgeView];
        messageInfo.isRead = YES;
        [weakSelf refreshMessageWith:tableView forRowAtIndexPath:indexPath];
        
        NSString *wyHref = [NSString stringWithFormat:@"wycategory://%@?msgId=%@&objId=%@",messageInfo.realUrlHost,messageInfo.msgId,messageInfo.objId];
            
        id vc = [WYLinkerHandler handleDealWithHref:wyHref From:self.navigationController];
        if (vc) {
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    } tag:tag];
}

//- (void)setMessageRead{
//    
//    [[WYSettingConfig staticInstance] removeMessageNum];
//    [[WYSettingConfig staticInstance] setMineMessageUnreadEvent:NO];
//    
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    [[WYEngine shareInstance] setMessageReadWithUid:[WYEngine shareInstance].uid type:0 tag:tag];
//    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
//        if (!jsonRet || errorMsg) {
//            if (!errorMsg.length) {
//                errorMsg = @"请求失败";
//            }
//            return;
//        }
//    }tag:tag];
//}
//
//-(void)getCacheMessageList{
//    __weak MessageListViewController *weakSelf = self;
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    [[WYEngine shareInstance] addGetCacheTag:tag];
//    [[WYEngine shareInstance] getMessageListWithUid:[WYEngine shareInstance].uid page:1 pageSize:DATA_LOAD_PAGESIZE_COUNT type:1 tag:tag];
//    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
//        if (jsonRet == nil) {
//            //...
//        }else{
//            weakSelf.orderInfos = [[NSMutableArray alloc] init];
//            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
//            for (NSDictionary *dic in object) {
//                WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
//                [messageInfo setMessageInfoByJsonDic:dic];
//                [weakSelf.orderInfos addObject:messageInfo];
//            }
//            [weakSelf.orderTableView reloadData];
//        }
//    }];
//}

//-(void)refreshMessageInfos{
//    _orderNextCursor = 1;
//    __weak MessageListViewController *weakSelf = self;
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    [[WYEngine shareInstance] getMessageListWithUid:[WYEngine shareInstance].uid page:(int)_orderNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT type:1 tag:tag];
//    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        [weakSelf.pullRefreshView finishedLoading];
//        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
//        if (!jsonRet || errorMsg) {
//            if (!errorMsg.length) {
//                errorMsg = @"请求失败";
//            }
//            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
//            return;
//        }
//        
//        weakSelf.orderInfos = [[NSMutableArray alloc] init];
//        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
//        for (NSDictionary *dic in object) {
//            WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
//            [messageInfo setMessageInfoByJsonDic:dic];
//            [weakSelf.orderInfos addObject:messageInfo];
//        }
//        
//        weakSelf.orderLoadMore = [[[jsonRet objectForKey:@"object"] objectForKey:@"isLast"] boolValue];
//        if (weakSelf.orderLoadMore) {
//            weakSelf.orderTableView.showsInfiniteScrolling = NO;
//        }else{
//            weakSelf.orderTableView.showsInfiniteScrolling = YES;
//            weakSelf.orderNextCursor ++;
//        }
//        [weakSelf refreshShowUI];
//        [weakSelf.orderTableView reloadData];
//        
//    }tag:tag];
//}

//#pragma mark - scrollView
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if(scrollView == self.containScroll){
//
//    }
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    if (scrollView == self.containScroll) {
//        if (0==fmod(scrollView.contentOffset.x,SCREEN_WIDTH)){
//            _selectedIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
//            [self.switcher forceSelectedIndex:_selectedIndex animated:YES];
//        }
//    }
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    if (scrollView == self.containScroll) {
//        if (decelerate) {
//            _selectedIndex = scrollView.contentOffset.x/SCREEN_WIDTH;
//        }
//    }
//}

- (void)transitionToViewAtIndex:(NSUInteger)index{
    [_containScroll setContentOffset:CGPointMake((index-1) * SCREEN_WIDTH, 0)];
}

- (void)setSelectedIndex:(NSUInteger)index{
    if (index != self.selectedIndex) {
        _selectedIndex = index;
        [self transitionToViewAtIndex:index];
    }
}

#pragma mark PullToRefreshViewDelegate
- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view {
    [self refreshMessageWithIndex:_selectedIndex];
}

- (NSDate *)pullToRefreshViewLastUpdated:(PullToRefreshView *)view {
    return [NSDate date];
}

#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.orderTableView)
        return _orderInfos.count;
    else if (tableView == self.activityTableView)
        return _activityInfos.count;
    else
        return _systemInfos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageViewCell";
    MessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    if (tableView == _orderTableView) {
        cell.messageInfo = _orderInfos[indexPath.row];
    }else if (tableView == _activityTableView) {
        cell.messageInfo = _activityInfos[indexPath.row];
    }else if (tableView == _systemTableView) {
        cell.messageInfo = _systemInfos[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    WYMessageInfo *messageInfo;
    if (tableView == _orderTableView) {
        messageInfo = _orderInfos[indexPath.row];
    }else if (tableView == _activityTableView) {
        messageInfo = _activityInfos[indexPath.row];
    }else if (tableView == _systemTableView) {
        messageInfo = _systemInfos[indexPath.row];
    }
    if (!messageInfo) {
        return;
    }
    if (!messageInfo.isRead) {
        [self setMessageRead:messageInfo tableView:tableView forRowAtIndexPath:indexPath];
    }else {
        NSString *wyHref = [NSString stringWithFormat:@"wycategory://%@?msgId=%@&objId=%@",messageInfo.realUrlHost,messageInfo.msgId,messageInfo.objId];
        id vc = [WYLinkerHandler handleDealWithHref:wyHref From:self.navigationController];
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WYMessageInfo *messageInfo;
        if (tableView == self.orderTableView) {
            messageInfo = [_orderInfos objectAtIndex:indexPath.row];
        }else if (tableView == self.activityTableView) {
            messageInfo = [_activityInfos objectAtIndex:indexPath.row];
        }else if (tableView == self.systemTableView) {
            messageInfo = [_systemInfos objectAtIndex:indexPath.row];
        }
        if (!messageInfo) {
            return;
        }
        [self deleteMessage:messageInfo tableView:tableView forRowAtIndexPath:indexPath];
    }
}

- (void)deleteMessageWith:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.orderTableView) {
        [_orderInfos removeObjectAtIndex:indexPath.row];
        [self.orderTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else if (tableView == self.activityTableView) {
        [_activityInfos removeObjectAtIndex:indexPath.row];
        [self.activityTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }else if (tableView == self.systemTableView) {
        [_systemInfos removeObjectAtIndex:indexPath.row];
        [self.systemTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)refreshMessageWith:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.orderTableView) {
        [self.orderTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else if (tableView == self.activityTableView) {
        [self.activityTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else if (tableView == self.systemTableView) {
        [self.systemTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)dealloc {
    _orderTableView.delegate = nil;
    _orderTableView.dataSource = nil;
    _activityTableView.delegate = nil;
    _activityTableView.dataSource = nil;
    _systemTableView.delegate = nil;
    _systemTableView.dataSource = nil;
}

@end
