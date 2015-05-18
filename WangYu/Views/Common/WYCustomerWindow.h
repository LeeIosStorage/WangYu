//
//  WYCustomerWindow.h
//  WangYu
//
//  Created by KID on 15/5/18.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WYCustomerWindowDelg <NSObject>

@optional
-(void)customerWindowClickAt:(NSIndexPath *)indexPath action:(NSString *)action;

@end

@interface WYCustomerWindow : UIWindow

@property (nonatomic, weak)id<WYCustomerWindowDelg> sheetDelg;
@property (nonatomic, assign) BOOL deleteBtnHidden;
@property (nonatomic, assign) BOOL collectBtnHidden;
@property (nonatomic, assign) BOOL shareSectionHidden;
@property (nonatomic, strong) NSString *collectBtnTitle;

-(void)setCustomerSheet;
-(void)cancelActionSheet:(id)sender;

@end
