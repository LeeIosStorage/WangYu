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
@property(nonatomic, strong) NSString* gameDes;
@property(nonatomic, strong) NSString* version;
@property(nonatomic, strong) NSString* downloadUrl;
@property(nonatomic, assign) int iosFileSize;
@property(nonatomic, assign) int downloadCount;
@property(nonatomic, assign) int favorCount;

@property(nonatomic, strong) NSString* gameCover;//手游封面图
@property(nonatomic, readonly) NSURL* gameCoverUrl;
@property(nonatomic, strong) NSString* gameIcon;//手游小图标
@property(nonatomic, readonly) NSURL* gameIconUrl;

@property(nonatomic, strong) NSMutableArray *coverIds;//封面imgs
@property(nonatomic, readonly) NSArray* coverURLs;

@property(nonatomic, strong) NSDictionary* gameInfoByJsonDic;

@end
