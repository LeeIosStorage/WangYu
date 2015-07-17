//
//  NSString+Value.h
//  jfun
//
//  Created by KID on 14/10/29.
//  Copyright (c) 2014年 FanShang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Value)

- (BOOL)isPhone;
- (BOOL)isEmail;
//检测phone是否合法
- (BOOL)isValidatePhone;
//检测email是否合法
- (BOOL)isValidateEmail;
//身份证验证
- (BOOL) validateIdentityCard;

//统计混编字符
- (int)      GetLength;
//计算字符宽度
- (CGFloat)  GetWidth:(CGFloat)Height Font:(UIFont *)Font;
//计算字符高度
- (CGFloat)  GetHeight:(CGFloat)Width Font:(UIFont *)Font;
//判断是否数字
- (BOOL)     GetFigure:(BOOL)Point;

//字符转换图片
- (NSData *) GetDataImage;
//字符计算时差
- (NSTimeInterval)GetTimeValue;

@end
