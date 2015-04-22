//
//  WYCommonUtils.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYCommonUtils.h"
#import "XEAlertView.h"
#import "SDImageCache.h"

@implementation WYCommonUtils

+ (float)widthWithText:(NSString *)text font:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    float titleLabelWidth = [text sizeWithAttributes:attributes].width;
    return titleLabelWidth;
}

+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font width:(float)width{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return textSize;
}

+ (NSString *)fileNameEncodedString:(NSString *)string
{
    if (![string length])
        return @"";
    
    CFStringRef static const charsToEscape = CFSTR(".:/");
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                        (__bridge CFStringRef)string,
                                                                        NULL,
                                                                        charsToEscape,
                                                                        kCFStringEncodingUTF8);
    return (__bridge_transfer NSString *)escapedString;
}

+ (unsigned long long)getDirectorySizeForPath:(NSString*)path {
    unsigned long long size = 0;
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}

+ (UInt32)getDistinctAsciiTextNum:(NSString*)text {
    UInt32 count = 0;
    
    for (int i = 0; i < text.length; ++i) {
        unichar c = [text characterAtIndex:i];
        if (c < 128) {
            count += 1;
        } else {
            count += 2;
        }
    }
    
    return count;
}
+ (UInt32)getHanziTextNum:(NSString*)text {
    UInt32 count = [WYCommonUtils getDistinctAsciiTextNum:text];
    return (count/2 + count%2);
}
+ (NSString*)getHanziTextWithText:(NSString*)text maxLength:(UInt32)maxLength {
    UInt32 count = 0;
    
    for (int i = 0; i < text.length; ++i) {
        unichar c = [text characterAtIndex:i];
        if (c < 128) {
            count += 1;
        } else {
            count += 2;
        }
        if ((count/2 + count%2) > maxLength) {
            //判断截取的最后几个字符是不是emoji表情，如果是emoji表情要把表情整体截取，不然会出现乱码的情况
            //emoji最多占用4个unicode码，所以index回退3个
            int backIndex = (i - 3) >0 ? (i - 3):0;
            for (int j = backIndex; j < text.length; ++j) {
                NSRange range = [text rangeOfComposedCharacterSequenceAtIndex:j];
                if (range.length > 1) {
                    if (range.location + range.length > i) {
                        return [text substringToIndex:range.location];
                    }
                    j = (int)range.location + (int)range.length;
                }
            }
            
            return [text substringToIndex:i];
        }
    }
    return text;
}

+(NSDictionary *)getParamDictFrom:(NSString *)query{
    NSArray *qitems = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *qdic = [NSMutableDictionary dictionaryWithCapacity:qitems.count];
    for (NSString *item in qitems) {
        NSArray *params = [item componentsSeparatedByString:@"="];
        //确保有两个
        if (params.count == 2) {
            NSString *paramdata = [params objectAtIndex:1];
            NSString *data = [[paramdata stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                [qdic setObject:data forKey:[params objectAtIndex:0]];
            }
        }
        
    }
    return qdic;
}

+ (void)usePhoneNumAction:(NSString *)phone{
    if (phone.length == 0 || !phone) {
        return;
    }
    XEAlertView *alertView = [[XEAlertView alloc] initWithTitle:nil message:phone cancelButtonTitle:@"取消" cancelBlock:nil okButtonTitle:@"呼叫" okBlock:^{
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", phone]];
        [[UIApplication sharedApplication] openURL:URL];
    }];
    [alertView show];
}

+(UIImage *)getImageFromSDImageCache:(NSString *) imageUrl
{
    if (!imageUrl) {
        return nil;
    }
    
    SDImageCache *imageCahe = [SDImageCache sharedImageCache];
    UIImage *image = [imageCahe imageFromDiskCacheForKey:imageUrl];
    
    return image;
}

+ (NSString*)stringSplitWithCommaForIds:(NSArray*)ids {
    NSMutableString * idsString = [[NSMutableString alloc] init];
    for (NSString* uid in ids) {
        if (idsString.length > 0) {
            [idsString appendString:@","];
        }
        [idsString appendString:uid.description];
    }
    return idsString;
}

+ (BOOL)isVersion:(NSString *)versionA greaterThanVersion:(NSString *)versionB {
    NSArray *versionAArray = [versionA componentsSeparatedByString:@"."];
    NSArray *versionBArray = [versionB componentsSeparatedByString:@"."];
    
    for (NSInteger i=0; i < versionAArray.count; i++) {
        if (i >= versionBArray.count) {
            if ([[versionAArray objectAtIndex:i] integerValue] > 0) {
                return YES;
            }else {
                continue;
            }
        }
        if ([[versionAArray objectAtIndex:i] integerValue]>[[versionBArray objectAtIndex:i] integerValue]) {
            return TRUE;
        } else if ([[versionAArray objectAtIndex:i] integerValue]<[[versionBArray objectAtIndex:i] integerValue]) {
            return FALSE;
        }
    }
    return FALSE;
}

@end
