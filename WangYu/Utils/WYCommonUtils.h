//
//  WYCommonUtils.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYUIKitMacro.h"

#define ls_dispatch_main_sync_safe(block)\
if ([NSThread isMainThread])\
{\
block();\
}\
else\
{\
dispatch_sync(dispatch_get_main_queue(), block);\
}

@interface WYCommonUtils : NSObject

/*! @brief 单纯获取text的Width (Height固定的)
 *
 *  @param  text: 文本
 *  @param  font: 字体
 *  @param  lineBreakMode: lineBreakMode 默认为NSLineBreakByWordWrapping = 0
 *  @return text的Width
 */
+ (float)widthWithText:(NSString *)text font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode;

/*! @brief  根据固定的Width 获取text的Size
 *
 *  @param  text:  文本
 *  @param  font:  字体
 *  @param  width: 固定的Width
 *  @return text的Size
 */
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font width:(float)width;


+ (NSString *)fileNameEncodedString:(NSString *)string;

//获取文件夹大小
+ (unsigned long long)getDirectorySizeForPath:(NSString*)path;

+ (UInt32)getDistinctAsciiTextNum:(NSString*)text;
+ (UInt32)getHanziTextNum:(NSString*)text;
+ (NSString*)getHanziTextWithText:(NSString*)text maxLength:(UInt32)maxLength;

+ (NSDictionary *)getParamDictFrom:(NSString *)query;

//拨打电话
+ (void)usePhoneNumAction:(NSString *)phone;

+(UIImage *)getImageFromSDImageCache:(NSString *) imageUrl;

+ (NSString*)stringSplitWithCommaForIds:(NSArray*)ids;

//版本信息
+ (BOOL)isVersion:(NSString *)versionA greaterThanVersion:(NSString *)versionB;

+(BOOL) isIphone4;

@end
