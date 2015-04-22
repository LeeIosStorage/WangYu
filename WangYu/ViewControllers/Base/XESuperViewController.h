//
//  XESuperViewController.h
//  Xiaoer
//
//  Created by KID on 15/1/4.
//
//

#import <UIKit/UIKit.h>
#import "XEBaseSuperViewController.h"
#import "XECommonVcTransition.h"

@interface XESuperViewController : XEBaseSuperViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) XECommonVcTransition *interactivePopTransition;
@property (nonatomic, assign) BOOL disablePan;

- (IBAction)backAction:(id)sender;

@end
