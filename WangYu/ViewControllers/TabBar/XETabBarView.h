//
//  XETabBarView.h
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import <UIKit/UIKit.h>
#import "XETabBarItemView.h"

@protocol XETabBarDelegate;
@interface XETabBarView : UIView

@property(nonatomic, assign) id<XETabBarDelegate> delegate;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) XETabBarItemView *selectedTabBarItem;
@property(nonatomic, assign) UInt32 initialIndex;
@property(nonatomic, assign) BOOL simulateSelected;
- (void)selectIndex:(NSUInteger)anIndex;
@end

@protocol XETabBarDelegate <NSObject>

@optional
-(void) tabBar:(XETabBarView *)aTabBar didSelectTabAtIndex:(NSUInteger)anIndex;
@end
