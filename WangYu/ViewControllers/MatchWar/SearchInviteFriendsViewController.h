//
//  SearchInviteFriendsViewController.h
//  WangYu
//
//  Created by Leejun on 15/7/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol SearchInviteFriendsVCDelegate;

@interface SearchInviteFriendsViewController : WYSuperViewController

@property (strong, nonatomic) IBOutlet UIView *searchMaskVew;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) id<SearchInviteFriendsVCDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *slePbUserInfos;
@property (nonatomic, strong) NSMutableArray *notWangYuUserPbs;

@end

@protocol SearchInviteFriendsVCDelegate <NSObject>
- (void)contactsSearchBarCancelButtonClicked:(NSMutableArray *)sleUserInfos;
@end