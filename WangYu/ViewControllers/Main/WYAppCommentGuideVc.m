//
//  WYAppCommentGuideVc.m
//  WangYu
//
//  Created by XuLei on 15/7/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYAppCommentGuideVc.h"
#import "FeedBackViewController.h"
#import "WYEngine.h"
#import "AppDelegate.h"

@interface WYAppCommentGuideVc ()

@property (strong, nonatomic) IBOutlet UIView *contentContainerView;

- (IBAction)goToAppStoreAction:(id)sender;
- (IBAction)rejectAction:(id)sender;
- (IBAction)complainAction:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *guideTitleLabel;

@property (strong, nonatomic) IBOutlet UIButton *starButton;
@property (strong, nonatomic) IBOutlet UIButton *complainButton;
@property (strong, nonatomic) IBOutlet UIButton *rejectButton;

@end

@implementation WYAppCommentGuideVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUI];
}

- (void)refreshUI {
    self.contentContainerView.layer.cornerRadius = 4;
    
    self.starButton.backgroundColor = SKIN_COLOR;
    self.starButton.layer.cornerRadius = 4;
    self.starButton.layer.masksToBounds = YES;
    [self.starButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    
    self.complainButton.backgroundColor = UIColorToRGB(0xe4e4e4);
    self.complainButton.layer.cornerRadius = 4;
    self.complainButton.layer.masksToBounds = YES;
    [self.complainButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    
    [self.rejectButton setBackgroundColor:[UIColor clearColor]];
    [self.rejectButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)isHasNormalTitle
{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CGRect frame = self.contentContainerView.frame;
    frame.origin.y = (self.view.bounds.size.height - frame.size.height)/2;
    self.contentContainerView.frame = frame;
}

- (IBAction)goToAppStoreAction:(id)sender {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id986749236"]];
    if (self.delegate) {
        [self.delegate cancelAppCommentGuideVc:self];
    }
}

- (IBAction)rejectAction:(id)sender {
    if (self.delegate) {
        [self.delegate cancelAppCommentGuideVc:self];
    }
}

- (IBAction)complainAction:(id)sender {    
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    FeedBackViewController* chatViewController = [[FeedBackViewController alloc] init];
    [appDelegate.mainTabViewController.navigationController pushViewController:chatViewController animated:YES];
    if (self.delegate) {
        [self.delegate cancelAppCommentGuideVc:self];
    }
}
- (void)viewDidUnload {
    [self setContentContainerView:nil];
    [super viewDidUnload];
}


@end
