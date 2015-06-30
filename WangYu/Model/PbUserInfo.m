//
//  PbUserInfo.m
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PbUserInfo.h"
#import "PinyinUtils.h"

static NSString *kNameKey = @"1";
static NSString *kPinyinOfNameKey = @"2";
static NSString *kPhoneNumKey = @"3";
static NSString *kRecordIdKey = @"4";

@implementation PbUserInfo

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _name = [decoder decodeObjectForKey:kNameKey];
        _pinyinOfName = [decoder decodeObjectForKey:kPinyinOfNameKey];
        _phoneNUm = [decoder decodeObjectForKey:kPhoneNumKey];
        _recordId = [[decoder decodeObjectForKey:kRecordIdKey] intValue];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_name forKey:kNameKey];
    [encoder encodeObject:_pinyinOfName forKey:kPinyinOfNameKey];
    [encoder encodeObject:_phoneNUm forKey:kPhoneNumKey];
    [encoder encodeObject:[NSNumber numberWithInt:_recordId] forKey:kRecordIdKey];
}



- (void)setName:(NSString *)name{
    _name = name;
    _pinyinOfName = [PinyinUtils Unicode2Pinyin:_name];
}
- (NSComparisonResult)compareByPinyinOfName:(PbUserInfo*)another{
    
    if (self.pinyinOfName.length == 0 && another.pinyinOfName.length != 0) {
        return NSOrderedDescending;
    }else if(self.pinyinOfName.length != 0 && another.pinyinOfName.length == 0){
        return NSOrderedAscending;
    }else if (self.pinyinOfName.length == 0 && another.pinyinOfName.length == 0){
        return [self.name caseInsensitiveCompare:[another name]];
    }
    
    BOOL selfStartWithPinYin = NO;
    BOOL anotherStartWithPinYin = NO;
    unichar selfChar = [self.pinyinOfName characterAtIndex:0];
    unichar anotherChar = [another.pinyinOfName characterAtIndex:0];
    if((selfChar >= 'A' && selfChar <= 'Z') || (selfChar >= 'a' && selfChar <= 'z')){
        selfStartWithPinYin = YES;
    }
    if((anotherChar >= 'A' && anotherChar <= 'Z') || (anotherChar >= 'a' && anotherChar <= 'z')){
        anotherStartWithPinYin = YES;
    }
    if (selfStartWithPinYin && !anotherStartWithPinYin) {
        return NSOrderedAscending;
    }else if (!selfStartWithPinYin && anotherStartWithPinYin) {
        return NSOrderedDescending;
    }
    return [self.pinyinOfName caseInsensitiveCompare:[another pinyinOfName]];
}

@end
