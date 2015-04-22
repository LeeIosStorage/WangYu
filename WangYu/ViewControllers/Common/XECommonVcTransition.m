//
//  XECommonVcTransition.m
//  Xiaoer
//
//  Created by KID on 15/1/4.
//
//

#import "XECommonVcTransition.h"

@implementation XECommonVcTransition

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *fromvc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    
    CGRect tovcFrame = toVc.view.frame;
    tovcFrame.origin.x = -tovcFrame.size.width/3.f;
    toVc.view.frame = tovcFrame;
    [containerView insertSubview:toVc.view belowSubview:fromvc.view];
    
    UIView *mask = [[UIView alloc] initWithFrame:fromvc.view.bounds];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = .2;
    mask.layer.shadowOpacity = .8;
    CGRect mframe = mask.frame;
    mframe.origin.x = -mframe.size.width;
    mask.frame = mframe;
    [containerView insertSubview:mask belowSubview:fromvc.view];
    
    
    float duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        // Fade out the source view controller
        CGRect fFrame = fromvc.view.frame;
        fFrame.origin.x = fFrame.size.width;
        fromvc.view.frame = fFrame;
        
        mask.alpha = 0;
        CGRect mframe = mask.frame;
        mframe.origin.x = 0;
        mask.frame = mframe;
        
        CGRect finaltoFrame = tovcFrame;
        finaltoFrame.origin.x = 0;
        toVc.view.frame = finaltoFrame;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [mask removeFromSuperview];
        if ([transitionContext transitionWasCancelled]) {
        }
    }];
}

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25f;
}

- (void)animationEnded:(BOOL) transitionCompleted
{
    NSLog(@"### %s", __FUNCTION__);
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    NSLog(@"### %s ,  presented = %@, presenting = %@, sourceController = %@", __FUNCTION__, presented, presenting, source);
    
    return self;
}

@end
