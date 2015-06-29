//
//  WYInputViewController.h
//  WangYu
//
//  Created by Leejun on 15/6/25.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol WYInputViewControllerDelegate;

@interface WYInputViewController : WYSuperViewController

@property(nonatomic, assign)id<WYInputViewControllerDelegate> delegate;
@property(nonatomic, strong) NSString* oldText;
@property(nonatomic, strong) NSString* titleText;
@property(nonatomic, assign) int maxTextLength;
@property(nonatomic, assign) int minTextLength;
@property(nonatomic, assign) float maxTextViewHight;
@property(nonatomic, strong) NSString* toolRightType;
@property(nonatomic, assign) UIKeyboardType keyboardType;

//约战发布选择游戏时用
@property(nonatomic, strong) NSDictionary *gameDic;

@end

@protocol WYInputViewControllerDelegate <NSObject>
@optional
- (void)inputViewControllerWithText:(NSString*)text;
//约战游戏选择
- (void)inputViewControllerWithGameDic:(NSDictionary*)gameDic;

@end
