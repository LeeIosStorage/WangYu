//
//  MatchWarDetailViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchWarDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "SettingViewCell.h"
#import "MatchCommentViewCell.h"
#import "WYEngine.h"
#import "NetbarDetailViewController.h"
#import "WYProgressHUD.h"
#import "WYShareActionSheet.h"
#import "WYMatchApplyInfo.h"
#import "WYMatchCommentInfo.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridViewCell+Extended.h"
#import "HPGrowingTextView.h"
#import "WYAlertView.h"
#import "WYProgressHUD.h"
#import "ManageMatchWarViewController.h"
#import "AppDelegate.h"

#define MATCH_DETAIL_TYPE_INFO          0
#define MATCH_DETAIL_TYPE_COMMENT       1

#define GRID_IMAGE_SIZE       31
#define item_spacing          7

#define growingTextViewMaxNumberOfLines 3

@interface MatchWarDetailViewController ()<UITableViewDataSource,UITableViewDelegate,WYShareActionSheetDelegate,GMGridViewDataSource, GMGridViewActionDelegate,HPGrowingTextViewDelegate>
{
    WYShareActionSheet *_shareAction;
    
    NSRange _textRange;
    int _maxReplyTextLength;
}
@property (nonatomic, strong) IBOutlet UITableView *matchInfoTableView;
@property (strong, nonatomic) NSMutableArray *commentInfos;
@property (nonatomic, strong) IBOutlet UITableView *commentTableView;

@property (assign, nonatomic) NSInteger selectedSegmentIndex;
@property (assign, nonatomic) SInt64  commentNextCursor;
@property (assign, nonatomic) BOOL commentCanLoadMore;

@property (nonatomic, strong) IBOutlet UIView *matchHeadContainerView;
@property (nonatomic, strong) IBOutlet UIImageView *bkImageView;
@property (nonatomic, strong) UIView   *supInfoHeadView;
@property (nonatomic, strong) UIView   *supCommentHeadView;
@property (nonatomic, strong) IBOutlet UILabel *matchTitleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *matchOwnerAvatarImgView;
@property (nonatomic, strong) IBOutlet UIView *statusView;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIView *segmentView;
@property (nonatomic, strong) IBOutlet UIImageView *segmentMoveImageView;
@property (nonatomic, strong) IBOutlet UIImageView *typeShadowImageView;
@property (nonatomic, strong) IBOutlet UILabel *infoTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *infoTabButton;
@property (nonatomic, strong) IBOutlet UILabel *commentNumTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *commentTabButton;

//自定义TitleBar
@property (strong, nonatomic) IBOutlet UIView *customTitleBarView;
@property (strong, nonatomic) IBOutlet UIButton *cusBackButton;
@property (strong, nonatomic) IBOutlet UILabel *toobarTitleLabel;

//报名view
@property (strong, nonatomic) IBOutlet UIView *matchFooterContainerView;
@property (strong, nonatomic) IBOutlet UIView *applyContainerView;
@property (strong, nonatomic) IBOutlet UILabel *applyCountLabel;
@property (strong, nonatomic) IBOutlet GMGridView *applyPeopleGridView;

@property (strong, nonatomic) IBOutlet UIView *commentFooterView;

@property (strong, nonatomic) IBOutlet UIView *shareBottomContainerView;
@property (strong, nonatomic) IBOutlet UIButton *manageButton;

@property (strong, nonatomic) IBOutlet UIView *commentBottomContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *inputViewBgImageView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *growingTextView;
@property (strong, nonatomic) IBOutlet UILabel *placeHolderLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

-(IBAction)matchInfoAction:(id)sender;
-(IBAction)commentSegmentAction:(id)sender;
-(IBAction)shareAction:(id)sender;
-(IBAction)manageAction:(id)sender;
-(IBAction)sendAction:(id)sender;

@end

@implementation MatchWarDetailViewController

- (void)dealloc{
    _matchInfoTableView.delegate = nil;
    _matchInfoTableView.dataSource = nil;
    _commentTableView.delegate = nil;
    _commentTableView.dataSource = nil;
    _growingTextView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    self.supInfoHeadView = [[UIView alloc] init];
    self.supInfoHeadView.backgroundColor = [UIColor clearColor];
    self.supCommentHeadView = [[UIView alloc] init];
    self.supCommentHeadView.backgroundColor = [UIColor clearColor];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self setContentInsetForScrollView:self.matchInfoTableView inset:inset];
    [self setContentInsetForScrollView:self.commentTableView inset:inset];
    [self.view insertSubview:self.customTitleBarView aboveSubview:self.titleNavBar];
    
    _applyPeopleGridView.backgroundColor = [UIColor clearColor];
    _applyPeopleGridView.style = GMGridViewStyleSwap;
    _applyPeopleGridView.itemSpacing = item_spacing;
    _applyPeopleGridView.minEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    _applyPeopleGridView.centerGrid = NO;
    _applyPeopleGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    _applyPeopleGridView.actionDelegate = self;
    _applyPeopleGridView.showsHorizontalScrollIndicator = NO;
    _applyPeopleGridView.showsVerticalScrollIndicator = NO;
    _applyPeopleGridView.dataSource = self;
    
    
    _maxReplyTextLength = 500;
    _growingTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _growingTextView.minNumberOfLines = 1;
    _growingTextView.maxNumberOfLines = growingTextViewMaxNumberOfLines;
    _growingTextView.returnKeyType = UIReturnKeySend; //just as an example
    _growingTextView.font = [UIFont systemFontOfSize:14.0f];
    _growingTextView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
    _growingTextView.delegate = self;
    _growingTextView.backgroundColor = [UIColor clearColor];
    _growingTextView.internalTextView.backgroundColor = [UIColor clearColor];
    _growingTextView.textColor = SKIN_TEXT_COLOR1;
    self.placeHolderLabel.font = SKIN_FONT_FROMNAME(14);
    self.placeHolderLabel.textColor = UIColorToRGB(0xc7c7c7);
    self.placeHolderLabel.hidden = NO;
    self.inputViewBgImageView.backgroundColor = UIColorToRGB(0xf5f5f5);
    [self.inputViewBgImageView.layer setMasksToBounds:YES];
    [self.inputViewBgImageView.layer setCornerRadius:4.0];
    [self.inputViewBgImageView.layer setBorderWidth:0.5]; //边框宽度
    [self.inputViewBgImageView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
    
    _selectedSegmentIndex = 0;
    CGPoint center = self.segmentMoveImageView.center;
    center.x = SCREEN_WIDTH/4+self.infoTipLabel.frame.origin.x/2;
    self.segmentMoveImageView.center = center;
    self.matchHeadContainerView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.matchHeadContainerView.layer.shadowOpacity = 0.3;
    self.matchHeadContainerView.layer.shadowOffset = CGSizeMake(0, 1);
    self.matchHeadContainerView.layer.shadowRadius = 2.0;
    self.matchHeadContainerView.layer.shouldRasterize = YES;
    self.matchHeadContainerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    CGRect frame = self.matchHeadContainerView.frame;
    frame.size.height = 238;
    self.matchHeadContainerView.frame = frame;
    
    frame = self.infoTipLabel.frame;
    frame.size.width = SCREEN_WIDTH/2-frame.origin.x;
    self.infoTipLabel.frame = frame;
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(commentLongPressAction:)];
    [self.matchInfoTableView addGestureRecognizer:longPressGesture];
    
    WYMatchWarInfo* copyMatchWarInfo = [[WYMatchWarInfo alloc] init];
    copyMatchWarInfo.mId = self.matchWarInfo.mId;
    if (self.matchWarInfo.matchWarInfoByJsonDic) {
        [copyMatchWarInfo setMatchWarInfoByJsonDic:self.matchWarInfo.matchWarInfoByJsonDic];
        copyMatchWarInfo.bgAvatar = nil;
    }
    _matchWarInfo = copyMatchWarInfo;
    
    
    [self refreshHeadViewShow];
    [self feedsTypeSwitch:MATCH_DETAIL_TYPE_INFO needRefreshFeeds:YES];
    
    
    self.commentCanLoadMore = YES;
    WS(weakSelf);
    [self.commentTableView addInfiniteScrollingWithActionHandler:^{
        if (!weakSelf) {
            return;
        }
        if (weakSelf.commentCanLoadMore) {
            [weakSelf.commentTableView.infiniteScrollingView stopAnimating];
            weakSelf.commentTableView.showsInfiniteScrolling = NO;
            return ;
        }
        
        int tag = [[WYEngine shareInstance] getConnectTag];
        [[WYEngine shareInstance] getMatchCommentInfoWithMatchId:weakSelf.matchWarInfo.mId page:(int)weakSelf.commentNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
            if (!weakSelf) {
                return;
            }
            [weakSelf.commentTableView.infiniteScrollingView stopAnimating];
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
                if ([dic isKindOfClass:[NSDictionary class]]) {
                    WYMatchCommentInfo *commentInfo = [[WYMatchCommentInfo alloc] init];
                    [commentInfo setCommentInfoByDic:dic];
                    [weakSelf.commentInfos addObject:commentInfo];
                }
            }
            
            weakSelf.commentCanLoadMore = [[jsonRet dictionaryObjectForKey:@"object"] boolValueForKey:@"isLast"];
            if (weakSelf.commentCanLoadMore) {
                weakSelf.commentTableView.showsInfiniteScrolling = NO;
            }else{
                weakSelf.commentTableView.showsInfiniteScrolling = YES;
                //可以加载更多
                weakSelf.commentNextCursor ++;
            }
            
//            [weakSelf refreshHeadViewShow];
            [weakSelf.commentTableView reloadData];
            
        } tag:tag];
    }];
    self.commentTableView.showsInfiniteScrolling = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
//    [self setTitle:@"约战详情"];
    self.titleNavBar.backgroundColor = SKIN_TEXT_COLOR1;
    self.titleNavBar.alpha = 0.0;
    [self setBarBackgroundColor:[UIColor clearColor] showLine:NO];
//    [self.titleNavBarLeftButton setTintColor:[UIColor whiteColor]];
    [self setTilteLeftViewHide:YES];
}

-(void)feedsTypeSwitch:(int)tag needRefreshFeeds:(BOOL)needRefresh
{
    if (tag == MATCH_DETAIL_TYPE_INFO) {
        //减速率
        self.commentTableView.decelerationRate = 0.0f;
        self.matchInfoTableView.decelerationRate = 1.0f;
        self.commentTableView.hidden = YES;
        self.matchInfoTableView.hidden = NO;
        
        if ([self.matchHeadContainerView superview]) {
            [self.matchHeadContainerView removeFromSuperview];
        }
        _supInfoHeadView.frame = self.matchHeadContainerView.frame;
        [_supInfoHeadView addSubview:self.matchHeadContainerView];
        self.matchInfoTableView.tableHeaderView = _supInfoHeadView;
        
        [self scrollViewDidScroll:self.matchInfoTableView];
        [self refreshBottomViewShow];
        
        if (needRefresh) {
            [self getCacheMatchWarInfo];
            [self refreshMatchWarInfo];
        }
    }else if (tag == MATCH_DETAIL_TYPE_COMMENT){
        
        self.commentTableView.decelerationRate = 1.0f;
        self.matchInfoTableView.decelerationRate = 0.0f;
        self.matchInfoTableView.hidden = YES;
        self.commentTableView.hidden = NO;
        
        if ([self.matchHeadContainerView superview]) {
            [self.matchHeadContainerView removeFromSuperview];
        }
        _supCommentHeadView.frame = self.matchHeadContainerView.frame;
        [_supCommentHeadView addSubview:self.matchHeadContainerView];
        self.commentTableView.tableHeaderView = _supCommentHeadView;
        
        [self scrollViewDidScroll:self.commentTableView];
        [self refreshBottomViewShow];
        
        if (!_commentInfos) {
            [self getCacheCommentInfos];
            [self refreshCommentInfos];
            return;
        }
        if (needRefresh) {
            [self refreshCommentInfos];
        }
    }
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
-(void)refreshHeadViewShow{
    
    self.infoTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.infoTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.commentNumTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.commentNumTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchTitleLabel.font = SKIN_FONT_FROMNAME(15);
    
    [self.matchOwnerAvatarImgView.layer setBorderWidth:1.5]; //边框宽度
    [self.matchOwnerAvatarImgView.layer setBorderColor:[UIColor whiteColor].CGColor];//边框颜色
    self.matchOwnerAvatarImgView.layer.masksToBounds = YES;
    self.matchOwnerAvatarImgView.layer.cornerRadius = self.matchOwnerAvatarImgView.frame.size.width/2;
    self.matchOwnerAvatarImgView.clipsToBounds = YES;
    self.matchOwnerAvatarImgView.contentMode = UIViewContentModeScaleAspectFill;
    [self.matchOwnerAvatarImgView sd_setImageWithURL:_matchWarInfo.userInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon_small"]];
    
    self.bkImageView.clipsToBounds = YES;
    self.bkImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.bkImageView sd_setImageWithURL:_matchWarInfo.bgAvatarUrl placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
    
    self.statusView.alpha = 0.7;
    self.statusView.layer.cornerRadius = self.statusView.frame.size.width/2;
    self.statusView.clipsToBounds = YES;
    self.statusView.backgroundColor = UIColorToRGB(0xfdd730);
    self.statusLabel.font = SKIN_FONT_FROMNAME(11);
    self.statusLabel.textColor = SKIN_TEXT_COLOR1;
//    self.statusLabel.text = @"进行中";
    
    self.toobarTitleLabel.font = SKIN_FONT_FROMNAME(18);
    self.toobarTitleLabel.textColor = [UIColor whiteColor];
    self.toobarTitleLabel.text = _matchWarInfo.title;
    
    self.matchTitleLabel.text = _matchWarInfo.title;
    
    
    self.manageButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.manageButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.manageButton.layer setMasksToBounds:YES];
    [self.manageButton.layer setCornerRadius:4.0];
    self.manageButton.backgroundColor = SKIN_COLOR;
    [self.manageButton setTitle:@"加入约战" forState:0];
    
    self.sendButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.sendButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.sendButton.layer setMasksToBounds:YES];
    [self.sendButton.layer setCornerRadius:4.0];
    [self.sendButton setTitle:@"发送" forState:0];
    [_sendButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
    _sendButton.enabled = NO;
    
    if (_matchWarInfo.isStart == 0) {
        self.statusLabel.text = @"报名中";
        self.statusView.backgroundColor = UIColorToRGB(0xfdd730);
    }else if (_matchWarInfo.isStart == 1){
        self.statusLabel.text = @"已开始";
        self.statusView.backgroundColor = UIColorToRGB(0xfdd730);
    }else{
        self.statusLabel.text = @"";
    }
    
    self.manageButton.enabled = YES;
    if (_matchWarInfo.userStatus == 1) {
        [self.manageButton setTitle:@"约战管理" forState:0];
    }else if (_matchWarInfo.userStatus == 2){
        [self.manageButton setTitle:@"退出约战" forState:0];
    }else if (_matchWarInfo.userStatus == 3){
        [self.manageButton setTitle:@"加入约战" forState:0];
    }else{
        self.manageButton.enabled = NO;
        self.manageButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    }
    
    self.commentNumTipLabel.text = [NSString stringWithFormat:@"评论(%d)",_matchWarInfo.commentsCount];
    
    //报名view
    self.applyCountLabel.font = SKIN_FONT_FROMNAME(12);
    self.applyCountLabel.textColor = SKIN_TEXT_COLOR1;
    NSString *string = [NSString stringWithFormat:@"报名成员  %d/%d",_matchWarInfo.applyCount,_matchWarInfo.peopleNum];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSUInteger length = [[NSString stringWithFormat:@"%d",_matchWarInfo.applyCount] length];
    UIColor *color = UIColorToRGB(0xf03f3f);
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:NSMakeRange(6, length)];
    self.applyCountLabel.attributedText = attrString;
    
    
    //GridView
    CGFloat applyContainerViewHeight = 85;
    self.applyPeopleGridView.hidden = YES;
    if (self.matchWarInfo.applys.count > 0) {
        self.applyPeopleGridView.hidden = NO;
        int peopleCount = (int)self.matchWarInfo.applys.count;
        int lineCount = (SCREEN_WIDTH - 12*2)/(GRID_IMAGE_SIZE+item_spacing);
        int rowCount = 0;
        if (peopleCount%lineCount == 0) {
            rowCount = peopleCount/lineCount;
        }else{
            rowCount = peopleCount/lineCount + 1;
        }
        if (rowCount > 3) {
            rowCount = 3;
        }
        
        CGRect frame1 = self.applyPeopleGridView.frame;
        frame1.size.width = (GRID_IMAGE_SIZE+item_spacing)*peopleCount;
        if (frame1.size.width > (SCREEN_WIDTH - 12*2)) {
            frame1.size.width = (SCREEN_WIDTH - 12*2)+7;
        }
        frame1.size.height = (GRID_IMAGE_SIZE+item_spacing)*rowCount-3;
        if (frame1.size.height < GRID_IMAGE_SIZE) {
            frame1.size.height = GRID_IMAGE_SIZE;
        }
        self.applyPeopleGridView.frame = frame1;
        
        applyContainerViewHeight = self.applyPeopleGridView.frame.origin.y + self.applyPeopleGridView.frame.size.height +12;
    }
    [self.applyPeopleGridView reloadData];
    
    CGRect frame = self.applyContainerView.frame;
    frame.size.height = applyContainerViewHeight;
    self.applyContainerView.frame = frame;
    
    frame = self.matchFooterContainerView.frame;
    frame.size.height = self.applyContainerView.frame.origin.y + self.applyContainerView.frame.size.height;
    self.matchFooterContainerView.frame = frame;
    
    self.matchInfoTableView.tableFooterView = self.matchFooterContainerView;
    if (!_commentInfos || _commentInfos.count == 0) {
        self.commentFooterView.backgroundColor = self.view.backgroundColor;
        self.commentTableView.tableFooterView = self.commentFooterView;
    }else{
        self.commentTableView.tableFooterView = nil;
    }
    
    
    if (_selectedSegmentIndex == MATCH_DETAIL_TYPE_INFO) {
        [self refreshSegmentViewUI:self.infoTabButton];
    }else if (_selectedSegmentIndex == MATCH_DETAIL_TYPE_COMMENT){
        [self refreshSegmentViewUI:self.commentTabButton];
    }
}

-(void)refreshSegmentViewUI:(UIButton *)sender{
    int MoM = 1;
    if (sender == self.infoTabButton) {
        MoM = 1;
        self.infoTabButton.selected = YES;
        self.commentTabButton.selected = NO;
        self.infoTipLabel.textColor = UIColorToRGB(0xf03f3f);
        self.commentNumTipLabel.textColor = SKIN_TEXT_COLOR1;
        _selectedSegmentIndex = MATCH_DETAIL_TYPE_INFO;
        [self feedsTypeSwitch:(int)_selectedSegmentIndex needRefreshFeeds:NO];
    }else if (sender == self.commentTabButton){
        MoM = 3;
        self.commentTabButton.selected = YES;
        self.infoTabButton.selected = NO;
        self.commentNumTipLabel.textColor = UIColorToRGB(0xf03f3f);
        self.infoTipLabel.textColor = SKIN_TEXT_COLOR1;
        _selectedSegmentIndex = MATCH_DETAIL_TYPE_COMMENT;
        [self feedsTypeSwitch:(int)_selectedSegmentIndex needRefreshFeeds:NO];
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.segmentMoveImageView.center;
        center.x = (SCREEN_WIDTH/4)*MoM;
        if (MoM == 1) {
            center.x = SCREEN_WIDTH/4+self.infoTipLabel.frame.origin.x/2;
        }
        self.segmentMoveImageView.center = center;
    }];
}

-(void)refreshBottomViewShow{
    
    if (_selectedSegmentIndex == MATCH_DETAIL_TYPE_INFO) {
        if (_commentBottomContainerView.superview) {
            [_commentBottomContainerView removeFromSuperview];
        }
        CGRect frame = self.shareBottomContainerView.frame;
        frame.origin.y = SCREEN_HEIGHT - frame.size.height;
        self.shareBottomContainerView.frame = frame;
        [self.view addSubview:self.shareBottomContainerView];
        
    }else if (_selectedSegmentIndex == MATCH_DETAIL_TYPE_COMMENT){
        if (_shareBottomContainerView.superview) {
            [_shareBottomContainerView removeFromSuperview];
        }
        CGRect frame = self.commentBottomContainerView.frame;
        frame.origin.y = SCREEN_HEIGHT - frame.size.height;
        frame.size.width = SCREEN_WIDTH;
        self.commentBottomContainerView.frame = frame;
        [self.view addSubview:self.commentBottomContainerView];
    }
}
#pragma mark - IBAction
-(IBAction)matchInfoAction:(id)sender{
    if (self.infoTabButton.selected) {
        return;
    }
    [self refreshSegmentViewUI:sender];
}
-(IBAction)commentSegmentAction:(id)sender{
    if (self.commentTabButton.selected) {
        return;
    }
    [self refreshSegmentViewUI:sender];
}

-(IBAction)shareAction:(id)sender{
    _shareAction = [[WYShareActionSheet alloc] init];
    _shareAction.matchWarInfo = _matchWarInfo;
    _shareAction.owner = self;
    [_shareAction showShareAction];
}
-(IBAction)manageAction:(id)sender{
    
//    [self manageMatchWar];
//    return;
    if ([[WYEngine shareInstance] needUserLogin:@"登录后才能报名约战"]) {
        return;
    }
    if (_matchWarInfo.userStatus == 1) {
        [self manageMatchWar];
    }else if (_matchWarInfo.userStatus == 2){
        [self exitMatchWar];
    }else if (_matchWarInfo.userStatus == 3){
        WS(weakSelf);
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:@"报名约战，您的手机号码会显示给发起者，便于联络。" cancelButtonTitle:@"取消" cancelBlock:^{
            
        } okButtonTitle:@"确定" okBlock:^{
            [weakSelf applyJoinMatch];
        }];
        [alertView show];
    }else if (_matchWarInfo.userStatus == -1){
        if ([[WYEngine shareInstance] needUserLogin:@"登录后才能报名约战"]) {
            return;
        }
    }
}
-(IBAction)sendAction:(id)sender{
    
    [self commitComment];
}

-(void)manageMatchWar{
    ManageMatchWarViewController *manageMatchVc = [[ManageMatchWarViewController alloc] init];
    manageMatchVc.matchWarInfo = _matchWarInfo;
    manageMatchVc.applys = self.matchWarInfo.applys;
    [self.navigationController pushViewController:manageMatchVc animated:YES];
}

-(void)growingTextViewResignFirstResponder{
    if ([_growingTextView isFirstResponder]) {
        [_growingTextView resignFirstResponder];
    }
    _growingTextView.text = nil;
}

#pragma mark - request
-(void)getCacheMatchWarInfo{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getMatchDetailsWithMatchId:_matchWarInfo.mId uid:[WYEngine shareInstance].uid tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            
            NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
            if ([object isKindOfClass:[NSDictionary class]]) {
                [weakSelf.matchWarInfo setMatchWarInfoByJsonDic:object];
            }
            [weakSelf refreshHeadViewShow];
            [weakSelf.matchInfoTableView reloadData];
            
            weakSelf.commentInfos = [[NSMutableArray alloc] init];
            for (WYMatchCommentInfo *commentInfo in weakSelf.matchWarInfo.comments) {
                [weakSelf.commentInfos addObject:commentInfo];
            }
        }
    }];
}
-(void)refreshMatchWarInfo{
    self.commentNextCursor = 1;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchDetailsWithMatchId:_matchWarInfo.mId uid:[WYEngine shareInstance].uid tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        if ([object isKindOfClass:[NSDictionary class]]) {
            [weakSelf.matchWarInfo setMatchWarInfoByJsonDic:object];
        }
        
        weakSelf.commentCanLoadMore = [[[jsonRet dictionaryObjectForKey:@"object"]  dictionaryObjectForKey:@"comments"] boolValueForKey:@"isLast"];
        if (weakSelf.commentCanLoadMore) {
            weakSelf.commentTableView.showsInfiniteScrolling = NO;
        }else{
            weakSelf.commentTableView.showsInfiniteScrolling = YES;
            //可以加载更多
            weakSelf.commentNextCursor ++;
        }
        
        weakSelf.commentInfos = [[NSMutableArray alloc] init];
        for (WYMatchCommentInfo *commentInfo in weakSelf.matchWarInfo.comments) {
            [weakSelf.commentInfos addObject:commentInfo];
        }
        [weakSelf refreshHeadViewShow];
        [weakSelf.matchInfoTableView reloadData];
        [weakSelf.commentTableView reloadData];
        
    }tag:tag];
}

-(void)getCacheCommentInfos{
//    WS(weakSelf);
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    [[WYEngine shareInstance] addGetCacheTag:tag];
//    [[WYEngine shareInstance] getMatchCommentInfoWithMatchId:_matchWarInfo.mId page:2 pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
//    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
//        if (jsonRet == nil) {
//            //...
//        }else{
//            
//            weakSelf.commentInfos = [[NSMutableArray alloc] init];
//            NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
//            for (NSDictionary *dic in object) {
//                if ([dic isKindOfClass:[NSDictionary class]]) {
//                    WYMatchCommentInfo *commentInfo = [[WYMatchCommentInfo alloc] init];
//                    [commentInfo setCommentInfoByDic:dic];
//                    [weakSelf.commentInfos addObject:commentInfo];
//                }
//            }
//            [weakSelf refreshHeadViewShow];
//            [weakSelf.commentTableView reloadData];
//        }
//    }];
}
-(void)refreshCommentInfos{
    
    [self.commentTableView reloadData];
    
//    self.commentNextCursor = 2;
//    WS(weakSelf);
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    [[WYEngine shareInstance] getMatchCommentInfoWithMatchId:_matchWarInfo.mId page:(int)self.commentNextCursor pageSize:DATA_LOAD_PAGESIZE_COUNT tag:tag];
//    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
//        if (!jsonRet || errorMsg) {
//            if (!errorMsg.length) {
//                errorMsg = @"请求失败";
//            }
//            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
//            return;
//        }
//        
//        weakSelf.commentInfos = [[NSMutableArray alloc] init];
//        NSArray *object = [[jsonRet dictionaryObjectForKey:@"object"] arrayObjectForKey:@"list"];
//        for (NSDictionary *dic in object) {
//            if ([dic isKindOfClass:[NSDictionary class]]) {
//                WYMatchCommentInfo *commentInfo = [[WYMatchCommentInfo alloc] init];
//                [commentInfo setCommentInfoByDic:dic];
//                [weakSelf.commentInfos addObject:commentInfo];
//            }
//        }
//        
//        weakSelf.commentCanLoadMore = [[jsonRet dictionaryObjectForKey:@"object"] boolValueForKey:@"isLast"];
//        if (weakSelf.commentCanLoadMore) {
//            weakSelf.commentTableView.showsInfiniteScrolling = NO;
//        }else{
//            weakSelf.commentTableView.showsInfiniteScrolling = YES;
//            //可以加载更多
//            weakSelf.commentNextCursor ++;
//        }
//        
//        [weakSelf refreshHeadViewShow];
//        [weakSelf.commentTableView reloadData];
//        
//    }tag:tag];
}

-(void)commitComment{
    if ([[WYEngine shareInstance] needUserLogin:@"登录后才能评论"]) {
        return;
    }
    NSString *content = _growingTextView.text;
    if (content.length == 0) {
        return;
    }
    self.sendButton.enabled = NO;
    __weak MatchWarDetailViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] commitCommentMatchWithMatchId:_matchWarInfo.mId uid:[WYEngine shareInstance].uid content:content tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        self.sendButton.enabled = YES;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"评论成功" At:weakSelf.view];
        
        NSDictionary *dic = [jsonRet objectForKey:@"object"];
        WYMatchCommentInfo *commentInfo = [[WYMatchCommentInfo alloc] init];
        [commentInfo setCommentInfoByDic:dic];
        [weakSelf.commentInfos insertObject:commentInfo atIndex:0];
        weakSelf.matchWarInfo.commentsCount ++;
        
        [weakSelf refreshHeadViewShow];
        [weakSelf.commentTableView reloadData];
        [weakSelf growingTextViewResignFirstResponder];
        
        [self.commentTableView setContentOffset:CGPointMake(0, 0 - self.commentTableView.contentInset.top) animated:YES];
        
    } tag:tag];
    
}

-(void)exitMatchWar{
    
    self.manageButton.enabled = NO;
    self.manageButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    __weak MatchWarDetailViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] cancelApplyMatchWarWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        self.manageButton.enabled = YES;
        self.manageButton.backgroundColor = SKIN_COLOR;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"已退出约战" At:weakSelf.view];
        weakSelf.matchWarInfo.userStatus = 3;
        weakSelf.matchWarInfo.applyCount --;
        [weakSelf addMendaciousApply:0];
        [weakSelf refreshHeadViewShow];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(matchWarDetailViewControllerWith:withMatchWarInfo:applyCountAdd:)]) {
            [self.delegate matchWarDetailViewControllerWith:self withMatchWarInfo:weakSelf.matchWarInfo applyCountAdd:NO];
        }
        
    } tag:tag];
}

-(void)applyJoinMatch{
    
    self.manageButton.enabled = NO;
    self.manageButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    __weak MatchWarDetailViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] applyMatchWarWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        self.manageButton.enabled = YES;
        self.manageButton.backgroundColor = SKIN_COLOR;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"报名成功" At:weakSelf.view];
        weakSelf.matchWarInfo.userStatus = 2;
        weakSelf.matchWarInfo.applyCount ++;
        [weakSelf addMendaciousApply:1];
        [weakSelf refreshHeadViewShow];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(matchWarDetailViewControllerWith:withMatchWarInfo:applyCountAdd:)]) {
            [self.delegate matchWarDetailViewControllerWith:self withMatchWarInfo:weakSelf.matchWarInfo applyCountAdd:YES];
        }
        
    } tag:tag];
}

#pragma mark - mendaciousLiked
- (void)addMendaciousApply:(int)type
{
    WYMatchApplyInfo *matchApplyInfo = [[WYMatchApplyInfo alloc] init];
    WYUserInfo *tmpUser = [[WYEngine shareInstance] userInfo];
    
    if (type == 1) {
        matchApplyInfo.userId = tmpUser.uid;
        matchApplyInfo.nickName = tmpUser.nickName;
        matchApplyInfo.userAvatar = tmpUser.avatar;
        matchApplyInfo.telephone = tmpUser.telephone;
        [_matchWarInfo.applys addObject:matchApplyInfo];
    }else if (type == 0){
        for (WYMatchApplyInfo *info in _matchWarInfo.applys) {
            if ([info.userId isEqualToString:tmpUser.uid]) {
                [_matchWarInfo.applys removeObject:info];
                break;
            }
        }
    }
    
    [self.applyPeopleGridView reloadData];
}

#pragma mark - dataModule
-(NSDictionary *)tableDataModule{
    NSDictionary *moduleDict;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    [tmpMutDict setObject:[self matchBasicInfosDict] forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
    moduleDict = tmpMutDict;
    return moduleDict;
}
-(NSDictionary *)matchBasicInfosDict{
    NSDictionary *minfoRows =  nil;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    NSString *intro = _matchWarInfo.itemName;
    NSDictionary *dict00 = @{@"titleLabel": @"竞技项目",
                                 @"icon": @"match_publish_game_icon",
                                 @"intro": intro!=nil?intro:@"",
                                 };
    intro = _matchWarInfo.itemServer;
    NSDictionary *dict01 = @{@"titleLabel": @"服务器",
                             @"icon": @"matchWar_fuwu_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = [WYUIUtils dateDiscriptionFromDate:_matchWarInfo.startTime];
    NSDictionary *dict02 = @{@"titleLabel": @"时间",
                             @"icon": @"match_detail_time_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = nil;
    if (_matchWarInfo.way == 1) {
        intro = @"线上";
    }else if (_matchWarInfo.way ==2){
        intro = [NSString stringWithFormat:@"线下/%@",_matchWarInfo.netbarName];
    }
    NSDictionary *dict03 = @{@"titleLabel": @"地点",
                             @"icon": @"match_publish_address_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = _matchWarInfo.remark;
    NSArray *remarkArray = [_matchWarInfo.remark componentsSeparatedByString:@" "];
    NSMutableString * remark = [[NSMutableString alloc] init];
    for (NSString* num in remarkArray) {
        if (remark.length > 0) {
            [remark appendString:@"\n"];
        }
        [remark appendString:num.description];
    }
    if (remark.length > 0) {
        intro = remark;
    }
    
    NSDictionary *dict04 = @{@"titleLabel": @"联系方式",
                             @"icon": @"match_publish_contact_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = _matchWarInfo.spoils;
    NSDictionary *dict05 = @{@"titleLabel": @"介绍",
                             @"icon": @"match_publish_intro_icon",
                             @"intro": intro!=nil?intro:@"",
                             };
    [tmpMutDict setObject:dict00 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict01 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict02 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict03 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict04 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict05 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    
    minfoRows = tmpMutDict;
    return minfoRows;
}

-(NSInteger)newSections{
    
    return [[self tableDataModule] allKeys].count;
}
-(NSInteger)newSectionPolicy:(NSInteger)section{
    
    NSDictionary *rowContentDic = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)section]];
    return [rowContentDic count];
}
-(CGFloat)heightWithRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    NSString *intro = [rowDicts objectForKey:@"intro"];
    UIFont *font = SKIN_FONT_FROMNAME(14);
    CGSize textSize = [WYCommonUtils sizeWithText:intro font:font width:SCREEN_WIDTH-114];
    return textSize.height + 23;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.commentTableView) {
        return 1;
    }
    return [self newSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.commentTableView) {
        return self.commentInfos.count;
    }
    return [self newSectionPolicy:section];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        WYMatchCommentInfo *commentInfo = _commentInfos[indexPath.row];
        return [MatchCommentViewCell heightForCommentInfo:commentInfo];
    }
    return [self heightWithRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        static NSString *CellIdentifier = @"MatchCommentViewCell";
        MatchCommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
            cell = [cells objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        WYMatchCommentInfo *commentInfo = _commentInfos[indexPath.row];
        cell.commentInfo = commentInfo;
        return cell;
    }
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:0];
        cell.topLineImage.hidden = YES;
    }else if (indexPath.row == [self newSectionPolicy:indexPath.section]-1){
        [cell setLineImageViewWithType:2];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = NO;
    cell.rightLabel.font = SKIN_FONT_FROMNAME(14);
    cell.rightLabel.textColor = SKIN_TEXT_COLOR4;
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = YES;
    
    CGFloat rowHeight = [self heightWithRowAtIndexPath:indexPath];
    CGRect frame = cell.avatarImageView.frame;
    frame.origin.y = (rowHeight-12)/2;
    frame.size.width = 12;
    frame.size.height = 12;
    cell.avatarImageView.frame = frame;
    
    frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 7;
    cell.titleLabel.frame = frame;
    
    //    cell.rightLabel.backgroundColor = [UIColor lightGrayColor];
    cell.rightLabel.autoresizingMask = UIViewAutoresizingNone;
    cell.rightLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
    cell.rightLabel.numberOfLines = 0;
    frame = cell.rightLabel.frame;
    frame.origin.x = 102;
    frame.size.width = SCREEN_WIDTH - frame.origin.x - 12;
    cell.rightLabel.frame = frame;
    cell.rightLabel.textAlignment = NSTextAlignmentRight;
    
    if (indexPath.row == 3 && _matchWarInfo.way == 2 && _matchWarInfo.netbarId.length > 0) {
        cell.indicatorImage.hidden = NO;
        frame = cell.rightLabel.frame;
        frame.origin.x = 102;
        frame.size.width = SCREEN_WIDTH - frame.origin.x - 28;
        cell.rightLabel.frame = frame;
    }
    
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    
    cell.titleLabel.text = [rowDicts objectForKey:@"titleLabel"];
    cell.avatarImageView.image = [UIImage imageNamed:[rowDicts objectForKey:@"icon"]];
    
    if (!cell.rightLabel.hidden) {
        NSString *intro = [rowDicts objectForKey:@"intro"];
        cell.rightLabel.text = intro;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.commentTableView) {
        
    }else{
        if (indexPath.row == 3) {
            if (_matchWarInfo.way == 2 && _matchWarInfo.netbarId.length > 0) {
                WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
                netbarInfo.nid = _matchWarInfo.netbarId;
                netbarInfo.netbarName = _matchWarInfo.netbarName;
                NetbarDetailViewController *netbarDetailVc = [[NetbarDetailViewController alloc] init];
                netbarDetailVc.netbarInfo = netbarInfo;
                [self.navigationController pushViewController:netbarDetailVc animated:YES];
            }
        }else if (indexPath.row == 4){
            
            
        }
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

- (void)commentLongPressAction:(UILongPressGestureRecognizer*)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPressGesture locationInView:_matchInfoTableView];
        NSIndexPath *indexPath = [_matchInfoTableView indexPathForRowAtPoint:point];
        SettingViewCell *cell = (SettingViewCell*)[_matchInfoTableView cellForRowAtIndexPath:indexPath];
        
        if (indexPath.row != 4) {
            return;
        }
        if (_matchWarInfo.remark.length == 0) {
            return;
        }
        
        UIMenuController * menuCtl = ((AppDelegate *)[UIApplication sharedApplication].delegate).appMenu;
        NSMutableArray *popMenuItems = nil;
        
        NSArray *remarkArray = [_matchWarInfo.remark componentsSeparatedByString:@" "];
        if (remarkArray.count > 0) {
            popMenuItems = [NSMutableArray array];
            for (int i = 0; i < remarkArray.count; i++) {
                NSString *remarkStr = [remarkArray objectAtIndex:i];
                NSArray *contactArray = [remarkStr componentsSeparatedByString:@":"];
                SEL action = nil;
                if (i == 0)
                    action = @selector(copyContactTextAction1);
                else if (i == 1)
                    action = @selector(copyContactTextAction2);
                else if (i == 2)
                    action = @selector(copyContactTextAction3);
                
                if (contactArray.count > 0) {
                    [popMenuItems addObject:[[UIMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"复制%@",[contactArray objectAtIndex:0]] action:action]];
                }
            }
        }
        
        [menuCtl setMenuVisible:NO];
        [menuCtl setMenuItems:popMenuItems];
        [menuCtl setArrowDirection:UIMenuControllerArrowDown];
        
        CGRect showRect = cell.frame;
        showRect.origin.x += 100;
        showRect.origin.y += 20;
        [menuCtl setTargetRect:showRect inView:self.matchInfoTableView];
        [menuCtl setMenuVisible:YES animated:YES];
    }
}

#pragma mark -HPGrowingTextViewDelegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView{
    
    [self refreshCommentBottomView];
    return YES;
}
- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    
    [self refreshCommentBottomView];
    _textRange = growingTextView.selectedRange;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = _commentBottomContainerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    _commentBottomContainerView.frame = r;
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    _textRange = growingTextView.selectedRange;
    
    [self refreshCommentBottomView];
    
    if ([WYCommonUtils getHanziTextNum:growingTextView.text] > _maxReplyTextLength && growingTextView.internalTextView.markedTextRange == nil) {
        growingTextView.text = [WYCommonUtils getHanziTextWithText:growingTextView.text maxLength:_maxReplyTextLength];
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"评论文字不可以超过%d个字符,已截断", _maxReplyTextLength] cancelButtonTitle:@"确定"];
        
        [alertView show];
    }
}


- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([WYCommonUtils getHanziTextNum:growingTextView.text] > _maxReplyTextLength) {
        
        WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"评论文字不可以超过%d个字符", _maxReplyTextLength] cancelButtonTitle:@"确定"];
        [alertView show];
        
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [self sendAction:nil];
        return NO;
        
    }
    return YES;
}

- (void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView{
    _textRange = growingTextView.selectedRange;
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    [self sendAction:nil];
    return YES;
}
-(void)refreshCommentBottomView{
    if (_growingTextView.text.length > 0) {
        self.placeHolderLabel.hidden = YES;
        [_sendButton setBackgroundColor:SKIN_COLOR];
        _sendButton.enabled = YES;
    } else {
        self.placeHolderLabel.hidden = NO;
        [_sendButton setBackgroundColor:UIColorToRGB(0xe4e4e4)];
        _sendButton.enabled = NO;
    }
}

#pragma mark - NSNotification
-(void) keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect toolbarFrame = _commentBottomContainerView.frame;
    
//    CGRect tableViewFrame = _commentTableView.frame;
//    tableViewFrame.size.height = self.view.bounds.size.height - keyboardBounds.size.height - toolbarFrame.size.height;
//    _commentTableView.frame = tableViewFrame;
//    
//    CGPoint offset = _commentTableView.contentOffset;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    toolbarFrame.origin.y = self.view.bounds.size.height - keyboardBounds.size.height - toolbarFrame.size.height;
    _commentBottomContainerView.frame = toolbarFrame;
    
//    if (_commentTableView.contentSize.height > _commentTableView.frame.size.height) {
//        offset = CGPointMake(0, _commentTableView.contentSize.height -  _tableView.frame.size.height);
//        _commentTableView.contentOffset = offset;
//    }
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    
    CGRect toolbarFrame = _commentBottomContainerView.frame;
    
//    CGRect tableViewFrame = _commentTableView.frame;
//    tableViewFrame.size.height = self.view.bounds.size.height - toolbarFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    toolbarFrame.origin.y = self.view.bounds.size.height - toolbarFrame.size.height;
    _commentBottomContainerView.frame = toolbarFrame;
    
//    _commentTableView.frame = tableViewFrame;
    
    // commit animations
    [UIView commitAnimations];
}

#pragma mark GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _matchWarInfo.applys.count;
    
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return CGSizeMake(GRID_IMAGE_SIZE, GRID_IMAGE_SIZE);
}


- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIImageView* imageview = [[UIImageView alloc] init];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.clipsToBounds = YES;
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = GRID_IMAGE_SIZE/2;
        cell.contentView = imageview;
    }
    
    UIImageView* imageiew = (UIImageView*)cell.contentView;
    id info = [self.matchWarInfo.applys objectAtIndex:index];
    if ([info isKindOfClass:[WYMatchApplyInfo class]]) {
        WYMatchApplyInfo* applyInfo = (WYMatchApplyInfo*)info;
        [imageiew sd_setImageWithURL:applyInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon_small"]];
    }else{
        imageiew.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
    }
    
    return cell;
}
#pragma mark GMGridViewActionDelegate
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
//    NSLog(@"Did tap at index %d", position);
}

#pragma mark - scrollViewDelegat
static CGFloat beginOffsetY = 63*2;
static CGFloat BKImageHeight = 320;
static CGFloat beginImageH = 0;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint offset = scrollView.contentOffset;
//    WYLog(@"offset = %f",offset.y);
    CGRect frame = CGRectMake(0, -63, SCREEN_WIDTH, BKImageHeight);
    CGFloat factor;
    
    //pull animation
    if (offset.y < 0) {
        factor = 0.5;
    } else {
        factor = 1;
    }
    
    float topOffset = -63;
    frame.origin.y = topOffset-offset.y*factor;
    if (frame.origin.y > 0) {
        frame.origin.y =  topOffset/factor - offset.y;
    }
    
    // zoom image
    if (offset.y <= -beginOffsetY) {
        factor = (ABS(offset.y+beginOffsetY)+BKImageHeight) * SCREEN_WIDTH/BKImageHeight;
        frame = CGRectMake(-(factor-SCREEN_WIDTH)/2, beginImageH, factor, BKImageHeight+ABS(offset.y+beginOffsetY));
    }
//     WYLog(@"frame = %@",NSStringFromCGRect(frame));
    _bkImageView.frame = frame;
    
    [self setTitleNavBarAlpha:scrollView point:offset];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([_growingTextView isFirstResponder]) {
        [_growingTextView resignFirstResponder];
    }
}

- (void)setTitleNavBarAlpha:(UIScrollView *)scrollView point:(CGPoint)offset{
    CGFloat tmpHeight = self.matchTitleLabel.frame.origin.y-self.titleNavBar.frame.size.height;
    int type = 0;
    if (offset.y <= 0) {
        type = 0;
        [self.titleNavBar setAlpha:0.0];
    }else if (offset.y >= tmpHeight){
        type = 1;
        [self.titleNavBar setAlpha:0.6];
    }else{
        type = 0;
        CGFloat alpha = fabs((offset.y)/tmpHeight);
        if (alpha >= 0.6) {
            alpha = 0.6;
        }
        [self.titleNavBar setAlpha:alpha];
    }
    [self refreshTitleBarUI:type];
}

-(void)refreshTitleBarUI:(int)type{
    if (type == 0) {
        self.toobarTitleLabel.hidden = YES;
    }else if (type == 1){
        self.toobarTitleLabel.text = _matchWarInfo.title;
        self.toobarTitleLabel.hidden = NO;
    }
}
- (UIStatusBarStyle)preferredStatusBarStyle NS_AVAILABLE_IOS(7_0){
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden NS_AVAILABLE_IOS(7_0){
    return NO;
}

#pragma mark - 复制联系方式
-(void)copyContactTextAction:(NSInteger)index{
    NSString *copyText = @"";
    NSArray *remarkArray = [_matchWarInfo.remark componentsSeparatedByString:@" "];
    if (remarkArray.count > index) {
        NSString *remarkStr = [remarkArray objectAtIndex:index];
        NSArray *contactArray = [remarkStr componentsSeparatedByString:@":"];
        if (contactArray.count > 1) {
            copyText = [[contactArray objectAtIndex:1] description];
        }
    }
    if (copyText.length == 0) {
        return;
    }
    UIPasteboard *copyBoard = [UIPasteboard generalPasteboard];
    copyBoard.string = copyText;
    [copyBoard setPersistent:YES];
}

-(void)copyContactTextAction1{
    [self copyContactTextAction:0];
}
- (void)copyContactTextAction2{
    [self copyContactTextAction:1];
}
- (void)copyContactTextAction3{
    [self copyContactTextAction:2];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    UIMenuController * menuCtl = ((AppDelegate *)[UIApplication sharedApplication].delegate).appMenu;
    BOOL bSameMenuInst = menuCtl == sender;
    
    if (action == @selector(copyContactTextAction3) || action == @selector(copyContactTextAction2) || action == @selector(copyContactTextAction1))
    {
        if (bSameMenuInst) {
            return YES;
        }
    }
    return NO;
}

@end
