//
//  PublishMatchWarViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/26.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PublishMatchWarViewController.h"
#import "SettingViewCell.h"

@interface PublishMatchWarViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSString *_matchGameName;
    
    NSString *_matchTitleName;
    NSString *_matchDateString;
    NSDate *_matchDate;
    NSString *_matchAddress;
    NSString *_matchPeopleNumber;
    NSString *_matchIntro;
    
    NSString *_matchContactWay;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *headView;
@property (nonatomic, strong) IBOutlet UILabel *matchGameNameTipLabel;
@property (nonatomic, strong) IBOutlet UILabel *matchGameNameLabel;

@property (nonatomic, strong) IBOutlet UIView *footerView;
@property (nonatomic, strong) IBOutlet UIView *matchContactView;
@property (nonatomic, strong) IBOutlet UILabel *matchContactTipLabel;
@property (nonatomic, strong) IBOutlet UILabel *matchContactLabel;

@property (nonatomic, strong) IBOutlet UIView *inviteContainerView;
@property (nonatomic, strong) IBOutlet UILabel *inviteTipLabel;
@property (nonatomic, strong) IBOutlet UIView *invitePeopleGridView;

@property (nonatomic, strong) IBOutlet UIView *bottomContainerView;
@property (nonatomic, strong) IBOutlet UIButton *bottomButton;


-(IBAction)matchGameAction:(id)sender;
-(IBAction)matchContactAction:(id)sender;
-(IBAction)addPeopleAction:(id)sender;
-(IBAction)deletePeopleAction:(id)sender;
-(IBAction)submitAction:(id)sender;

@end

@implementation PublishMatchWarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.bottomButton.enabled = NO;
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
    
    self.matchContactTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchContactTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchContactLabel.font = SKIN_FONT_FROMNAME(14);
    self.matchContactLabel.textColor = UIColorToRGB(0xc7c7c7);
    self.matchContactLabel.text = @"请填写(必填)";
    if (_matchContactWay.length > 0) {
        self.matchContactLabel.textColor = UIColorToRGB(0x666666);
        self.matchContactLabel.text = _matchContactWay;
    }
    
    self.inviteTipLabel.font = SKIN_FONT_FROMNAME(14);
    self.inviteTipLabel.textColor = SKIN_TEXT_COLOR1;
    
    [self refreshBottomViewShow];
    
    self.tableView.tableHeaderView = self.headView;
    self.tableView.tableFooterView = self.footerView;
    [self.tableView reloadData];
}

-(void)refreshBottomViewShow{
    
    self.bottomButton.titleLabel.font = SKIN_FONT_FROMNAME(15);
    self.bottomButton.layer.cornerRadius = 4;
    self.bottomButton.layer.masksToBounds = YES;
    if (self.bottomButton.enabled) {
        self.bottomButton.backgroundColor = SKIN_COLOR;
    }else{
        self.bottomButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    }
}

#pragma mark - IBAction
-(IBAction)matchGameAction:(id)sender{
    
}

-(IBAction)matchContactAction:(id)sender{
    
}

-(IBAction)addPeopleAction:(id)sender{
    
}

-(IBAction)deletePeopleAction:(id)sender{
    
}

-(IBAction)submitAction:(id)sender{
    
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
    NSString *intro = _matchTitleName;
    NSDictionary *dict00 = @{@"titleLabel": @"约战标题",
                             @"icon": @"match_publish_title_icon",
                             @"intro": intro!=nil?intro:@"为自己的约战描述一下吧",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
    intro = _matchDateString;
    NSDictionary *dict01 = @{@"titleLabel": @"时间",
                             @"icon": @"match_detail_time_icon",
                             @"intro": intro!=nil?intro:@"请设置",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
    intro = _matchAddress;
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
    intro = _matchIntro;
    NSDictionary *dict04 = @{@"titleLabel": @"介绍",
                             @"icon": @"match_publish_intro_icon",
                             @"intro": intro!=nil?intro:@"请介绍",
                             @"textcolor": intro!=nil?@(1):@(0),
                             };
    [tmpMutDict setObject:dict00 forKey:[NSString stringWithFormat:@"r%d",(int)tmpMutDict.count]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
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
        [cell setLineImageViewWithType:0];
        if ([self newSectionPolicy:indexPath.section] == 1) {
            [cell setLineImageViewWithType:-1];
        }
    }else if (indexPath.row == [self newSectionPolicy:indexPath.section]-1){
        [cell setLineImageViewWithType:-1];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = NO;
    cell.rightLabel.font = SKIN_FONT_FROMNAME(14);
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = NO;
    
    CGRect frame = cell.avatarImageView.frame;
    frame.origin.y = (44-12)/2;
    frame.size.width = 12;
    frame.size.height = 12;
    cell.avatarImageView.frame = frame;
    
    frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 7;
    cell.titleLabel.frame = frame;
    
//    cell.rightLabel.backgroundColor = [UIColor lightGrayColor];
    cell.rightLabel.autoresizingMask = UIViewAutoresizingNone;
    frame = cell.rightLabel.frame;
    frame.origin.x = 102;
    frame.size.width = SCREEN_WIDTH - frame.origin.x - 28;
    cell.rightLabel.frame = frame;
    cell.rightLabel.textAlignment = NSTextAlignmentRight;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.indicatorImage.hidden = YES;
            frame = cell.rightLabel.frame;
            frame.origin.x = 102;
            frame.size.width = SCREEN_WIDTH - frame.origin.x - 12;
            cell.rightLabel.frame = frame;
            cell.rightLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    
    cell.titleLabel.text = [rowDicts objectForKey:@"titleLabel"];
    cell.avatarImageView.image = [UIImage imageNamed:[rowDicts objectForKey:@"icon"]];
    
    if (!cell.rightLabel.hidden) {
        cell.rightLabel.text = [rowDicts objectForKey:@"intro"];
        
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
    
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        }else if (indexPath.row == 1){
            
        }else if (indexPath.row == 2){
            
        }else if (indexPath.row == 3){
            
        }else if (indexPath.row == 4){
            
        }
    }
}

@end
