//
//  WYShareActionSheet.h
//  WangYu
//
//  Created by KID on 15/5/18.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYNetbarInfo.h"
#import "WYActivityInfo.h"
#import "WYGameInfo.h"
#import "WYMatchWarInfo.h"
#import "WYNewsInfo.h"

@protocol WYShareActionSheetDelegate <NSObject>
@optional

@end

@interface WYShareActionSheet : NSObject

@property (nonatomic, weak) UIViewController<WYShareActionSheetDelegate> *owner;

@property (nonatomic, strong) WYNetbarInfo *netbarInfo;

@property (nonatomic, strong) WYActivityInfo *activityInfo;

@property (nonatomic, strong) WYGameInfo *gameInfo;

@property (nonatomic, strong) WYMatchWarInfo *matchWarInfo;//约战

@property (nonatomic, strong) WYNewsInfo *newsInfo;//资讯

-(void) showShareAction;

@end
