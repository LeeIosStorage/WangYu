//
//  SearchInviteFriendsViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SearchInviteFriendsViewController.h"
#import "InviteFriendsViewCell.h"
#import "PbUserInfo.h"

@interface SearchInviteFriendsViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>
{
    ABAddressBookRef _addressBook;
    
    NSMutableArray* _allUserInfoPbs;
    NSMutableArray* _selectedUserPbs;
    NSMutableArray* _searchedContacts;
}
@property (nonatomic,strong) IBOutlet UIView *topView;

-(IBAction)backToPreViewController:(id)sender;

@end

@implementation SearchInviteFriendsViewController

- (void)dealloc{
    WYLog(@"%@ dealloc!!!",NSStringFromClass([self class]));
    if (_addressBook) {
        CFRelease(_addressBook);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleNavBar.hidden = YES;
    self.searchBar.tintColor = SKIN_TEXT_COLOR1;
//    self.searchBar.barTintColor = UIColorRGB(189, 189, 195);
    self.topView.backgroundColor = UIColorRGB(201, 201, 206);
    
    CFErrorRef myError = NULL;
    _addressBook = ABAddressBookCreateWithOptions(NULL, &myError);
    
    
    _allUserInfoPbs = [[NSMutableArray alloc] initWithArray:_notWangYuUserPbs];
    _selectedUserPbs = [[NSMutableArray alloc] initWithArray:_slePbUserInfos];
    
    [_allUserInfoPbs sortUsingSelector:@selector(compareByPinyinOfName:)];
    
    UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelGestureRecognizer:)];
    [self.searchMaskVew addGestureRecognizer:gestureRecongnizer];
}

- (void)cancelGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self backToPreViewController:nil];
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

-(IBAction)backToPreViewController:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contactsSearchBarCancelButtonClicked:)]) {
        _topView.hidden = YES;
        [self.delegate contactsSearchBarCancelButtonClicked:_selectedUserPbs];
    }
}

-(void)doSearchAction{
    
    NSString *searchContent = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (searchContent.length == 0) {
        self.tableView.hidden = YES;
        self.searchMaskVew.hidden = NO;
        return;
    } else {
        self.tableView.hidden = NO;
        self.searchMaskVew.hidden = YES;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    _searchedContacts = [[NSMutableArray alloc] init];
    for (PbUserInfo* userInfo in _allUserInfoPbs) {
        BOOL filter = NO;
        
        if ([userInfo.name rangeOfString:searchContent options:NSCaseInsensitiveSearch].length > 0) {
            filter = YES;
        } else {
            filter = [WYCommonUtils searchPinYin:userInfo.pinyinOfName searchContent:searchContent];
        }
        
//        if (filter == NO && userInfo.mark.length > 0) {
//            if (!userInfo.pinyinOfRealNickName) {
//                userInfo.pinyinOfRealNickName = [PinyinUtils Unicode2Pinyin:userInfo.realNickName];
//            }
//            if ([userInfo.realNickName rangeOfString:searchContent options:NSCaseInsensitiveSearch].length > 0) {
//                filter = YES;
//            } else {
//                filter = [LSCommonUtils searchPinYin:userInfo.pinyinOfRealNickName searchContent:searchContent];
//            }
//            
//        }
        
        if (filter) {
            [_searchedContacts addObject:userInfo];
        }
    }
    
    [self.tableView reloadData];

}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self backToPreViewController:nil];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self doSearchAction];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self doSearchAction];
    
    if (searchText.length == 0) {
        self.view.backgroundColor = [UIColor clearColor];
    }else{
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - tableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchedContacts.count;
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
    
    PbUserInfo *pbUserInfo = _searchedContacts[indexPath.row];
    if (_selectedUserPbs) {
        for (PbUserInfo *info in _selectedUserPbs) {
            if ([info.phoneNUm isEqualToString:pbUserInfo.phoneNUm]) {
                pbUserInfo.selected = YES;
                break;
            }
        }
    }
    [cell setPbUserInfo:pbUserInfo withddressBookRef:_addressBook];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    
    PbUserInfo *pbUserInfo = _allUserInfoPbs[indexPath.row];
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

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
