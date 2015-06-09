//
//  AboutViewController.m
//  WangYu
//
//  Created by KID on 15/4/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "AboutViewController.h"
#import "TTTAttributedLabel.h"

@interface AboutViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *aboutIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *aboutVersionLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutTipLabel;
@property (strong, nonatomic) IBOutlet UILabel *aboutCompanyLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *aboutInformationLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self refreshUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"关于我们"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshUI{
    self.aboutVersionLabel.font = SKIN_FONT_FROMNAME(15);
    self.aboutVersionLabel.textColor = SKIN_TEXT_COLOR1;
//    self.aboutTipLabel.font = SKIN_FONT_FROMNAME(12);
    self.aboutTipLabel.textColor = SKIN_TEXT_COLOR2;
//    self.aboutCompanyLabel.font = SKIN_FONT_FROMNAME(12);
    self.aboutCompanyLabel.textColor = SKIN_TEXT_COLOR2;
    self.aboutInformationLabel.font = SKIN_FONT_FROMNAME(14);
    self.aboutInformationLabel.textColor = SKIN_TEXT_COLOR2;
    
    NSString *localVserion = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    self.aboutVersionLabel.text = [NSString stringWithFormat:@"网娱大师%@",localVserion];
    
    self.aboutTipLabel.text = @"Copyright © 2015";
    self.aboutCompanyLabel.text = @"河南网娱互动网络科技有限公司";
    
    self.aboutInformationLabel.lineHeightMultiple = 0.8;
    self.aboutInformationLabel.text = self.aboutInformationLabel.text;
    
    //set label 行间距
//    NSString *aboutInformationText = self.aboutInformationLabel.text;
//    NSUInteger length = [aboutInformationText length];
//    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:aboutInformationText];
//    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    style.lineHeightMultiple = 1.4;
//    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, length)];
//    self.aboutInformationLabel.attributedText = attrString;
    
}

@end
