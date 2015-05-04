//
//  SetPwdViewController.m
//  WangYu
//
//  Created by KID on 15/5/4.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SetPwdViewController.h"

@interface SetPwdViewController ()

@property (strong, nonatomic) IBOutlet UITextField *setPwdTextField;
@property (strong, nonatomic) IBOutlet UITextField *comfirmTextField;
@property (strong, nonatomic) IBOutlet UIButton *comfimAction;

- (IBAction)confirmAction:(id)sender;

@end

@implementation SetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUIControl];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"设置密码"];
    [self setBarBackgroundColor:UIColorToRGB(0xf5f5f5) showLine:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshUIControl{
    self.comfimAction.backgroundColor = SKIN_COLOR;
    self.comfimAction.layer.cornerRadius = 4;
    self.comfimAction.layer.masksToBounds = YES;
    
}

#pragma mark - IBAction
- (IBAction)confirmAction:(id)sender{
    
}

@end
