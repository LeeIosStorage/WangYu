//
//  PersonalProfileViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/19.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PersonalProfileViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "SettingViewCell.h"
#import "UIImageView+WebCache.h"
#import "AvatarListViewController.h"
#import "QHQnetworkingTool.h"
#import "WYActionSheet.h"
#import "WYInputViewController.h"

#define TAG_USER_NAME        0
#define TAG_USER_REALNAME    1
#define TAG_USER_IDCARD      2
#define TAG_USER_QQ          3

@interface PersonalProfileViewController ()<UITableViewDataSource,UITableViewDelegate,AvatarListViewControllerDelegate,WYInputViewControllerDelegate>
{
    int _editTag;
    
    UIImage *_avatarImage;
    NSData *_avatarData;
    NSString *_recommendUserHeadPic;
    
    WYUserInfo *_oldUserInfo;
    WYUserInfo *_newUserInfo;
}
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation PersonalProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadUserInfo];
}

-(void)loadUserInfo{
    WYUserInfo* tmpUserInfo = _userInfo;
    if (tmpUserInfo == nil || tmpUserInfo.uid.length == 0) {
        [WYProgressHUD AlertError:@"用户不存在"];
    }
    _oldUserInfo = [[WYUserInfo alloc] init];
    [_oldUserInfo setUserInfoByJsonDic:tmpUserInfo.userInfoByJsonDic];
    _oldUserInfo.uid = _userInfo.uid;
    
    _newUserInfo = [[WYUserInfo alloc] init];
    [_newUserInfo setUserInfoByJsonDic:tmpUserInfo.userInfoByJsonDic];
    _newUserInfo.uid = _userInfo.uid;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"个人信息"];
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

- (void)editUserInfo{
    NSMutableArray *dataArray = [NSMutableArray array];
    if (_avatarData) {
        QHQFormData* pData = [[QHQFormData alloc] init];
        pData.data = _avatarData;
        pData.name = @"avatar";
        pData.filename = @"avatar";
        pData.mimeType = @"image/png";
        [dataArray addObject:pData];
    }else{
        dataArray = nil;
    }
    __weak PersonalProfileViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] editUserInfoWithUid:[WYEngine shareInstance].uid nickName:_newUserInfo.nickName avatar:dataArray userHead:_recommendUserHeadPic qqNumber:_newUserInfo.qq sex:_newUserInfo.gender realName:_newUserInfo.realName idCard:_newUserInfo.idCard tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"更新失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        WYUserInfo *userInfo = [[WYUserInfo alloc] init];
        [userInfo setUserInfoByJsonDic:object];
        [WYEngine shareInstance].userInfo = userInfo;
        [weakSelf.tableView reloadData];
        
    }tag:tag];
}

-(NSDictionary *)tableDataModule{
    NSDictionary *moduleDict;
    NSMutableDictionary *tmpMutDict = [NSMutableDictionary dictionary];
    
    
    //section = 0
    NSMutableDictionary *sectionDict0 = [NSMutableDictionary dictionary];
    NSString *intro = [_newUserInfo.smallAvatarUrl absoluteString];
    if (_recommendUserHeadPic.length > 0) {
        intro = [NSString stringWithFormat:@"%@/%@",[[WYEngine shareInstance] baseImgUrl],_recommendUserHeadPic];
    }
    NSDictionary *dict00 = @{@"titleLabel": @"头像",
                             @"intro": intro!=nil?intro:@"",
                             };
    [sectionDict0 setObject:dict00 forKey:[NSString stringWithFormat:@"r%d",(int)sectionDict0.count]];
    
    //section = 1
    NSMutableDictionary *sectionDict1 = [NSMutableDictionary dictionary];
    intro = _newUserInfo.nickName;
    NSDictionary *dict10 = @{@"titleLabel": @"昵称",
                             @"intro": intro!=nil?intro:@"",
                             };
    intro = _newUserInfo.gender;
    intro = @"";
    if ([_newUserInfo.gender isEqualToString:@"0"]) {
        intro = @"男";
    }else if ([_newUserInfo.gender isEqualToString:@"1"]){
        intro = @"女";
    }
    NSDictionary *dict11 = @{@"titleLabel": @"性别",
                             @"intro": intro!=nil?intro:@"",
                             };
    [sectionDict1 setObject:dict10 forKey:[NSString stringWithFormat:@"r%d",(int)sectionDict1.count]];
    [sectionDict1 setObject:dict11 forKey:[NSString stringWithFormat:@"r%d",(int)sectionDict1.count]];
    
    //section = 2
    NSMutableDictionary *sectionDict2 = [NSMutableDictionary dictionary];
    intro = _newUserInfo.realName;
    NSDictionary *dict20 = @{@"titleLabel": @"真实姓名",
                             @"intro": intro!=nil?intro:@"未填写",
                             };
    intro = _newUserInfo.idCard;
    NSDictionary *dict21 = @{@"titleLabel": @"身份证",
                             @"intro": intro!=nil?intro:@"未填写",
                             };
    intro = _newUserInfo.qq;
    NSDictionary *dict22 = @{@"titleLabel": @"QQ",
                             @"intro": intro!=nil?intro:@"未填写",
                             };
    [sectionDict2 setObject:dict20 forKey:[NSString stringWithFormat:@"r%d",(int)sectionDict2.count]];
    [sectionDict2 setObject:dict21 forKey:[NSString stringWithFormat:@"r%d",(int)sectionDict2.count]];
    [sectionDict2 setObject:dict22 forKey:[NSString stringWithFormat:@"r%d",(int)sectionDict2.count]];
    
    
    [tmpMutDict setObject:sectionDict0 forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:sectionDict1 forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
    [tmpMutDict setObject:sectionDict2 forKey:[NSString stringWithFormat:@"s%d",(int)tmpMutDict.count]];
    
    moduleDict = tmpMutDict;
    return moduleDict;
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
    if (section == 0) {
        return 10;
    }else if (section == 1){
        return 50;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 64;
    }
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }else if (section == 1){
        UIView *supView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
        supView.backgroundColor = [UIColor clearColor];
        
        UIView *viewSub = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, 40)];
        viewSub.backgroundColor = [UIColor whiteColor];
        
        UIImageView *lineImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
        lineImgView.image = [UIImage imageNamed:@"s_n_set_line"];
        [viewSub addSubview:lineImgView];
        
        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 4, 16)];
        colorLabel.backgroundColor = UIColorToRGB(0xfac402);
        colorLabel.layer.cornerRadius = 1.0;
        colorLabel.layer.masksToBounds = YES;
        [viewSub addSubview:colorLabel];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(23, 0, 200, 40)];
        label.textColor = SKIN_TEXT_COLOR1;
        label.font = SKIN_FONT_FROMNAME(15);
        label.text = @"参赛资料";
        [viewSub addSubview:label];
        
        [supView addSubview:viewSub];
        return supView;
    }else{
        return nil;
    }
}
static int avatarImageView_Tag = 201;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        CGSize size = CGSizeMake(64-10*2, 64-10*2);
        UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - size.width - 28, 10, size.width, size.height)];
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width/2;
        avatarImageView.clipsToBounds = YES;
        avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        avatarImageView.tag = avatarImageView_Tag;
        [cell addSubview:avatarImageView];
    }
    
    UIImageView *userAvatarImageView = (UIImageView *)[cell viewWithTag:avatarImageView_Tag];
    userAvatarImageView.hidden = YES;
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:0];
        if ([self newSectionPolicy:indexPath.section] == 1) {
            [cell setLineImageViewWithType:-1];
        }
    }else if (indexPath.row == [self newSectionPolicy:indexPath.section]-1){
        [cell setLineImageViewWithType:2];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = NO;
    cell.rightLabel.font = SKIN_FONT_FROMNAME(14);
    cell.avatarImageView.hidden = YES;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.rightLabel.hidden = YES;
            userAvatarImageView.hidden = NO;
        }
    }
    
    NSDictionary *cellDicts = [[self tableDataModule] objectForKey:[NSString stringWithFormat:@"s%d", (int)indexPath.section]];
    NSDictionary *rowDicts = [cellDicts objectForKey:[NSString stringWithFormat:@"r%d", (int)indexPath.row]];
    
    cell.titleLabel.text = [rowDicts objectForKey:@"titleLabel"];
    
    if (!cell.rightLabel.hidden) {
        cell.rightLabel.text = [rowDicts objectForKey:@"intro"];
        if (indexPath.section == 2) {
            cell.rightLabel.textColor = UIColorToRGB(0x666666);
        }else{
            cell.rightLabel.textColor = SKIN_TEXT_COLOR2;
        }
    }
    if (!userAvatarImageView.hidden) {
        if (_avatarImage) {
            [userAvatarImageView setImage:_avatarImage];
        }else{
            [userAvatarImageView sd_setImageWithURL:nil];
            [userAvatarImageView sd_setImageWithURL:[NSURL URLWithString:[rowDicts objectForKey:@"intro"]] placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon_small"]];
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
            AvatarListViewController *avatarListVc = [[AvatarListViewController alloc] init];
            avatarListVc.delagte = self;
            [self.navigationController pushViewController:avatarListVc animated:YES];
        }
    }else if (indexPath.section == 1) {
        if (indexPath.row == 0){
            _editTag = TAG_USER_NAME;
            [self editUserInfo:TAG_USER_NAME withRowDicts:rowDicts];
        }else if (indexPath.row == 1){
            __weak PersonalProfileViewController *weakSelf = self;
            WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
                if (2 == buttonIndex) {
                    return;
                }
                NSString *gender = @"";
                if (buttonIndex == 0) {
                    gender = @"0";
                }else if (buttonIndex == 1){
                    gender = @"1";
                }
                if (![_newUserInfo.gender isEqualToString:gender]) {
                    _newUserInfo.gender = gender;
                    [weakSelf.tableView reloadData];
                    [weakSelf editUserInfo];
                }
            } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男", @"女", nil];
            [sheet showInView:self.view];
        }
    }else if (indexPath.section == 2){
        [self selectRowsAtIndexPath:indexPath rowDicts:rowDicts];
    }
}

-(void)selectRowsAtIndexPath:(NSIndexPath *)indexPath rowDicts:(NSDictionary *)rowDicts{
    if (indexPath.row == 0) {
        _editTag = TAG_USER_REALNAME;
    }else if (indexPath.row == 1) {
        _editTag = TAG_USER_IDCARD;
    }else if (indexPath.row == 2){
        _editTag = TAG_USER_QQ;
    }
    [self editUserInfo:_editTag withRowDicts:rowDicts];
}
-(void)editUserInfo:(int)Tag withRowDicts:(NSDictionary *)rowDicts{
    
    WYInputViewController *lvc = [[WYInputViewController alloc] init];
    lvc.delegate = self;
    lvc.oldText = [rowDicts objectForKey:@"intro"];
    if (Tag == TAG_USER_NAME) {
        lvc.oldText = _newUserInfo.nickName;
//        lvc.minTextLength = 0;
        lvc.maxTextLength = 16;
    }
    if (Tag == TAG_USER_REALNAME) {
        lvc.oldText = _newUserInfo.realName;
//        lvc.minTextLength = 2;
//        lvc.maxTextLength = 16;
    }
    if (Tag == TAG_USER_IDCARD) {
        lvc.oldText = _newUserInfo.idCard;
        lvc.minTextLength = 9;
        lvc.maxTextLength = 9;
        lvc.toolRightType = @"wy_IDCard";
//        lvc.keyboardType = UIKeyboardTypeNumberPad;
    }
    if (Tag == TAG_USER_QQ) {
        lvc.oldText = _newUserInfo.qq;
        lvc.maxTextLength = 8;
        lvc.keyboardType = UIKeyboardTypeNumberPad;
    }
    lvc.maxTextViewHight = 39.0f;
    lvc.titleText = [rowDicts objectForKey:@"titleLabel"];
    [self.navigationController pushViewController:lvc animated:YES];
}

#pragma mark -XEInputViewControllerDelegate
- (void)inputViewControllerWithText:(NSString*)text{
    WYLog(@"text==%@",text);
    if (_editTag == TAG_USER_NAME) {
        _newUserInfo.nickName = text;
    }else if (_editTag == TAG_USER_REALNAME){
        _newUserInfo.realName = text;
    }else if (_editTag == TAG_USER_IDCARD){
        _newUserInfo.idCard = text;
    }else if (_editTag == TAG_USER_QQ){
        _newUserInfo.qq = text;
    }
    [self.tableView reloadData];
    [self editUserInfo];
}

#pragma mark - AvatarListViewControllerDelegate
- (void)avatarListViewControllerWith:(AvatarListViewController*)vc selectAvatarId:(NSString *)selectAvatarId avatarImage:(UIImage*)avatarImage avatarData:(NSData*)avatarData{
    
    [vc.navigationController popViewControllerAnimated:YES];
    _recommendUserHeadPic = selectAvatarId;
    _avatarImage = avatarImage;
    _avatarData = avatarData;
    [self.tableView reloadData];
    [self editUserInfo];
}

@end
