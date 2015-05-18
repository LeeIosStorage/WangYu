//
//  WYShareActionSheet.h
//  WangYu
//
//  Created by KID on 15/5/18.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WYShareActionSheetDelegate <NSObject>

@optional
-(void) deleteTopicAction:(id)info;
@end

@interface WYShareActionSheet : NSObject

@property (nonatomic, weak) UIViewController<WYShareActionSheetDelegate> *owner;

-(void) showShareAction;

@end
