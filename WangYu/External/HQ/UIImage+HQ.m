//
//  UIImage+HQ.m
//  JFun
//
//  Created by MIQ on 14-11-21.
//  Copyright (c) 2014年 miqu. All rights reserved.
//

#import "UIImage+HQ.h"

@implementation UIImage (HQ)

+(instancetype)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }
        else{
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor
{
    // 1.加载原图
    UIImage *oldImage = [UIImage imageNamed:name];
    
    // 2.开启上下文
    CGFloat imageW = oldImage.size.width + 2 * borderWidth;
    CGFloat imageH = oldImage.size.height + 2 * borderWidth;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    [borderColor set];
    CGFloat bigRadius = imageW * 0.5; // 大圆半径
    CGFloat centerX = bigRadius; // 圆心
    CGFloat centerY = bigRadius;
    CGContextAddArc(ctx, centerX, centerY, bigRadius, 0, M_PI * 2, 0);
    CGContextFillPath(ctx); // 画圆
    
    // 5.小圆
    CGFloat smallRadius = bigRadius - borderWidth;
    CGContextAddArc(ctx, centerX, centerY, smallRadius, 0, M_PI * 2, 0);
    // 裁剪(后面画的东西才会受裁剪的影响)
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(borderWidth, borderWidth, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

/*
 *将图片裁剪到指定矩形
 *leftTopPos:矩形区域左上角相对于图片的坐标
 *rightBottomPos:矩形区域右下角相对于图片的坐标
 */
+ (instancetype)rectImageWithName:(NSString *)name leftTopPos:(CGSize)leftTopPos rightBottomPos:(CGSize)rightBottomPos
{
    // 1.加载原图
    UIImage *oldImage = [UIImage imageNamed:name];
    
    // 2.开启上下文
    CGFloat imageW = rightBottomPos.width - leftTopPos.width;
    CGFloat imageH = rightBottomPos.height - leftTopPos.height;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    CGContextAddRect(ctx, CGRectMake(leftTopPos.width, leftTopPos.height, rightBottomPos.width - leftTopPos.width, rightBottomPos.height - leftTopPos.height));
    CGContextFillPath(ctx); // 画出裁剪区域
    CGContextClip(ctx);
    
    // 6.画图
    [oldImage drawInRect:CGRectMake(-leftTopPos.width, -leftTopPos.height, oldImage.size.width, oldImage.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (instancetype)rectImageWithLeftTopPos:(CGSize)leftTopPos rightBottomPos:(CGSize)rightBottomPos
{
    
    // 2.开启上下文
    CGFloat imageW = rightBottomPos.width - leftTopPos.width;
    CGFloat imageH = rightBottomPos.height - leftTopPos.height;
    CGSize imageSize = CGSizeMake(imageW, imageH);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    
    // 3.取得当前的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 4.画边框(大圆)
    CGContextAddRect(ctx, CGRectMake(leftTopPos.width, leftTopPos.height, rightBottomPos.width - leftTopPos.width, rightBottomPos.height - leftTopPos.height));
    CGContextFillPath(ctx); // 画出裁剪区域
    //    CGContextClip(ctx);
    
    // 6.画图
    [self drawInRect:CGRectMake(-leftTopPos.width, -leftTopPos.height, self.size.width, self.size.height)];
    
    // 7.取图
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 8.结束上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
