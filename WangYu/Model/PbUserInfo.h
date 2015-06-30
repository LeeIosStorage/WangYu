//
//  PbUserInfo.h
//  WangYu
//
//  Created by Leejun on 15/6/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PbUserInfo : NSObject<NSCoding>

@property(nonatomic, strong) NSString* name;
@property(nonatomic, readonly) NSString* pinyinOfName;
@property(nonatomic, strong) NSString* phoneNUm;
@property(nonatomic, assign) int recordId;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, assign) BOOL invited;
- (NSComparisonResult)compareByPinyinOfName:(PbUserInfo*)another;

@end
