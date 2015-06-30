//
//  InviteFriendsViewCell.h
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PbUserInfo.h"
#import <AddressBook/AddressBook.h>

@interface InviteFriendsViewCell : UITableViewCell

@property (nonatomic, strong) PbUserInfo *pbUserInfo;

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *phoneNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *stateImageView;

- (void)setPbUserInfo:(PbUserInfo*)userInfo withddressBookRef:(ABAddressBookRef)addressBook;

@end
