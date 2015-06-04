//
//  WYUserGuideConfig.h
//  WangYu
//
//  Created by 许 磊 on 15/6/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYUserGuideConfig : NSObject

+ (WYUserGuideConfig *)shareInstance;

- (BOOL)newPeopleGuideShowForVcType:(NSString *)vcType;
- (void)setNewGuideShowYES:(NSString *)vcType;
- (void)saveToPersistence;

+ (void)logout;

@end
