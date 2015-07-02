//
//  WYMatchCommentInfo.h
//  WangYu
//
//  Created by Leejun on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYMatchCommentInfo : NSObject

@property(nonatomic, strong) NSString* content;
@property(nonatomic, strong) NSDate* createDate;
@property(nonatomic, strong) NSString* userId;
@property(nonatomic, strong) NSString* nickName;
@property(nonatomic, strong) NSString* userAvatar;
@property(nonatomic, readonly) NSURL* smallAvatarUrl;

- (void)setCommentInfoByDic:(NSDictionary*)dic;

@end
