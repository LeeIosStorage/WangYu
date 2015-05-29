//
//  AvatarListViewController.h
//  WangYu
//
//  Created by KID on 15/5/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol AvatarListViewControllerDelegate;

@interface AvatarListViewController : WYSuperViewController

@property (nonatomic, assign) id<AvatarListViewControllerDelegate> delagte;

@end

@protocol AvatarListViewControllerDelegate <NSObject>
@optional
- (void)avatarListViewControllerWith:(AvatarListViewController*)vc selectAvatarId:(NSString *)selectAvatarId avatarImage:(UIImage*)avatarImage avatarData:(NSData*)avatarData;
@end