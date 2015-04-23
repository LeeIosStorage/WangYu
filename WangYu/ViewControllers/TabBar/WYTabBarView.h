//
//  WYTabBarView.h
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import <UIKit/UIKit.h>
#import "WYTabBarItemView.h"

@protocol WYTabBarDelegate;
@interface WYTabBarView : UIView

@property(nonatomic, assign) id<WYTabBarDelegate> delegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) WYTabBarItemView *selectedTabBarItem;
@property(nonatomic, assign) UInt32 initialIndex;
@property(nonatomic, assign) BOOL simulateSelected;
- (void)selectIndex:(NSUInteger)anIndex;
@end

@protocol WYTabBarDelegate <NSObject>

@optional
-(void) tabBar:(WYTabBarView *)aTabBar didSelectTabAtIndex:(NSUInteger)anIndex;
@end
