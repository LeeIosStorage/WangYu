//
//  WYUIUtils.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYUIUtils.h"
#import "WYAlertView.h"
#import "WYSystem.h"
#import "UIImage+Resize.h"

#define DAY_SECOND 60*60*24

@implementation WYUIUtils

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

#pragma mark -- adapter ios 7
+(BOOL)updateFrameWithView:(UIView *)view superView:(UIView *)superView isAddHeight:(BOOL)isAddHeight
{
    return [self updateFrameWithView:view superView:superView isAddHeight:isAddHeight delHeight:STAUTTAR_DEFAULT_HEIGHT];
}

+(BOOL)updateFrameWithView:(UIView *)view superView:(UIView *)superView isAddHeight:(BOOL)isAddHeight delHeight:(CGFloat)height
{
    CGRect viewFrame = view.frame;
    if (isAddHeight) {
        viewFrame.size.height += height;
    }else{
        //view是相对super和底部的就不改位置
        UIViewAutoresizing resizeMask = view.autoresizingMask;
        if (resizeMask & UIViewAutoresizingFlexibleTopMargin) {
            return YES;
        }
        
        //如果tableview的大小与parent大小是一样的话就不移
        if (view.frame.size.height >= superView.frame.size.height) {
            return NO;
        }
        
        //如果view是跟scrollview并从parent的顶开始的也不移
        if (view.frame.origin.y <= 0 && [view isKindOfClass:[UIScrollView class]]) {
            return NO;
        }
    }
    view.frame = viewFrame;
    
    return YES;
}

+(void)showAlertWithMsg:(NSString *)msg
{
    [self showAlertWithMsg:msg title:nil];
}

+(void)showAlertWithMsg:(NSString *)msg title:(NSString *) title
{
    WYAlertView *alert = [[WYAlertView alloc] initWithTitle:title message:msg cancelButtonTitle:@"确定"];
    [alert show];
}

+ (int)getAgeByDate:(NSDate*)date{
    NSDate* nowDate = [NSDate date];
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calender components:unitFlags fromDate:nowDate];
    return (int)compsNow.year - (int)comps.year;
}

+(NSDateFormatter *) dateFormatterOFUS {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    return dateFormatter;
}

static NSDateFormatter * s_dateFormatterOFUS = nil;
static bool dateFormatterOFUSInvalid ;
+ (NSDate*)dateFromUSDateString:(NSString*)string{
    if (![string isKindOfClass:[NSString class]]) {
        return nil;
    }
    @synchronized(self) {
        if (s_dateFormatterOFUS == nil || dateFormatterOFUSInvalid) {
            s_dateFormatterOFUS = [[NSDateFormatter alloc] init];
            [s_dateFormatterOFUS setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//EEE MMM d HH:mm:ss zzzz yyyy
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [s_dateFormatterOFUS setLocale:usLocale];
            dateFormatterOFUSInvalid = NO;
        }
    }
    
    NSDateFormatter* dateFormatter = s_dateFormatterOFUS;
    NSDate* date = nil;
    @synchronized(dateFormatter){
        @try {
            date = [dateFormatter dateFromString:string];
        }
        @catch (NSException *exception) {
            //异常了以后处理有些问题,有可能会crash
            dateFormatterOFUSInvalid = YES;
        }
    }
    return date;
}

+(NSDateComponents *) dateComponentsFromDate:(NSDate *) date{
    if (!date) {
        return nil;
    }
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit ;
    return [calender components:unitFlags fromDate:date];
}

+ (NSString*)dateYearToDayDiscriptionFromDate:(NSDate*)date{
    NSString *_timestamp = nil;
    if (date == nil) {
        return @"";
    }
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    
    _timestamp = [NSString stringWithFormat:@"%04d.%02d.%02d", (int)comps.year, (int)comps.month, (int)comps.day];
    
    return _timestamp;
}

+ (NSString*)dateYearToMinuteDiscriptionFromDate:(NSDate*)date{
    NSString *_timestamp = nil;
    if (date == nil) {
        return @"";
    }
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    
    _timestamp = [NSString stringWithFormat:@"%04d.%02d.%02d %02d:%02d", (int)comps.year, (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
    
    return _timestamp;
}

+ (NSString*)dateDiscriptionFromDate:(NSDate*)date{
    NSString *_timestamp = nil;
    NSDate* nowDate = [NSDate date];
    if (date == nil) {
        return @"";
    }
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calender components:unitFlags fromDate:nowDate];
    
    if (comps.year == compsNow.year){
        _timestamp = [NSString stringWithFormat:@"%d月%d日 %02d:%02d", (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
    } else {
        _timestamp = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d", (int)comps.year, (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
    }
    
    return _timestamp;
}

+ (NSString*)dateDiscriptionFromNowBk:(NSDate*)date{
    NSString *_timestamp = nil;
    NSDate* nowDate = [NSDate date];
    if (date == nil) {
        return @"";
    }
    int distance = [nowDate timeIntervalSinceDate:date];
    if (distance < 0) distance = 0;
    NSCalendar * calender = [NSCalendar currentCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calender components:unitFlags fromDate:nowDate];
    
    if (distance >= 0) {
        if (distance < 60) {
            _timestamp = [NSString stringWithFormat:@"%@", @"刚刚"];
        } else if (distance < 60*60) {
            _timestamp = [NSString stringWithFormat:@"%d%@", distance/60, @"分钟前"];
        }else if (distance < DAY_SECOND) {
            if (comps.day == compsNow.day)
            {
                _timestamp = [NSString stringWithFormat:@"今天 %02d:%02d", (int)comps.hour,(int)comps.minute];
            }
            else
                _timestamp = [NSString stringWithFormat:@"昨天 %02d:%02d", (int)comps.hour,(int)comps.minute];
        }
        //    else if (distance < DAY_SECOND*2) {
        ////        compsNow.hour = compsNow.minute = compsNow.second = 0;
        ////        NSDate *startOfToday = [calender dateFromComponents:compsNow];
        ////        distance = [startOfToday timeIntervalSinceDate:date];
        //        if ((comps.day == compsNow.day-1) || (comps.day != compsNow.day-1 && comps.day > compsNow.day-1)) {
        //            _timestamp = [NSString stringWithFormat:@"昨天 %02d:%02d", (int)comps.hour,(int)comps.minute];
        //        }else{
        //            _timestamp = [NSString stringWithFormat:@"前天 %02d:%02d", (int)comps.hour,(int)comps.minute];
        //        }
        //    }else if (distance < DAY_SECOND*3) {
        ////        compsNow.hour = compsNow.minute = compsNow.second = 0;
        ////        NSDate *startOfToday = [calender dateFromComponents:compsNow];
        ////        distance = [startOfToday timeIntervalSinceDate:date];
        //        if ((comps.day == compsNow.day-2) || (comps.day != compsNow.day-2 && comps.day > compsNow.day-2)){
        //            _timestamp = [NSString stringWithFormat:@"前天 %02d:%02d", (int)comps.hour,(int)comps.minute];
        //        }else{
        //            _timestamp = [NSString stringWithFormat:@"%d月%d日 %02d:%02d", (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
        //        }
        //    }
        else {
            compsNow.hour = compsNow.minute = compsNow.second = 0;
            NSDate *startOfToday = [calender dateFromComponents:compsNow];
            distance = [startOfToday timeIntervalSinceDate:date];
            if (distance <= DAY_SECOND) {
                _timestamp = [NSString stringWithFormat:@"昨天 %02d:%02d", (int)comps.hour,(int)comps.minute];
            }
            else{
                if (comps.year == compsNow.year){
                    _timestamp = [NSString stringWithFormat:@"%d月%d日 %02d:%02d", (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
                } else {
                    _timestamp = [NSString stringWithFormat:@"%04d年%02d月%02d日 %02d:%02d", (int)comps.year, (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
                }
            }
        }
    }else{
        _timestamp = [NSString stringWithFormat:@"%04d年%02d月%02d日 %02d:%02d", (int)comps.year, (int)comps.month, (int)comps.day, (int)comps.hour, (int)comps.minute];
    }
    
    return _timestamp;
}

+ (NSString*)dateDiscription1FromNowBk:(NSDate*)date{
    NSString *_timestamp = nil;
    NSDate* nowDate = [NSDate date];
    if (date == nil) {
        return @"";
    }
    int distance = [nowDate timeIntervalSinceDate:date];
    if (distance < 0) distance = 0;
    //    NSCalendar * calender = [NSCalendar currentCalendar];
    //    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
    //    NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit | NSWeekdayCalendarUnit;
    //    NSDateComponents *comps = [calender components:unitFlags fromDate:date];
    //    NSDateComponents *compsNow = [calender components:unitFlags fromDate:nowDate];
    
    if (distance < 0) {
        distance = 0;
    }
    if (distance < DAY_SECOND*30) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance/60/60/24, @"天"];
    } else if (distance < DAY_SECOND*365) {
        _timestamp = [NSString stringWithFormat:@"%d%@%d%@",distance/60/60/24/30,@"个月",distance/60/60/24%30,@"天"];
    } else if (distance < DAY_SECOND*365*6){
        _timestamp = [NSString stringWithFormat:@"%d%@%d%@",distance/60/60/24/365,@"岁",distance/60/60/24%365/30,@"个月"];
    } else {
        _timestamp = [NSString stringWithFormat:@"%d%@",distance/60/60/24/365,@"岁"];
    }
    
    //    if (distance < 60) {
    //        _timestamp = [NSString stringWithFormat:@"%d%@", distance, @"秒前"];
    //    } else if (distance < 60*60) {
    //        _timestamp = [NSString stringWithFormat:@"%d%@", distance/60, @"分钟前"];
    //    }else if (distance < DAY_SECOND) {
    //        _timestamp = [NSString stringWithFormat:@"%d%@", distance/60/60, @"小时前"];
    //    }else if (distance < DAY_SECOND*7) {
    //        _timestamp = [NSString stringWithFormat:@"%d%@", distance/60/60/24, @"天前"];
    //    }else {
    //        if (comps.year == compsNow.year){
    //            _timestamp = [NSString stringWithFormat:@"%02d-%02d", comps.month,comps.day];
    //        } else {
    //            _timestamp = [NSString stringWithFormat:@"%04d-%02d-%02d", comps.year,comps.month,comps.day];
    //        }
    //    }
    
    return _timestamp;
}

+ (int)distanceSinceNowCompareDate:(NSDate*)date{
    NSDate* nowDate = [NSDate date];
    if (date == nil) {
        return 0;
    }
    int distance = [date timeIntervalSinceDate:nowDate];
    return distance;
}
+ (NSString *)secondChangToDateString:(NSString *)dateStr {
    
    if (dateStr.length == 0) {
        return @"";
    }
    
    long long time = [dateStr longLongValue];
    int hour = (int)time/(60*60);
    int minute = (time/60)%60;
    int second = time%60;
    
    NSString *ts = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute,second];
    return ts;
}

+ (NSString*)documentOfCameraDenied
{
    return @"请检查设备是否有相机功能";
}
+ (NSString*)documentOfAVCaptureDenied
{
    return @"无法访问你的相机。\n请到手机系统的[设置]->[隐私]->[相机]允许网娱大师使用相机";
}

+ (NSString*)documentOfLocationDenied {
    return @"无法获取你的位置信息。\n请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务，并允许网娱大师使用定位服务";
}
+ (NSString*)documentOfAssetsLibraryDenied {
    NSString *errorString = nil;
    double version = [[[UIDevice currentDevice] systemVersion] doubleValue];
    if (version > 6.0) {
        errorString = @"网娱大师没有权限访问您的相册,请在【隐私】【照片】中允许【网娱大师】访问";
    }else{
        errorString = @"网娱大师没有权限访问您的相册,请打开您的【定位服务】";
    }
    return errorString;
}

+ (UIImage*)scaleImage:(UIImage*)image toSize:(CGSize)size {
    return [image resizedImage:size interpolationQuality:0];
}
#define LS_MAX_IMAGE_WIDTH  640.0
+ (UIImage*)addOperationAsset:(ALAsset *) asset
{
    NSLog(@"########start");
    
    UIImage* image = nil;
    //只有长图才去压缩，一般的图直接取fullScreenImage
    CGSize fullResolutionImageSize = [UIScreen mainScreen].bounds.size;
    
    if ([asset.defaultRepresentation respondsToSelector:@selector(dimensions)]) {
        fullResolutionImageSize = asset.defaultRepresentation.dimensions;
    } else {
        fullResolutionImageSize.width = CGImageGetWidth(asset.defaultRepresentation.fullResolutionImage);
        fullResolutionImageSize.height = CGImageGetHeight(asset.defaultRepresentation.fullResolutionImage);
    }
    
    if (fullResolutionImageSize.height/fullResolutionImageSize.width > [UIScreen mainScreen].bounds.size.height/[UIScreen mainScreen].bounds.size.width) {
        CFTimeInterval tick = CACurrentMediaTime();
        image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:1.0 orientation:(NSInteger)asset.defaultRepresentation.orientation];
        NSLog(@"imageWithCGImage tick=%f", CACurrentMediaTime() -tick);
        
        if (MIN(image.size.width, image.size.height) > LS_MAX_IMAGE_WIDTH) {
            CGSize newSize = image.size;
            if (image.size.width == MIN(image.size.width, image.size.height)) {
                newSize.width = LS_MAX_IMAGE_WIDTH;
                newSize.height = image.size.height/(image.size.width/LS_MAX_IMAGE_WIDTH);
            } else {
                newSize.height = LS_MAX_IMAGE_WIDTH;
                newSize.width = image.size.width/(image.size.height/LS_MAX_IMAGE_WIDTH);
            }
            //                @synchronized(_selectedAssetsSet){
            //                    if (![_selectedAssetsSet containsObject:asset]) {
            //                        return ;
            //                    }
            //                }
            image = [WYUIUtils scaleImage:image toSize:newSize];
            //image = [image imageScaledToFitSize:newSize];
        }
        NSLog(@"scaleImage tick=%f", CACurrentMediaTime() -tick);
    } else {
        image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    }
    
    if (image == nil) {
        image = [[UIImage alloc] init];
    }
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            @synchronized(_selectedAssetsSet) {
    //                if ([self.selectedAssetsSet containsObject:asset]) {
    //                    [[self selectedImageDic] setObject:image forKey:[NSNumber numberWithInt:(int)asset]];
    //                }
    //            }
    //        });
    NSLog(@"########stop");
    return image;
}

//计算textview的高度
+(CGFloat) calculateTextViewMaxHeight:(UITextView *) textview
{
    return [self calculateTextViewHeight:textview];
}
+(CGFloat) calculateTextViewHeight:(UITextView *) textView
{
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        CGRect txtFrame = textView.frame;
        //@"%@\n "
        return [[NSString stringWithFormat:@"%@\n ",textView.text]                boundingRectWithSize:CGSizeMake(txtFrame.size.width - textView.contentInset.left - textView.contentInset.right, CGFLOAT_MAX)
                                                                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                            attributes:[NSDictionary dictionaryWithObjectsAndKeys:textView.font,NSFontAttributeName, nil] context:nil].size.height;
    }
    return textView.contentSize.height ;
}
+(CGSize) reSizeTextViewContentSize:(UITextView *) textview
{
    if ([textview respondsToSelector:@selector(textContainerInset)]) {
        NSRange oringalRange = textview.selectedRange;
        textview.selectedRange = NSMakeRange(textview.text.length, 0);
        CGRect line = [textview caretRectForPosition:
                       textview.selectedTextRange.start];
        
        UIEdgeInsets inset = textview.textContainerInset;
        CGSize newSize = CGSizeMake(ceil(line.size.width)  + inset.left + inset.right,
                                    ceil(line.size.height + line.origin.y) + inset.top);
        textview.contentSize = newSize;
        
        //还原原始光标
        textview.selectedRange = oringalRange;
    }
    
    return textview.contentSize;
}

#define ASSET_VIEW_FRAME CGRectMake(0, 0, 75, 75)
#define ASSET_VIEW_PADDING 4
+(CGRect)getAssetViewFrame{
    
    double tmpPerRowF = SCREEN_WIDTH / (ASSET_VIEW_FRAME.size.width + ASSET_VIEW_PADDING);
    int tmpPerRowI = tmpPerRowF;
    
    CGRect asset_view_frame = ASSET_VIEW_FRAME;
    float assetViewWidth = (SCREEN_WIDTH-ASSET_VIEW_PADDING*(tmpPerRowI+1))/tmpPerRowI;
    asset_view_frame.size.width = assetViewWidth;
    asset_view_frame.size.height = assetViewWidth;
    return asset_view_frame;
}

+ (UIFont*)customFontWithPath:(NSString*)path size:(CGFloat)size
{
    NSURL *fontUrl = [NSURL fileURLWithPath:path];
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL((__bridge CFURLRef)fontUrl);
    CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataProvider);
    CGDataProviderRelease(fontDataProvider);
    CTFontManagerRegisterGraphicsFont(fontRef, NULL);
    NSString *fontName = CFBridgingRelease(CGFontCopyPostScriptName(fontRef));
    UIFont *font = [UIFont fontWithName:fontName size:size];
    CGFontRelease(fontRef);
    return font;
}

+ (UIFont*)customFontWithFontName:(NSString*)fontName size:(CGFloat)size{
    UIFont *font = [UIFont fontWithName:fontName size:size];//HiraginoSansGB-W3
    return font;
}

#pragma CATransition动画实现
+ (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView : (UIView *) view
{
    /*
     * type  @"oglFlip":翻转,@"rippleEffect":波纹
     */
    CATransition *animation = [CATransition animation];
    animation.duration = 0.4f;
    animation.type = type;
    if (subtype != nil) {
        animation.subtype = subtype;
    }
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
}

@end
