//
//  WYMessageInfo.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYMessageInfo : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* content;
@property(nonatomic, assign) int type;
@property(nonatomic, strong) NSDate* createDate;

@property(nonatomic, strong) NSDictionary* messageInfoByJsonDic;

@end
