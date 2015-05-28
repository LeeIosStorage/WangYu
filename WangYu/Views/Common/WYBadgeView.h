//
//  WYBadgeView.h
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYBadgeView : UIView

@property(nonatomic,strong) NSString* text;
@property(nonatomic,strong) UIFont* font;
@property(nonatomic, assign)int unreadNum;

//更新背景色
-(void)updateBadgeViewImage:(NSString *) imageName;

@end
