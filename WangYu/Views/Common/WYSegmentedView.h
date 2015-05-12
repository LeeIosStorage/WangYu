//
//  WYSegmentedView.h
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^segmentedButtonClickBlock)(NSInteger index);

@interface WYSegmentedView : UIView

@property (nonatomic,strong) segmentedButtonClickBlock segmentedButtonClickBlock;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) NSUInteger selectIndex;

@end
