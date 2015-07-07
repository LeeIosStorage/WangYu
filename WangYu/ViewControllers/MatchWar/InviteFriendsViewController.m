//
//  InviteFriendsViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "PbUserInfo.h"
#import "InviteFriendsViewCell.h"

#define MAX_INVITE_COUNT 19

@interface InviteFriendsViewController ()
{
    NSMutableArray* _notWangYuUserPbs;
    NSMutableArray* _selectedUserPbs;
    ABAddressBookRef _addressBook;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *indexAllContacts;
@property (nonatomic, strong) NSMutableArray *allIndexKeys;

@end

@implementation InviteFriendsViewController

- (void)dealloc{
    if (_addressBook) {
        CFRelease(_addressBook);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self doCheckPb];
}

- (void)doCheckPb{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
            CFErrorRef myError = NULL;
            ABAddressBookRef myAddressBook = ABAddressBookCreateWithOptions(NULL, &myError);
            ABAddressBookRequestAccessWithCompletion(myAddressBook, ^(bool granted, CFErrorRef error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        [self doStartMatchPb];
                    } else {
                        [self alertCanNotAccessPhoneBook];
                        return;
                    }
                    if (myAddressBook) {
                        CFRelease(myAddressBook);
                    }
                });
                
            });
        }else{
            CFErrorRef myError = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &myError);
            if (addressBook ==  nil) {
                [self alertCanNotAccessPhoneBook];
                return;
            }else{
                CFRelease(addressBook);
                [self doStartMatchPb];
            }
        }
    }else{
        [self doStartMatchPb];
    }
}

-(void)doStartMatchPb{
    
     CFErrorRef myError = NULL;
     _addressBook = ABAddressBookCreateWithOptions(NULL, &myError);
    
    _notWangYuUserPbs = [[NSMutableArray alloc] init];
    NSArray *allPbs = [WYCommonUtils getAllPbPhoneContacts];
    if (allPbs) {
        [_notWangYuUserPbs addObjectsFromArray:allPbs];
    }
//    [_notWangYuUserPbs sortUsingSelector:@selector(compareByPinyinOfName:)];
    
    [self newSortAllContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"邀请"];
    [self setRightButtonWithTitle:@"确认" selector:@selector(confirmAction:)];
    if (_slePbUserInfos) {
        _selectedUserPbs = [NSMutableArray arrayWithArray:_slePbUserInfos];
    }else {
        _selectedUserPbs = [[NSMutableArray alloc] init];
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

#pragma mark - 组织字母格式排序
- (void)newSortAllContacts
{
    NSMutableDictionary *allKeys = [[NSMutableDictionary alloc] init];
    self.allIndexKeys = [[NSMutableArray alloc] init];
    self.indexAllContacts = [[NSMutableArray alloc] init];
    
    NSMutableArray *noCarTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *tmpArray = _notWangYuUserPbs;
    for (int i = 0; i < tmpArray.count; ++i) {
        PbUserInfo *pbUserInfo = [tmpArray objectAtIndex:i];
        
        NSString *showName = pbUserInfo.pinyinOfName;
        if (showName.length == 0){
            [noCarTitleArray addObject:pbUserInfo];
            continue;
        }
        
        NSString* title = [showName substringWithRange:NSMakeRange(0, 1)];
        title = [title uppercaseString];
        if ([title compare:@"Z"] > 0|| [title compare:@"A"] < 0) {
            [noCarTitleArray addObject:pbUserInfo];
            continue;
        }else{
            NSMutableArray *array = [allKeys objectForKey:title];
            if (array == nil) {
                NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                [allKeys setObject:tmpArray forKey:title];
            }
            
            NSArray *keys = [allKeys allKeys];
            if ([keys count] == 0) {
                NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
                [allKeys setObject:tmpArray forKey:title];
            }
            NSArray *allKey = [allKeys allKeys];
            for (NSString *keyStr in allKey) {
                if ([keyStr isEqualToString:title])
                {
                    NSMutableArray *array = [allKeys objectForKey:title];
                    [array addObject:pbUserInfo];
                    [allKeys setObject:array forKey:title];
                }
            }
        }
    }
    
    NSMutableArray* keys = [[NSMutableArray alloc] initWithArray:[allKeys allKeys]];
    [keys sortUsingSelector:@selector(compare:)];
    if ([noCarTitleArray count] > 0) {
        [keys addObject:@"#"];
        [allKeys setObject:noCarTitleArray forKey:@"#"];
    }
    self.allIndexKeys = keys;
    
    //没有联系人时，依然显示联系人这个区
    if ([keys count] == 0) {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        [_indexAllContacts addObject:tmpArray];
    }
    
    for (NSString* title in keys) {
        NSMutableArray *array = [allKeys objectForKey:title];
        [_indexAllContacts addObject:array];
    }
    
    [self.tableView reloadData];
}

#pragma mark - custom
- (void)alertCanNotAccessPhoneBook{
    [WYUIUtils showAlertWithMsg:@"请在iPhone的“设置-隐私-通讯录”选项中，选择允许网娱大师访问你的通讯录"];
}

-(void)confirmAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    if (_sendInviteFriendsCallBack) {
        _sendInviteFriendsCallBack(_selectedUserPbs);
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _indexAllContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    int sectionViewHeight = 24;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, sectionViewHeight)];
    view.backgroundColor = self.view.backgroundColor;
    
    UIImageView *t_ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    t_ImageView.image = [UIImage imageNamed:@"s_n_set_line"];
    [view addSubview:t_ImageView];
    
    UIImageView *b_ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 24, SCREEN_WIDTH, 1)];
    b_ImageView.image = [UIImage imageNamed:@"s_n_set_line"];
    [view addSubview:b_ImageView];
    
    NSString *indexLabelText = [self.allIndexKeys objectAtIndex:section];
    UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 2, 200, view.frame.size.height-2)];
    indexLabel.backgroundColor = [UIColor clearColor];
    indexLabel.textColor = SKIN_TEXT_COLOR2;
    indexLabel.font = SKIN_FONT_FROMNAME(12);
    indexLabel.text = indexLabelText;
    [view addSubview:indexLabel];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = [_indexAllContacts objectAtIndex:section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"InviteFriendsViewCell";
    InviteFriendsViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    NSArray *array = [_indexAllContacts objectAtIndex:indexPath.section];
    PbUserInfo *pbUserInfo = array[indexPath.row];
    if (_selectedUserPbs) {
        for (PbUserInfo *info in _selectedUserPbs) {
            if ([info.phoneNUm isEqualToString:pbUserInfo.phoneNUm]) {
                pbUserInfo.selected = YES;
                break;
            }
        }
    }
//    cell.pbUserInfo = pbUserInfo;
    [cell setPbUserInfo:pbUserInfo withddressBookRef:_addressBook];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    if (_selectedUserPbs.count > MAX_INVITE_COUNT) {
        
        [WYUIUtils showAlertWithMsg:[NSString stringWithFormat:@"最多可以邀请%d个战友",MAX_INVITE_COUNT]];
        return;
    }
    
    NSArray *array = [_indexAllContacts objectAtIndex:indexPath.section];
    PbUserInfo *pbUserInfo = array[indexPath.row];
    pbUserInfo.selected = !pbUserInfo.selected;
    
    for (PbUserInfo *info in _selectedUserPbs) {
        if (!pbUserInfo.selected && [info.phoneNUm isEqualToString:pbUserInfo.phoneNUm]) {
            [_selectedUserPbs removeObject:info];
            break;
        }
    }
    if (pbUserInfo.selected) {
        [_selectedUserPbs addObject:pbUserInfo];
    }
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

@end
