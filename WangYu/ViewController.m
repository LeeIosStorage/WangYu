//
//  ViewController.m
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ViewController.h"
#import "SKSplashIcon.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (strong, nonatomic) SKSplashView *splashView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = SKIN_COLOR;
    [self viewSplash];
}

- (void) viewSplash
{
    //Setting the background
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    imageView.image = [UIImage imageNamed:@"twitter background.png"];
//    [self.view addSubview:imageView];
    //Twitter style splash
    SKSplashIcon *twitterSplashIcon = [[SKSplashIcon alloc] initWithImage:[UIImage imageNamed:@"twitterIcon"] animationType:SKIconAnimationTypeBounce];
    UIColor *twitterColor = [UIColor clearColor];
    _splashView = [[SKSplashView alloc] initWithSplashIcon:twitterSplashIcon backgroundColor:twitterColor animationType:SKSplashAnimationTypeNone];
    _splashView.delegate = self; //Optional -> if you want to receive updates on animation beginning/end
    _splashView.animationDuration = 2; //Optional -> set animation duration. Default: 1s
    [self.view addSubview:_splashView];
    [_splashView startAnimation];
    [UIView animateWithDuration:2 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) splashViewDidEndAnimating: (SKSplashView *) splashView
{
    AppDelegate *appDelgate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelgate signIn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
