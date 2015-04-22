//
//  UIColor+bit.h
//  LanShan
//
//  Created by Sara on 14-2-22.
//  Copyright (c) 2014年 HZMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (bit)

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;

@end
