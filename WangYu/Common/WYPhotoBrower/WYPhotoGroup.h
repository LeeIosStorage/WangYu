//
//  WYPhotoGroup.h
//  WangYu
//
//  Created by 许 磊 on 15/5/21.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYPhotoGroup;

@protocol WYPhotoGroupDelegate <NSObject>

@optional
- (void)controllerStatusBarHidden:(BOOL)bHidden;

@end

@interface WYPhotoGroup : UIView

@property (nonatomic, strong) NSArray *photoItemArray;

@property (nonatomic, weak) id<WYPhotoGroupDelegate> delegate;

@end
