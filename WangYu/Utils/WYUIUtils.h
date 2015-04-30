//
//  WYUIUtils.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "WYUIKitMacro.h"

@interface WYUIUtils : NSObject

+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

#pragma mark -- adapter ios7
/*! @brief 改变view的大小, 主要是适配ios7的stautar 如果是addHeight的就添加高度，把y为-statusBar.frame.size.height,不为add时就往下移
 *
 */
+(BOOL)updateFrameWithView:(UIView *)view superView:(UIView *)superView isAddHeight:(BOOL)isAddHeight;

/*! @brief 改变view的大小, 主要是适配ios7的stautar 如果是addHeight的就添加高度，把y为-height,不为add时就往下移
 *
 */
+(BOOL)updateFrameWithView:(UIView *)view superView:(UIView *)superView isAddHeight:(BOOL)isAddHeight delHeight:(CGFloat)height;

+(void)showAlertWithMsg:(NSString *)msg;
+(void)showAlertWithMsg:(NSString *)msg title:(NSString *) title;

//年龄
+ (int)getAgeByDate:(NSDate*)date;
+ (NSString*)dateDiscriptionFromDate:(NSDate*)date;
+ (NSString*)dateDiscriptionFromNowBk:(NSDate*)date;
+ (NSString*)dateDiscription1FromNowBk:(NSDate*)date;
+ (int)distanceSinceNowCompareDate:(NSDate*)date;
+ (NSString *)secondChangToDateString:(NSString *)dateStr;

+ (NSDateFormatter *) dateFormatterOFUS;
+ (NSDate*)dateFromUSDateString:(NSString*)string;
+ (NSDateComponents *) dateComponentsFromDate:(NSDate *) date;

+ (NSString*)documentOfCameraDenied;
+ (NSString*)documentOfAVCaptureDenied;
+ (NSString*)documentOfAssetsLibraryDenied;

+ (NSString*)documentOfLocationDenied;

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size;
+ (UIImage*)addOperationAsset:(ALAsset *) asset;

//计算textview的高度
+(CGFloat) calculateTextViewMaxHeight:(UITextView *) textview;
+(CGSize) reSizeTextViewContentSize:(UITextView *) textview;

+(CGRect)getAssetViewFrame;

//自定义冬青字体
+ (UIFont*)customFontWithPath:(NSString*)path size:(CGFloat)size;

@end
