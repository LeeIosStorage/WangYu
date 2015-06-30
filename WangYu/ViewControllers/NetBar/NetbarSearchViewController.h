//
//  NetbarSearchViewController.h
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSuperViewController.h"
#import "WYNetbarInfo.h"

@protocol NetbarSearchViewControllerDelegate;

@interface NetbarSearchViewController : WYSuperViewController

@property (nonatomic, assign) BOOL isChoose;
@property (nonatomic, assign) id<NetbarSearchViewControllerDelegate>delegate;

@property (nonatomic, strong) NSString *areaCode;//选择城市code
@property (nonatomic, assign) BOOL showFilter;

@end

@protocol NetbarSearchViewControllerDelegate <NSObject>
- (void)searchViewControllerSelectWithNetbarInfo:(WYNetbarInfo*)netbarInfo;

@end