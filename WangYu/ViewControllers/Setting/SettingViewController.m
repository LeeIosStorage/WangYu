//
//  SettingViewController.m
//  WangYu
//
//  Created by KID on 15/5/8.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingViewCell.h"
#import "WYAlertView.h"
#import "WYEngine.h"
#import "WYCommonUtils.h"
#import "WelcomeViewController.h"
#import "AboutViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "WYProgressHUD.h"
#import "WYActionSheet.h"
#import "WYSettingConfig.h"
#import "LocationViewController.h"
#import "WYLinkerHandler.h"
#import "WYCommonWebVc.h"

@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate,LocationViewControllerDelegate,UITextFieldDelegate>
{
    int _maxAddMessageLenght;
}
@property (strong, nonatomic) IBOutlet UITableView *setTableView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIButton *exitButton;

@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *cityCode;
@property (assign, nonatomic) unsigned long long cacheSize;

@property (strong, nonatomic) NSString *inviteCode;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, assign) BOOL isInFieldDelegate;

- (IBAction)exitAction:(id)sender;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self.view setBackgroundColor:UIColorRGB(234, 234, 234)];
    
    _maxAddMessageLenght = 20;
    _inviteCode = [WYEngine shareInstance].userInfo.invitationCode;
    _cityCode = [WYEngine shareInstance].userInfo.cityCode;
    _cityName = [WYEngine shareInstance].userInfo.cityName;
    [self getCacheSize];
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)initNormalTitleNavBarSubviews{
    [self setTitle:@"设置"];
}

- (void)getCacheSize{
    //获取缓存文件大小
    self.cacheSize = UINT64_MAX;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned long long size = [WYCommonUtils getDirectorySizeForPath:[[WYEngine shareInstance] wyInstanceDocPath]];
        size += [[SDImageCache sharedImageCache] getSize];
        size += [[WYEngine shareInstance] getUrlCacheSize];
        __weak SettingViewController* weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.cacheSize = size;
            [weakSelf.setTableView reloadData];
        });
    });
}

-(void)refreshUI{
    
    self.setTableView.tableFooterView = self.footerView;
    
    self.exitButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.exitButton.backgroundColor = SKIN_COLOR;
    self.exitButton.layer.cornerRadius = 4;
    self.exitButton.layer.masksToBounds = YES;
    if (![[WYEngine shareInstance] hasAccoutLoggedin]) {
//        self.exitButton.titleLabel.text = @"注册或登录";
        [self.exitButton setTitle:@"注册或登录" forState:UIControlStateNormal];
    }else{
//        self.exitButton.titleLabel.text = @"退出当前帐号";
        [self.exitButton setTitle:@"退出当前帐号" forState:UIControlStateNormal];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1) {
        return 1;
    }
    else if (section == 2){
        return 4;
    }
#ifdef DEBUG
    return 1;
#endif
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 10)];
    view.backgroundColor = [UIColor clearColor];
    return view;
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
    cell.rightLabel.hidden = YES;
    cell.avatarImageView.hidden = YES;
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"切换城市";
                cell.rightLabel.text = _cityName;
                cell.rightLabel.hidden = NO;
                [cell setLineImageViewWithType:-1];
                break;
            }
        }
        case 1:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"客服中心";
                [cell setLineImageViewWithType:-1];
                break;
            }
        }
        case 2:{
            if (indexPath.row == 0) {
                cell.titleLabel.text = @"填写邀请码";
                cell.rightLabel.text = _inviteCode;
                cell.rightLabel.hidden = NO;
                [cell setLineImageViewWithType:-1];
                break;
            }else if (indexPath.row == 1) {
                cell.titleLabel.text = @"清理缓存";
                [cell setLineImageViewWithType:0];
                if (self.cacheSize != UINT64_MAX) {
                    NSString* cacheSizeStr = @"";
                    if (self.cacheSize > 1024*1024*1024) {
                        cacheSizeStr = [NSString stringWithFormat:@"%.2f GB", self.cacheSize*1.0/(1024*1024*1024)];
                    } else {
                        cacheSizeStr = [NSString stringWithFormat:@"%.2f MB", self.cacheSize*1.0/(1024*1024)];
                    }
                    cell.rightLabel.text = cacheSizeStr;
                    cell.rightLabel.hidden = NO;
                }
                break;
            }
            else if (indexPath.row == 2){
                cell.titleLabel.text = @"给我评分";
                [cell setLineImageViewWithType:1];
                break;
            }
            else if (indexPath.row == 3){
                cell.titleLabel.text = @"关于我们";
                [cell setLineImageViewWithType:2];
                break;
            }
            
        }
        case 3:{
            if (indexPath.row == 0){
                if ([WYEngine shareInstance].serverPlatform == OnlinePlatform) {
                    cell.titleLabel.text = @"测试环境";
                }else{
                    cell.titleLabel.text = @"线上环境";
                }
                cell.indicatorImage.hidden = YES;
                [cell setLineImageViewWithType:-1];
            }
        }
            break;
        default:
            break;
    }
    
    if (indexPath.row == 0) {
        // cell.topline.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:{
            if ([[WYEngine shareInstance] needUserLogin:nil]) {
                return;
            }
            LocationViewController *locationChooseVc = [[LocationViewController alloc] init];
            locationChooseVc.isShowNoticeView = YES;
            locationChooseVc.delagte = self;
            [self.navigationController pushViewController:locationChooseVc animated:YES];
            break;
        }
        case 1:{
//            id vc = [WYLinkerHandler handleDealWithHref: From:self.navigationController];
//            if (vc) {
//                [self. pushViewController:vc animated:YES];
//            }
            NSString *url = [NSString stringWithFormat:@"%@/cs/web/detail", [WYEngine shareInstance].baseUrl];
            WYCommonWebVc *webvc = [[WYCommonWebVc alloc] initWithAddress:url];
            webvc.showFeedback = YES;
            [self.navigationController pushViewController:webvc animated:YES];
            
            break;
        }
        case 2:{
            if (indexPath.row == 0) {
                [self showInviteCodeAlert];
                break;
            }else if (indexPath.row == 1) {
                [self showClearCacheAction];
                break;
            }
            else if (indexPath.row == 2){
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id986749236"]];//
                break;
            }else if (indexPath.row == 3){
                AboutViewController *aVc = [[AboutViewController alloc] init];
                [self.navigationController pushViewController:aVc animated:YES];
//                id vc = [WYLinkerHandler handleDealWithHref:[NSString stringWithFormat:@"%@/my/web/about", [WYEngine shareInstance].baseUrl] From:self.navigationController];
//                if (vc) {
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
                break;
            }
        }
        case 3:{
            if (indexPath.row == 0){
                [self onLogoutWithError:nil];
                break;
            }
        }
        default:
            break;
    }
}

- (void)signOutAndLogin{
    AppDelegate * appDelgate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    WYLog(@"signOut for user logout from SettingViewController");
    [appDelgate signOut];
    [[WYEngine shareInstance] visitorLogin];
}

- (void)onLogoutWithError:(NSError *)error {
    if ([WYEngine shareInstance].serverPlatform == TestPlatform) {
        [WYEngine shareInstance].serverPlatform = OnlinePlatform;
    } else {
        [WYEngine shareInstance].serverPlatform = TestPlatform;
    }
    AppDelegate * appDelgate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSLog(@"signOut for user logout");
    [appDelgate signOut];
}

- (void)checkVersion{
//    int tag = [[WYEngine shareInstance] getConnectTag];
//    //去服务器取版本信息
//    [[WYEngine shareInstance] getAppNewVersionWithTag:tag];
//    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//        if (!jsonRet || err){
//            return ;
//        }
//        
//        NSString *localVserion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
//        NSString* version = nil;
//        
//        version = [jsonRet stringObjectForKey:@"object"];
//        
//        //        NSString* checkedVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"checkedVersion"];
//        //        if ([checkedVersion isEqualToString:version]) {
//        //            return;
//        //        }
//        //        localVserion
//        //        [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"checkedVersion"];
//        if ([XECommonUtils isVersion:version greaterThanVersion:localVserion]) {
//            XEAlertView *alert = [[XEAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@版本已上线", version] message:@"宝爸宝妈快去更新吧" cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"立刻更新" okBlock:^{
//                NSURL *url = [[ NSURL alloc ] initWithString: @"http://itunes.apple.com/app/id967105015"] ;
//                [[UIApplication sharedApplication] openURL:url];
//            }];
//            [alert show];
//            return;
//        }else{
//            [XEProgressHUD AlertSuccess:@"当前版本已经是最新版本"];
//        }
//    } tag:tag];
    
}

- (void)showClearCacheAction
{
    __weak SettingViewController* weakSelf = self;
    WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"确认清除" message:@"是否清除本地所有图片和内容缓存" cancelButtonTitle:@"取消" cancelBlock:^{
    } okButtonTitle:@"清除" okBlock:^{
        [weakSelf clearCacheAction];
    }];
    [alertView show];
}

- (void)clearCacheAction{
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    
    [[WYEngine shareInstance] clearAllCache];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:[[WYEngine shareInstance] wyInstanceDocPath] error:nil];
        [[NSFileManager defaultManager] createDirectoryAtPath:[[WYEngine shareInstance] wyInstanceDocPath] withIntermediateDirectories:YES attributes:nil error:nil];
    });
    self.cacheSize = 0;
    [self.setTableView reloadData];
    [WYProgressHUD AlertSuccess:@"缓存已清空"];
}

#pragma mark - LocationViewControllerDelegate
- (void)locationViewControllerWith:(LocationViewController*)vc selectCity:(NSDictionary *)cityDic{
    
    [vc.navigationController popViewControllerAnimated:YES];
    
    _cityName = [cityDic stringObjectForKey:@"name"];
    _cityCode = [cityDic stringObjectForKey:@"areaCode"];
    [self.setTableView reloadData];
    [self updateUserCity:_cityCode];
}

- (void)updateUserCity:(NSString*)cityCode{
    
    [WYProgressHUD AlertLoading:@"正在切换城市..." At:self.view];
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] editUserCityWithUid:[WYEngine shareInstance].uid cityCode:_cityCode cityName:_cityName tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"切换城市成功" At:weakSelf.view];
        
        NSDictionary *object = [jsonRet dictionaryObjectForKey:@"object"];
        WYUserInfo *userInfo = [[WYUserInfo alloc] init];
        [userInfo setUserInfoByJsonDic:object];
        [WYEngine shareInstance].userInfo = userInfo;
        
        [weakSelf.setTableView reloadData];
        
    }tag:tag];
    
}

- (IBAction)exitAction:(id)sender {
    
    __weak SettingViewController *weakSelf = self;
    if (![[WYEngine shareInstance] hasAccoutLoggedin]) {
        [self signOutAndLogin];
    }else{
        WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                return;
            }
            if (buttonIndex == 0) {
                [weakSelf signOutAndLogin];
            }
        }];
        [sheet addButtonWithTitle:@"退出登录"];
        sheet.destructiveButtonIndex = sheet.numberOfButtons - 1;
        
        [sheet addButtonWithTitle:@"取消"];
        sheet.cancelButtonIndex = sheet.numberOfButtons -1;
        [sheet showInView:self.view];
    }
}

- (void)showInviteCodeAlert{
    
    if ([[WYEngine shareInstance] needUserLogin:nil]) {
        return;
    }
    if (_inviteCode.length > 0) {
        return;
    }
    [self removeInviteCodeAlert];
    
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:@"填写邀请码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    _alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    _textFiled = [_alertView textFieldAtIndex:0];
    _textFiled.delegate = self;
    _textFiled.font = [UIFont systemFontOfSize:15];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPersonTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    [_alertView show];
}
-(void)removeInviteCodeAlert{
    if (_alertView) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _textFiled.delegate = nil;
        _textFiled = nil;
        _alertView.delegate = nil;
        _alertView = nil;
        ;
    }
}

#pragma mark -- UIAlertViewDelegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self checkInviteCode];
    }
}


#pragma mark --UITextFieldDelegate
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

//ios 7监听文本变化的函数
-(void) addPersonTextFieldDidChange:(NSNotification *) noti
{
    if (_isInFieldDelegate) {
        _isInFieldDelegate = NO;
        return;
    }
    
    UITextField *textField = noti.object;
    if (![textField isEqual:_textFiled]) {
        return;
    }
    
    int count = [WYCommonUtils getHanziTextNum:textField.text];
    
    if (count >= _maxAddMessageLenght) {
//        [self showMaxInputLenghtNotice];
        textField.text = [WYCommonUtils getHanziTextWithText:textField.text maxLength:_maxAddMessageLenght];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    _isInFieldDelegate = YES;
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    
    //删除
    if (!string.length && range.length > 0) {
        return YES;
    }
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    int count = [WYCommonUtils getHanziTextNum:newString];
    if (count >= _maxAddMessageLenght) {
//        [self showMaxInputLenghtNotice];
        textField.text = [WYCommonUtils getHanziTextWithText:newString maxLength:_maxAddMessageLenght];
        return NO;
    }
    return YES;
}

- (void)checkInviteCode{
    NSString *content = [_textFiled.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (content.length == 0) {
        [WYProgressHUD AlertError:@"请填写正确邀请码" At:self.view];
        return;
    }
    [WYProgressHUD AlertLoading:@"正在验证邀请码" At:self.view];
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] uploadMineInviteCodeWith:[WYEngine shareInstance].uid invitationCode:content tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"验证成功." At:weakSelf.view];
        weakSelf.inviteCode = content;
        NSDictionary *dic = [jsonRet objectForKey:@"object"];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            WYUserInfo *userInfo = [[WYUserInfo alloc] init];
            [userInfo setUserInfoByJsonDic:dic];
            [WYEngine shareInstance].userInfo = userInfo;
        }
        [weakSelf.setTableView reloadData];
    }tag:tag];
}
@end
