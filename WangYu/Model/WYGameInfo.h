//
//  WYGameInfo.h
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYGameInfo : NSObject

@property(nonatomic, strong) NSString* gameId;
@property(nonatomic, strong) NSString* gameName;
@property(nonatomic, strong) NSString* gameIntro;
@property(nonatomic, strong) NSString* gameIcon;
@property(nonatomic, readonly) NSURL* gameIconUrl;

@property(nonatomic, strong) NSDictionary* gameInfoByJsonDic;

@end
