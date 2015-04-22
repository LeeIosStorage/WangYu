//
//  UIColor+bit.m
//  LanShan
//
//  Created by Sara on 14-2-22.
//  Copyright (c) 2014年 HZMC. All rights reserved.
//

#import "UIColor+bit.h"

@implementation UIColor (bit)

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity
{
    float red = ((float)((hexColor & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexColor & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexColor & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:opacity];
}


+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGFloat)red{
    return CGColorGetComponents(self.CGColor)[0];
}

- (CGFloat)green{
    return CGColorGetComponents(self.CGColor)[1];
}

- (CGFloat)blue{
    return CGColorGetComponents(self.CGColor)[2];
}

@end
