//
//  WYNavigationController.m
//  Xiaoer
//
//  Created by KID on 14/12/31.
//
//

#import "WYNavigationController.h"
#import "WYSuperViewController.h"
#import "WYCommonVcTransition.h"

@interface WYNavigationController ()

@property (nonatomic, strong) NSMutableArray *needPushArray;
@property (nonatomic, assign) BOOL isPushing;
@property (nonatomic, strong) WYCommonVcTransition *tempTransition;

@end

@implementation WYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
#ifdef USE_SYS_PAN_GESTURE
    __weak WYNavigationController *weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
    }
#endif
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

//判断是否有要显示的
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    // Enable the gesture again once the new controller is shown
    _isPushing = NO;
    
#ifdef USE_SYS_PAN_GESTURE
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        //if current view controll is root level, disable gesture recognizer.
        if ([navigationController viewControllers].count == 1) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }else
            self.interactivePopGestureRecognizer.enabled = YES;
    }
#endif
    if (_needPushArray.count > 0) {
//        [self doPushViewController];
    }
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC  NS_AVAILABLE_IOS(7_0){
    if(operation == UINavigationControllerOperationPop){
        if([fromVC isKindOfClass:[WYSuperViewController class]]){
            WYSuperViewController *vc = (WYSuperViewController *)fromVC;
            self.tempTransition = vc.interactivePopTransition;
            return vc.interactivePopTransition;
        }
    }
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController NS_AVAILABLE_IOS(7_0){
    if([animationController isKindOfClass:[WYCommonVcTransition class]]){
        return self.tempTransition;
    }
    return nil;
}

#pragma mark -- 禁止横竖屏切换
-(BOOL)shouldSupportRotate{
//    if ([[self.viewControllers lastObject] isKindOfClass:NSClassFromString(@"LSMWPhotoBrowser")]
//        || [[self.viewControllers lastObject] isKindOfClass:NSClassFromString(@"LSCommonWebVc")]
//        ){
//        return YES;
//    }
    return NO;
}
//5.0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([self shouldSupportRotate]){
        return YES;
    }
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//6.0
- (BOOL)shouldAutorotate{
    return [self shouldSupportRotate];
}
- (NSUInteger)supportedInterfaceOrientations{
    if ([self shouldSupportRotate])
        return UIInterfaceOrientationMaskAll;
    else
        return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController *)WYpopViewControllerAnimated:(id)animated {
    return [super popViewControllerAnimated:[animated boolValue]];
}

@end
