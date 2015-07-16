//
//  WYThemeInfo.h
//  WangYu
//
//  Created by XuLei on 15/7/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 广告类型
 */
typedef enum ThemeType_{
    Theme_Netbar = 1,         //网吧类广告 1
    Theme_Game,               //游戏类广告 2
    Theme_Match,              //比赛类广告 3
    Theme_Activity,           //活动类广告 4
    Theme_Other,              //其它类广告 5
}ThemeType;

@interface WYThemeInfo : NSObject

@property (nonatomic, strong) NSString *targetId;
@property (nonatomic, strong) NSString *thumbImageUrl;
@property (nonatomic, strong) NSString *middelImageUrl;
@property (nonatomic, strong) NSString *originalImageUrl;
@property (nonatomic, assign) int themeType;
@property (nonatomic, strong) NSString *themeActionUrl;
@property (nonatomic, readonly) NSString* realUrlHost;

@property (nonatomic, readonly) NSURL *thumbImageURL;           //小图网址
@property (nonatomic, readonly) NSURL *middleImageURL;          //中图网址
@property (nonatomic, readonly) NSURL *originalImageURL;        //原图网址

@property (nonatomic, strong) NSDictionary* themeInfoByJsonDic;

@end
