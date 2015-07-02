//
//  WYMatchApplyInfo.h
//  WangYu
//
//  Created by Leejun on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYMatchApplyInfo : NSObject

@property(nonatomic, strong) NSString* applyId;
@property(nonatomic, strong) NSString* userId;
@property(nonatomic, strong) NSString* nickName;
@property(nonatomic, strong) NSString* userAvatar;
@property(nonatomic, strong) NSString* telephone;
@property(nonatomic, readonly) NSURL* smallAvatarUrl;

- (void)setApplyInfoByDic:(NSDictionary*)dic;

@end
