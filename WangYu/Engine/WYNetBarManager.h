//
//  WYNetBarManager.h
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYNetBarManager : NSObject

+ (WYNetBarManager*)shareInstance;

- (NSMutableArray *)getHistorySearchRecord;
- (NSMutableArray *)addSaveHistorySearchRecord:(NSString *)record;
- (void)removeHistorySearchRecord;

@end
