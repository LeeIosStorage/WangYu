//
//  InviteMemberViewController.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "InviteMemberViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "NSString+Value.h"

@interface InviteMemberViewController ()

@property (strong, nonatomic) IBOutlet UIView *inputView;
@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

- (IBAction)addMemberAction:(id)sender;

@end

@implementation InviteMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews {
    [self setTitle:@"添加队友"];
}

- (void)refreshUI {
    
    self.phoneTextField.textColor = SKIN_TEXT_COLOR2;
    self.phoneTextField.font = SKIN_FONT_FROMNAME(14);
    
    [self.inputView.layer setMasksToBounds:YES];
    [self.inputView.layer setCornerRadius:4.0];
    [self.inputView.layer setBorderWidth:0.5]; //边框宽度
    [self.inputView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
    
    self.hintLabel.textColor = SKIN_TEXT_COLOR2;
    self.hintLabel.font = SKIN_FONT_FROMNAME(12);
    
    [self.addButton.layer setMasksToBounds:YES];
    [self.addButton.layer setCornerRadius:4.0];
    [self.addButton setBackgroundColor:SKIN_COLOR];
    self.addButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.addButton.titleLabel.textColor = SKIN_TEXT_COLOR1;
}

- (IBAction)addMemberAction:(id)sender {
    if (_phoneTextField.text.length == 0) {
        [WYProgressHUD lightAlert:@"请输入被邀请人手机号"];
        return;
    }
    if (![_phoneTextField.text isPhone]) {
        [WYProgressHUD lightAlert:@"请输入正确的手机号"];
        return;
    }
    
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addTeamMemberWithUid:[WYEngine shareInstance].uid activityId:self.activityId teamId:self.teamId round:1 telephone:self.phoneTextField.text tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"添加成功" At:weakSelf.view];
    }tag:tag];
}

@end
