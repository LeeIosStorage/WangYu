//
//  XETabBarViewController.h
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import <UIKit/UIKit.h>
#import "XETabBarView.h"

#define TAB_INDEX_MINE 3
#define TAB_INDEX_CHAT 2
#define TAB_INDEX_EVALUATION 1
#define TAB_INDEX_MAINPAGE 0

@protocol XETabBarControllerDelegate;

@interface XETabBarViewController : UIViewController

@property (nonatomic, assign) id <XETabBarControllerDelegate> delegate;

@property (nonatomic, retain) XETabBarView *tabBar;
@property (nonatomic, assign) NSUInteger selectedIndex;

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) UIViewController *selectedViewController;
@property(nonatomic, assign) UInt32 initialIndex;

/*
 * -1表示有标示但不知具体数目，只显示红点
 */
- (void)setBadge:(int)badgeNum forIndex:(NSUInteger)index;
@end

@protocol XETabBarControllerDelegate <NSObject>
@optional
-(BOOL) tabBarController:(XETabBarViewController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;
-(void) tabBarController:(XETabBarViewController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end

//viewControllers可以继承的协议
@protocol XETabBarControllerSubVcProtocol<NSObject>

@optional
//已经选中的情况再次选中
- (void)tabBarController:(XETabBarViewController *)tabBarController reSelectVc:(UIViewController *)viewController;

@end

/*!
 @category UIViewController (XETabBarControllerItem)
 @abstract
 */
@interface UIViewController (XETabBarControllerItem)

@property (nonatomic, retain) XETabBarViewController *tabController;

@end
