//
//  PublishMatchWarViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PublishMatchWarViewController.h"
#import "SettingViewCell.h"
#import "SelectGameViewController.h"
#import "WYActionSheet.h"
#import "WYNetbarInfo.h"
#import "NetbarSearchViewController.h"
#import "WYInputTextViewController.h"
#import "ContactWayViewController.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+WebCache.h"
#import "GMGridViewLayoutStrategies.h"
#import "GMGridViewCell+Extended.h"
#import "InviteFriendsViewController.h"
#import "PbUserInfo.h"
#import <AddressBook/AddressBook.h>
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYMatchWarInfo.h"
#import "PublishSucceedViewController.h"

#define Title_maxTextLength 18

#define GRID_IMAGE_SIZE       31
#define item_spacing          7

@interface PublishMatchWarViewController ()<UITableViewDelegate,UITableViewDataSource,SelectGameViewControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate,NetbarSearchViewControllerDelegate,WYInputTextViewControllerDelegate,ContactWayViewControllerDelegate,GMGridViewDataSource, GMGridViewActionDelegate>
{
    NSString *_matchGameName;
    NSDictionary *_matchGameDic;
    
//    NSString *_matchTitleName;
    
    NSString *_matchDateString;
    NSDate *_matchDate;
    
    int _peopleNumber;
    NSString *_matchPeopleNumber;
    
    NSString *_matchIntro;
    
    int _matchWay;//1线上2线下
    NSString *_matchAddress;
    WYNetbarInfo *_netbarInfo;
    
    //联系方式
    NSDictionary *_matchContactDic;
    NSString *_matchContactWay;
    NSString *_matchContactWayToServer;
    
    ABAddressBookRef _addressBook;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *headView;
@property (nonatomic, strong) IBOutlet UILabel *matchGameNameTipLabel;
@property (nonatomic, strong) IBOutlet UILabel *matchGameNameLabel;

@property (nonatomic, strong) IBOutlet UIView *titleContainerView;
@property (nonatomic, strong) IBOutlet UILabel *matchTitleTipLabel;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@property (nonatomic, strong) IBOutlet UIView *footerView;
@property (nonatomic, strong) IBOutlet UIView *matchContactView;
@property (nonatomic, strong) IBOutlet UILabel *matchContactTipLabel;
@property (nonatomic, strong) IBOutlet TTTAttributedLabel *matchContactLabel;

@property (nonatomic, strong) NSMutableArray *invitePeopleData;
@property (nonatomic, strong) IBOutlet UIView *inviteContainerView;
@property (nonatomic, strong) IBOutlet UILabel *inviteTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *inviteDeleteButton;
@property (nonatomic, strong) IBOutlet GMGridView *invitePeopleGridView;

@property (nonatomic, strong) IBOutlet UIView *bottomContainerView;
@property (nonatomic, strong) IBOutlet UIButton *bottomButton;

@property (nonatomic, strong) NSArray *peopleNumbers;
@property (nonatomic, weak) UIView *Pickermask;
@property (nonatomic, strong) IBOutlet UIView *dateChooseView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

-(IBAction)matchGameAction:(id)sender;
-(IBAction)matchContactAction:(id)sender;
-(IBAction)addPeopleAction:(id)sender;
-(IBAction)deletePeopleAction:(id)sender;
- (IBAction)datePickerValueChanged:(id)sender;
-(IBAction)submitAction:(id)sender;
@end

@implementation PublishMatchWarViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_addressBook) {
        CFRelease(_addressBook);
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    CFErrorRef myError = NULL;
    _addressBook = ABAddressBookCreateWithOptions(NULL, &myError);
    
    self.bottomButton.enabled = NO;
    _matchContactDic = [[NSDictionary alloc] init];
    _invitePeopleData = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 100; i ++) {
//        [_invitePeopleData addObject:@{@"phone":@"13803833466"}];
//    }
    
    //GridView
    _invitePeopleGridView.backgroundColor = [UIColor clearColor];
    _invitePeopleGridView.style = GMGridViewStyleSwap;
    _invitePeopleGridView.itemSpacing = item_spacing;
    _invitePeopleGridView.minEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
    _invitePeopleGridView.centerGrid = NO;
    _invitePeopleGridView.layoutStrategy = [GMGridViewLayoutStrategyFactory strategyFromType:GMGridViewLayoutVertical];
    _invitePeopleGridView.actionDelegate = self;
    _invitePeopleGridView.showsHorizontalScrollIndicator = NO;
    _invitePeopleGridView.showsVerticalScrollIndicator = NO;
    _invitePeopleGridView.dataSource = self;
    _invitePeopleGridView.enableEditOnLongPress = YES;
    _invitePeopleGridView.disableEditOnEmptySpaceTap = YES;
    
    
    _peopleNumbers = @[@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12),@(13),@(14),@(15),@(16),@(17),@(18),@(19),@(20)];
    
    [self refreshHeadViewShowUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"约战发布"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)isCanPublish{
    
    if (_matchGameName.length > 0 && self.textField.text.length > 0 && _matchDateString.length > 0 && _matchWay >= 1 && _matchPeopleNumber.length > 0 && _matchContactWay.length > 0) {
        return YES;
    }
    return NO;
}

-(void)publishMatchWar{
    
    NSString *itemId = [_matchGameDic stringObjectForKey:@"item_id"];
    NSString *server = [_matchGameDic stringObjectForKey:@"game_server"];
    
    NSMutableArray *invitedPhones = nil;
    if (_invitePeopleData.count > 0) {
        invitedPhones = [NSMutableArray array];
        for (PbUserInfo *pbUserInfo in _invitePeopleData) {
            if (pbUserInfo.phoneNUm.length > 0) {
                [invitedPhones addObject:pbUserInfo.phoneNUm];
            }
        }
    }
    
    [WYProgressHUD AlertLoading:@"约战发布中..." At:self.view];
    __weak PublishMatchWarViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] matchPublishWithUid:[WYEngine shareInstance].uid title:_textField.text itemId:itemId server:server way:_matchWay netbarId:_netbarInfo.nid netbarName:_netbarInfo.netbarName beginTime:_matchDateString num:_peopleNumber contactWay:_matchContactWayToServer intro:_matchIntro invitedPhones:invitedPhones tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"发布失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
//            return;
        }
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        WYMatchWarInfo *matchInfo = [[WYMatchWarInfo alloc] init];
        [matchInfo setMatchWarInfoByJsonDic:object];
        matchInfo.mId = [[object objectForKey:@"id"] description];
        if (_netbarInfo.nid.length > 0) {
            matchInfo.netbarId = _netbarInfo.nid;
        }
        [weakSelf goToSucceedViewController:matchInfo];
        
    }tag:tag];
}

-(void)goToSucceedViewController:(WYMatchWarInfo*)matchInfo{
    PublishSucceedViewController *succeedVc = [[PublishSucceedViewController alloc] init];
    succeedVc.matchWarInfo = matchInfo;
    
    UINavigationController *navVc = [self navigationController];
    //去掉衍生出来的部分viewController
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (id vc in navVc.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"PublishMatchWarViewController"]) {
            continue;
        }
        [viewControllers addObject:vc];
    }
    [viewControllers addObject:succeedVc];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

#pragma mark - custom
-(void)refreshHeadViewShowUI{
    
    self.matchGameNameTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchGameNameTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchGameNameLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchGameNameLabel.textColor = UIColorToRGB(0xc7c7c7);
    self.matchGameNameLabel.text = @"去选择";
    if (_matchGameName.length > 0) {
        self.matchGameNameLabel.textColor = UIColorToRGB(0x666666);
        self.matchGameNameLabel.text = _matchGameName;
    }
    
    self.matchTitleTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchTitleTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.textField.font = SKIN_FONT_FROMNAME(14);
    self.textField.textColor = UIColorToRGB(0x666666);
    
    self.matchContactTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchContactTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchContactLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchContactLabel.textColor = UIColorToRGB(0xc7c7c7);
    NSString *matchContactLabel = @"请填写(必填)";
    if (_matchContactWay.length > 0) {
        self.matchContactLabel.textColor = UIColorToRGB(0x666666);
        matchContactLabel = _matchContactWay;
    }
    self.matchContactLabel.text = matchContactLabel;
    
    self.matchContactLabel.lineHeightMultiple = 0.8;
    CGSize textSize = [WYCommonUtils sizeWithText:matchContactLabel font:self.matchContactLabel.font width:SCREEN_WIDTH-129];
    CGRect frame = self.matchContactView.frame;
    frame.size.height = textSize.height + 23;
    self.matchContactView.frame = frame;
    
    
    self.inviteTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.inviteTipLabel.textColor = SKIN_TEXT_COLOR1;
    
    //时间
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *compsNow = [calender components:unitFlags fromDate:[NSDate date]];
    _datePicker.minimumDate = [calender dateFromComponents:compsNow];
    
    compsNow.day += 7;
    _datePicker.maximumDate = [calender dateFromComponents:compsNow];
    
    //邀请人GridView
    CGFloat inviteContainerViewHeight = 85;
    self.invitePeopleGridView.hidden = YES;
    if (self.invitePeopleData.count > 0) {
        self.invitePeopleGridView.hidden = NO;
        int peopleCount = (int)self.invitePeopleData.count;
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
        
        CGRect frame1 = self.invitePeopleGridView.frame;
        frame1.size.width = (GRID_IMAGE_SIZE+item_spacing)*peopleCount;
        if (frame1.size.width > (SCREEN_WIDTH - 12*2)) {
            frame1.size.width = (SCREEN_WIDTH - 12*2)+7;
        }
        frame1.size.height = (GRID_IMAGE_SIZE+item_spacing)*rowCount-3;
        if (frame1.size.height < GRID_IMAGE_SIZE) {
            frame1.size.height = GRID_IMAGE_SIZE;
        }
        self.invitePeopleGridView.frame = frame1;
        
        inviteContainerViewHeight = self.invitePeopleGridView.frame.origin.y + self.invitePeopleGridView.frame.size.height +10;
    }
    [self.invitePeopleGridView reloadData];
    
    //邀请view
    frame = self.inviteContainerView.frame;
    frame.origin.y = self.matchContactView.frame.origin.y + self.matchContactView.frame.size.height + 10;
    frame.size.height = inviteContainerViewHeight;
    self.inviteContainerView.frame = frame;
    
    
    frame = self.footerView.frame;
    frame.size.height = self.inviteContainerView.frame.origin.y + self.inviteContainerView.frame.size.height;
    self.footerView.frame = frame;
    
    
    self.tableView.tableHeaderView = self.headView;
    self.tableView.tableFooterView = self.footerView;
    [self.tableView reloadData];
    
    [self refreshBottomViewShow];
}

-(void)refreshBottomViewShow{
    
    self.bottomButton.titleLabel.font = SKIN_FONT_FROMNAME(15);
    self.bottomButton.layer.cornerRadius = 4;
    self.bottomButton.layer.masksToBounds = YES;
    
    self.bottomButton.enabled = [self isCanPublish];
    if (self.bottomButton.enabled) {
        self.bottomButton.backgroundColor = SKIN_COLOR;
    }else{
        self.bottomButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    }
}
-(void)refreshInviteDeleteButton{
    if (_invitePeopleGridView.editing) {
        [_inviteDeleteButton setImage:[UIImage imageNamed:@"match_publish_check_icon"] forState:UIControlStateNormal];
    }else{
        [_inviteDeleteButton setImage:[UIImage imageNamed:@"match_publish_delete_icon"] forState:UIControlStateNormal];
    }
}

//人数选择
-(void)peopleNumberChoose{
    
    [self pickerComfirm];
    UIView *Pickermask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    Pickermask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [[UIApplication sharedApplication].keyWindow addSubview:Pickermask];
    self.Pickermask = Pickermask;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePicker)];
    [Pickermask addGestureRecognizer:tap];
    
    UIPickerView *countPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-230, SCREEN_WIDTH, 200)];
    countPicker.backgroundColor = [UIColor whiteColor];
    countPicker.layer.cornerRadius = 5;
    countPicker.delegate = self;
    countPicker.dataSource = self;
    [Pickermask addSubview:countPicker];
    
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
    confirmBtn.backgroundColor = [UIColor whiteColor];
    confirmBtn.layer.cornerRadius = 5;
    [confirmBtn addTarget:self action:@selector(pickerComfirm) forControlEvents:UIControlEventTouchUpInside];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [Pickermask addSubview:confirmBtn];
    
}
-(void)pickerComfirm
{
    if (_matchPeopleNumber.length == 0) {
        _peopleNumber = [_peopleNumbers[0] intValue];
        _matchPeopleNumber = [NSString stringWithFormat:@"%@个",[_peopleNumbers objectAtIndex:0]];
    }
    [self.tableView reloadData];
    [self.Pickermask removeFromSuperview];
}
-(void)closePicker
{
    [self.Pickermask removeFromSuperview];
}

//时间选择
-(void)showDatePicker{
    
    [self datePickerValueChanged:nil];
    UIView *Pickermask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    Pickermask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    [[UIApplication sharedApplication].keyWindow addSubview:Pickermask];
    self.Pickermask = Pickermask;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePicker)];
    [Pickermask addGestureRecognizer:tap];
    
    CGRect rect = _dateChooseView.frame;
    rect.origin.y = self.view.frame.size.height - _dateChooseView.frame.size.height;
    rect.size.width = Pickermask.frame.size.width;
    _dateChooseView.frame = rect;
    [Pickermask addSubview:_dateChooseView];
    
}

-(void)addressChoose{
    __weak PublishMatchWarViewController *weakSelf = self;
    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        if (buttonIndex == 0) {
            _matchWay = 1;
//            _matchAddress = @"线上";
            [weakSelf.tableView reloadData];
        }else if (buttonIndex == 1){
            NetbarSearchViewController *netbarSearchVc = [[NetbarSearchViewController alloc] init];
            netbarSearchVc.delegate = self;
            netbarSearchVc.isChoose = YES;
            [weakSelf.navigationController pushViewController:netbarSearchVc animated:YES];
        }
        
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"线上约战", @"线下约战", nil];
    [sheet showInView:self.view];
}

-(void)setMatchIntro{
    WYInputTextViewController *vc = [[WYInputTextViewController alloc] init];
    vc.oldText = _matchIntro;
    vc.titleText = @"介绍";
    vc.placeHolder = @"请简短介绍下您的约战规则、奖品...";
    vc.maxTextLength = 40;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - IBAction
-(IBAction)matchGameAction:(id)sender{
    SelectGameViewController *vc = [[SelectGameViewController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)matchContactAction:(id)sender{
    ContactWayViewController *contactWayVc = [[ContactWayViewController alloc] init];
    contactWayVc.contactDic = _matchContactDic;
    contactWayVc.delegate = self;
    [self.navigationController pushViewController:contactWayVc animated:YES];
}

-(IBAction)addPeopleAction:(id)sender{
    WS(weakSelf);
    InviteFriendsViewController *inviteFriendsVc = [[InviteFriendsViewController alloc] init];
    inviteFriendsVc.slePbUserInfos = self.invitePeopleData;
    inviteFriendsVc.sendInviteFriendsCallBack = ^(NSArray *array){
        
        weakSelf.invitePeopleData = [NSMutableArray arrayWithArray:array];
//        [weakSelf.invitePeopleGridView reloadData];
        [weakSelf refreshHeadViewShowUI];
    };
    [self.navigationController pushViewController:inviteFriendsVc animated:YES];
}

-(IBAction)deletePeopleAction:(id)sender{
    
    _invitePeopleGridView.editing = !_invitePeopleGridView.editing;
    [self refreshInviteDeleteButton];
}

-(IBAction)submitAction:(id)sender{
    [self publishMatchWar];
}

- (IBAction)datePickerValueChanged:(id)sender{
    _matchDate = _datePicker.date;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    _matchDateString = [dateFormatter stringFromDate:_matchDate];
    
//    _matchDateString = [WYUIUtils dateDiscriptionFromDate:_matchDate];
    [self.tableView reloadData];
}

#pragma mark - dataModule
-(NSDictionary *)tableDataModule{
    NSDictionary *moduleDict;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    [tmpMutDict setObject:[self matchBasicInfosDict] forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
//    [tmpMutDict setObject:[self matchBasicInfosDict] forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
//    [tmpMutDict setObject:[self matchContactDict] forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
    
    moduleDict = tmpMutDict;
    return moduleDict;
}
-(NSDictionary *)matchGameDict{
    NSDictionary *minfoRows =  nil;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
//    NSString *intro = nil;
//    NSDictionary *dict01 = @{@"titleLabel": @"竞技项目",
//                             @"intro": intro!=nil?intro:@"",
//                             };
//    [tmpMutDict setObject:dict01 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    
    minfoRows = tmpMutDict;
    return minfoRows;
}
-(NSDictionary *)matchBasicInfosDict{
    NSDictionary *minfoRows =  nil;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
//    NSString *intro = _matchTitleName;
//    NSDictionary *dict00 = @{@"titleLabel": @"约战标题",
//                             @"icon": @"match_publish_title_icon",
//                             @"intro": intro!=nil?intro:@"为自己的约战描述一下吧",
//                             @"textcolor": intro!=nil?@(1):@(0),
//                             };
    NSString *intro = _matchDateString;
    NSDictionary *dict01 = @{@"titleLabel": @"时间",
                             @"icon": @"match_detail_time_icon",
                             @"intro": intro!=nil?intro:@"请设置",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
    intro = nil;
    if (_matchWay == 1) {
        intro = @"线上";
    }else if (_matchWay ==2){
        intro = [NSString stringWithFormat:@"线下/%@",_netbarInfo.netbarName];
    }
    NSDictionary *dict02 = @{@"titleLabel": @"地点",
                             @"icon": @"book_wangba",
                             @"intro": intro!=nil?intro:@"请设置",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
    intro = _matchPeopleNumber;
    NSDictionary *dict03 = @{@"titleLabel": @"人数",
                             @"icon": @"match_publish_people_icon",
                             @"intro": intro!=nil?intro:@"请设置",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
    intro = nil;
    if (_matchIntro.length > 0) {
        intro = _matchIntro;
    }
    NSDictionary *dict04 = @{@"titleLabel": @"介绍",
                             @"icon": @"match_publish_intro_icon",
                             @"intro": intro!=nil?intro:@"请介绍",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
//    [tmpMutDict setObject:dict00 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict01 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict02 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict03 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:dict04 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
    
    minfoRows = tmpMutDict;
    return minfoRows;
}
-(NSDictionary *)matchContactDict{
    NSDictionary *minfoRows =  nil;
    
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    
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
    CGSize textSize = [WYCommonUtils sizeWithText:intro font:font width:SCREEN_WIDTH-130];
    return textSize.height + 23;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self newSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self newSectionPolicy:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    return 10;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
//    view.backgroundColor = [UIColor clearColor];
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightWithRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:1];
    }else if (indexPath.row == [self newSectionPolicy:indexPath.section]-1){
        [cell setLineImageViewWithType:-1];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = NO;
    cell.rightLabel.font = SKIN_FONT_FROMNAME(14);
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = NO;
    
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
    frame.size.width = SCREEN_WIDTH - frame.origin.x - 28;
    cell.rightLabel.frame = frame;
    cell.rightLabel.textAlignment = NSTextAlignmentRight;
    
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            cell.indicatorImage.hidden = YES;
//            frame = cell.rightLabel.frame;
//            frame.origin.x = 102;
//            frame.size.width = SCREEN_WIDTH - frame.origin.x - 12;
//            cell.rightLabel.frame = frame;
//            cell.rightLabel.textAlignment = NSTextAlignmentLeft;
//        }
//    }
    
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    
    cell.titleLabel.text = [rowDicts objectForKey:@"titleLabel"];
    cell.avatarImageView.image = [UIImage imageNamed:[rowDicts objectForKey:@"icon"]];
    
    if (!cell.rightLabel.hidden) {
        NSString *intro = [rowDicts objectForKey:@"intro"];
        cell.rightLabel.text = intro;
        
        int textcolor = [[rowDicts objectForKey:@"textcolor"] intValue];
        if (textcolor == 1){
            cell.rightLabel.textColor = UIColorToRGB(0x666666);
        }else{
            cell.rightLabel.textColor = UIColorToRGB(0xc7c7c7);
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    [self.textField resignFirstResponder];
    
//    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
//    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            
//        }else
        if (indexPath.row == 0){
            [self showDatePicker];
        }else if (indexPath.row == 1){
            [self addressChoose];
        }else if (indexPath.row == 2){
            [self peopleNumberChoose];
        }else if (indexPath.row == 3){
            [self setMatchIntro];
        }
    }
}

#pragma mark GMGridViewDataSource
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return _invitePeopleData.count;
    
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
        cell.deleteButtonIcon = [UIImage imageNamed:@"match_publish_remove_icon"];
        cell.deleteButtonOffset = CGPointMake(12, -12);
        UIImageView* imageview = [[UIImageView alloc] init];
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        imageview.clipsToBounds = YES;
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = GRID_IMAGE_SIZE/2;
        cell.contentView = imageview;
    }
    
    UIImageView* imageiew = (UIImageView*)cell.contentView;
    id info = [self.invitePeopleData objectAtIndex:index];
    if ([info isKindOfClass:[PbUserInfo class]]) {
        PbUserInfo* pbUserInfo = (PbUserInfo*)info;
        if (_addressBook) {
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, pbUserInfo.recordId);
            if(ABPersonHasImageData(person)){
                CFDataRef dataRef = ABPersonCopyImageData(person);
                UIImage *image = [UIImage imageWithData:(__bridge NSData *)dataRef];
                if(dataRef) CFRelease(dataRef);
                [imageiew setImage:image];
            }else{
                imageiew.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
            }
        }else{
            imageiew.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
        }
    }else{
        imageiew.image = [UIImage imageNamed:@"personal_avatar_default_icon_small"];
    }
    
    return cell;
}
-(BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES;
}
#pragma mark GMGridViewActionDelegate
-(void)GMGridView:(GMGridView *)gridView processDeleteActionForItemAtIndex:(NSInteger)index {
    [self.invitePeopleData removeObjectAtIndex:index];
    [self.invitePeopleGridView removeObjectAtIndex:index withAnimation:GMGridViewItemAnimationFade];
//    [self.invitePeopleGridView reloadData];
    [self refreshHeadViewShowUI];
}
- (void)GMGridView:(GMGridView *)gridView changedEdit:(BOOL)edit{
    [self refreshInviteDeleteButton];
}
- (BOOL)GMGridView:(GMGridView *)gridView didLongTapOnItemAtIndex:(NSInteger)position{
    
    return YES;
}
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"Did tap at index %ld", position);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.textField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self refreshBottomViewShow];
    if ([string isEqualToString:@"\n"]) {
        return NO;
    }
    if (!string.length && range.length > 0) {
        return YES;
    }
    
    int newLength = [WYCommonUtils getHanziTextNum:[textField.text stringByAppendingString:string]];
    if(newLength >= Title_maxTextLength && textField.markedTextRange == nil) {
        _textField.text = [WYCommonUtils getHanziTextWithText:[textField.text stringByReplacingCharactersInRange:range withString:string] maxLength:Title_maxTextLength];
        return NO;
    }
    return YES;
}
- (void)checkTextChaneg:(NSNotification *)notif
{
    [self refreshBottomViewShow];
    if (_textField.markedTextRange != nil) {
        return;
    }
    
    if ([WYCommonUtils getHanziTextNum:_textField.text] > Title_maxTextLength && _textField.markedTextRange == nil) {
        _textField.text = [WYCommonUtils getHanziTextWithText:_textField.text maxLength:Title_maxTextLength];
    }
}

#pragma mark - UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@",[_peopleNumbers objectAtIndex:row]];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _peopleNumbers.count;
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    _peopleNumber = [_peopleNumbers[row] intValue];
    _matchPeopleNumber = [NSString stringWithFormat:@"%@个",[_peopleNumbers objectAtIndex:row]];
    [self.tableView reloadData];
}

#pragma mark - SelectGameViewControllerDelegate
- (void)selectGameViewControllerWithGameDic:(NSDictionary*)gameDic{
    WYLog(@"gameDic %@",gameDic);
    _matchGameDic = gameDic;
    if ([gameDic stringObjectForKey:@"item_name"] && [gameDic stringObjectForKey:@"game_server"]) {
        _matchGameName = [NSString stringWithFormat:@"%@•%@",[gameDic stringObjectForKey:@"item_name"],[gameDic stringObjectForKey:@"game_server"]];
    }
    [self refreshHeadViewShowUI];
}

#pragma mark - NetbarSearchViewControllerDelegate
- (void)searchViewControllerSelectWithNetbarInfo:(WYNetbarInfo*)netbarInfo{
    [self.navigationController popViewControllerAnimated:YES];
    if (netbarInfo && netbarInfo.nid.length > 0) {
        _matchWay = 2;
//        _matchAddress = @"线下";
        _netbarInfo = netbarInfo;
        [self.tableView reloadData];
    }
}
#pragma mark - WYInputTextViewControllerDelegate
- (void)inputTextViewControllerWithText:(NSString*)text{
    _matchIntro = text;
    [self.tableView reloadData];
}
#pragma mark - ContactWayViewControllerDelegate
-(void)contactWayViewControllerWithContactDic:(NSDictionary *)contactDic{
    [self.navigationController popViewControllerAnimated:YES];
    if (contactDic.count > 0) {
        _matchContactDic = contactDic;
        _matchContactWay = nil;
        
        NSArray* arr = [contactDic allKeys];
        arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
            NSComparisonResult result = [obj2 compare:obj1];
            return result==NSOrderedDescending;
        }];
        
        for (NSString *key in arr) {
            NSString *value = [contactDic stringObjectForKey:key];
            if (value.length > 0) {
                if ([key isEqualToString:contact_YY]) {
                    _matchContactWay = [NSString stringWithFormat:@"YY房号:%@",value];
                    _matchContactWayToServer = [NSString stringWithFormat:@"YY房号:%@",value];
                }else if ([key isEqualToString:contact_WX]){
                    if (_matchContactWay.length > 0) {
                        _matchContactWay = [NSString stringWithFormat:@"%@\n微信号:%@",_matchContactWay,value];
                        _matchContactWayToServer = [NSString stringWithFormat:@"%@ 微信号:%@",_matchContactWayToServer,value];
                    }else{
                        _matchContactWay = [NSString stringWithFormat:@"微信号:%@",value];
                        _matchContactWayToServer = [NSString stringWithFormat:@"微信号:%@",value];
                    }
                }else if ([key isEqualToString:contact_QQ]){
                    if (_matchContactWay.length > 0) {
                        _matchContactWay = [NSString stringWithFormat:@"%@\nQQ:%@",_matchContactWay,value];
                        _matchContactWayToServer = [NSString stringWithFormat:@"%@ QQ:%@",_matchContactWayToServer,value];
                    }else{
                        _matchContactWay = [NSString stringWithFormat:@"QQ:%@",value];
                        _matchContactWayToServer = [NSString stringWithFormat:@"QQ:%@",value];
                    }
                }
            }
        }
        
        [self refreshHeadViewShowUI];
    }
}

@end
