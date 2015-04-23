//
//  UIImage+HQ.h
//  JFun
//
//  Created by MIQ on 14-11-21.
//  Copyright (c) 2014年 miqu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HQ)
+(instancetype)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
+ (instancetype)rectImageWithName:(NSString *)name leftTopPos:(CGSize)leftTopPos rightBottomPos:(CGSize)rightBottomPos;
+ (instancetype)circleImageWithName:(NSString *)name borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
/*
 *将图片裁剪到指定矩形
 *leftTopPos:矩形区域左上角相对于图片的坐标
 *rightBottomPos:矩形区域右下角相对于图片的坐标
 */
- (instancetype)rectImageWithLeftTopPos:(CGSize)leftTopPos rightBottomPos:(CGSize)rightBottomPos;
@end
