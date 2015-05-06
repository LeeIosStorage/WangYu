//
//  ColorGradView.m
//  WangYu
//
//  Created by KID on 15/5/6.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ColorGradView.h"

@implementation ColorGradView

- (id)initWithFrame:(CGRect)frame FromColorArray:(NSMutableArray*)colorArray ByGradientType:(GradientType)gradientType
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *backImage = [self buttonImageFromColors:colorArray ByGradientType:gradientType];
        [self setImage:backImage];
//        [self setBackgroundImage:backImage forState:UIControlStateNormal];
    }
    return self;
}

- (UIImage*) buttonImageFromColors:(NSArray*)colors ByGradientType:(GradientType)gradientType
{
    NSMutableArray *array = [NSMutableArray array];
    for (UIColor *color in colors) {
        [array addObject:(id)color.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)array, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, self.frame.size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(self.frame.size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(self.frame.size.width, self.frame.size.height);
            break;
        case 3:
            start = CGPointMake(self.frame.size.width, 0.0);
            end = CGPointMake(0.0, self.frame.size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

@end
