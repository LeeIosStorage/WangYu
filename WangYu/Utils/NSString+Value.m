//
//  NSString+Value.m
//  jfun
//
//  Created by KID on 14/10/29.
//  Copyright (c) 2014年 FanShang. All rights reserved.
//

#import "NSString+Value.h"

@implementation NSString (Value)

- (BOOL)isPhone
{
    if (self.length == 11)
    {
        NSScanner *Scanner = [NSScanner scannerWithString:self];
        int Value;
        return [Scanner scanInt:&Value] && [Scanner isAtEnd];
    }
    return NO;
}

- (BOOL)isValidatePhone{
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:self];
    if (!isMatch) {
        return NO;
    }
    return YES;
}

- (BOOL)isEmail
{
    if (self.length >= 5)
    {
        if (([self rangeOfString:@"@"].location != NSNotFound) &&
            ([self rangeOfString:@"."].location != NSNotFound))
            return YES;
    }
    return NO;
}

- (BOOL)isValidateEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
- (BOOL) validateIdentityCard
{
    BOOL flag;
    if (self.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:self];
}

- (int) GetLength
{
    int Length = 0;
    char * P = (char *)  [self cStringUsingEncoding:      NSUnicodeStringEncoding];
    for (int i = 0 ; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++)
    {
        if (*P)
        {
            P++;
            Length++;
        }
        else
            P++;
    }
    return Length;
}

- (CGFloat)GetWidth:(CGFloat)Height Font:(UIFont *)Font
{
    CGSize  Size = [self boundingRectWithSize: CGSizeMake(MAXFLOAT, Height)
                                      options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:Font, NSFontAttributeName,nil]
                                      context: nil].size;
    return  Size.width;
}

- (CGFloat)GetHeight:(CGFloat)Width Font:(UIFont *)Font
{
    CGSize  Size = [self boundingRectWithSize: CGSizeMake(Width, MAXFLOAT)
                                      options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                   attributes:[NSDictionary dictionaryWithObjectsAndKeys:Font, NSFontAttributeName,nil]
                                      context: nil].size;
    return  Size.height;
}

- (BOOL) GetFigure:(BOOL)Point
{
    BOOL OK = YES;
    NSCharacterSet *Set;
    if (Point)
        Set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    else
        Set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < self.length)
    {
        NSString *String = [self substringWithRange:NSMakeRange(i, 1)];
        NSRange Range = [String rangeOfCharacterFromSet:Set];
        if (Range.length == 0)
        {
            OK = NO;
            break;
        }
        i++;
    }
    return OK;
}

- (NSData *)GetDataImage
{
    NSString *STR = self;
    STR = [STR stringByReplacingOccurrencesOfString:@"<" withString:@""];
    STR = [STR stringByReplacingOccurrencesOfString:@">" withString:@""];
    STR = [STR stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    Byte Bytes[STR.length];
    int J = 0;
    for(int i = 0; i < STR.length; i++)
    {
        int int_CH;
        
        unichar Hex_Char1 = [STR characterAtIndex:i];
        int int_CH1;
        if (Hex_Char1 >= '0' && Hex_Char1 <= '9')
            int_CH1 = (Hex_Char1 - 48) * 16;
        else if (Hex_Char1 >= 'A' && Hex_Char1 <= 'F')
            int_CH1 = (Hex_Char1 - 55) * 16;
        else
            int_CH1 = (Hex_Char1 - 87) * 16;
        i++;
        
        unichar Hex_Char2 = [STR characterAtIndex:i];
        int int_CH2;
        if (Hex_Char2 >= '0' && Hex_Char2 <= '9')
            int_CH2 = (Hex_Char2 - 48);
        else if (Hex_Char1 >= 'A' && Hex_Char1 <= 'F')
            int_CH2 = (Hex_Char2 - 55);
        else
            int_CH2 = (Hex_Char2 - 87);
        
        int_CH = int_CH1 + int_CH2;
        Bytes[J] = int_CH;
        J++;
    }
    return  [[NSData alloc]initWithBytes:Bytes length:STR.length];
}

- (NSTimeInterval) GetTimeValue
{
    NSInteger H = 0, M = 0, S = 0;
    NSArray *Time = [self componentsSeparatedByString:@":"];
    S = [[Time objectAtIndex:Time.count - 1] integerValue];
    M = [[Time objectAtIndex:Time.count - 2] integerValue];
    if   (Time.count > 2)
        H = [[Time objectAtIndex:0]              integerValue];
    return H * 3600 + M * 60 + S;
}

@end
