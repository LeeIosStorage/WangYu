//
//  WYSuperViewController.h
//  Xiaoer
//
//  Created by KID on 15/1/4.
//
//

#import <UIKit/UIKit.h>
#import "WYBaseSuperViewController.h"
#import "WYCommonVcTransition.h"

@interface WYSuperViewController : WYBaseSuperViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) WYCommonVcTransition *interactivePopTransition;
@property (nonatomic, assign) BOOL disablePan;

- (IBAction)backAction:(id)sender;

@end
