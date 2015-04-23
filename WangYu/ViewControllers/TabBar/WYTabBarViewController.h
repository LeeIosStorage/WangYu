//
//  WYTabBarViewController.h
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import <UIKit/UIKit.h>
#import "WYTabBarView.h"

#define TAB_INDEX_MINE 3
#define TAB_INDEX_CHAT 2
#define TAB_INDEX_EVALUATION 1
#define TAB_INDEX_MAINPAGE 0

@protocol WYTabBarControllerDelegate;

@interface WYTabBarViewController : UIViewController

@property (nonatomic, assign) id <WYTabBarControllerDelegate> delegate;

@property (nonatomic, retain) WYTabBarView *tabBar;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property(nonatomic, assign) UInt32 initialIndex;

/*
 * -1表示有标示但不知具体数目，只显示红点
 */
- (void)setBadge:(int)badgeNum forIndex:(NSUInteger)index;
@end

@protocol WYTabBarControllerDelegate <NSObject>
@optional
-(BOOL) tabBarController:(WYTabBarViewController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
-(void) tabBarController:(WYTabBarViewController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end

//viewControllers可以继承的协议
@protocol WYTabBarControllerSubVcProtocol<NSObject>

@optional
//已经选中的情况再次选中
- (void)tabBarController:(WYTabBarViewController *)tabBarController reSelectVc:(UIViewController *)viewController;

@end

/*!
 @category UIViewController (WYTabBarControllerItem)
 @abstract
 */
@interface UIViewController (WYTabBarControllerItem)

@property (nonatomic, retain) WYTabBarViewController *tabController;

@end
