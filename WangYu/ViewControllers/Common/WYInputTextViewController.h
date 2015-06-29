//
//  WYInputTextViewController.h
//  WangYu
//
//  Created by Leejun on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"

@protocol WYInputTextViewControllerDelegate;
@interface WYInputTextViewController : WYSuperViewController

@property(nonatomic, assign)id<WYInputTextViewControllerDelegate> delegate;
@property(nonatomic, strong) NSString* oldText;
@property(nonatomic, strong) NSString* titleText;
@property(nonatomic, strong) NSString* placeHolder;
@property(nonatomic, assign) int maxTextLength;
@property(nonatomic, assign) int minTextLength;
@property(nonatomic, assign) float maxTextViewHight;
@property(nonatomic, strong) NSString* toolRightType;
@property(nonatomic, assign) UIKeyboardType keyboardType;
@end
@protocol WYInputTextViewControllerDelegate <NSObject>

@optional
- (void)inputTextViewControllerWithText:(NSString*)text;

@end
