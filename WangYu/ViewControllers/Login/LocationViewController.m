//
//  LocationViewController.m
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "LocationViewController.h"
#import "AppDelegate.h"

@interface LocationViewController ()

@property (nonatomic, strong) NSArray *cityArray;

@property (strong, nonatomic) IBOutlet UILabel *currentLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIButton *currentCityButton;
@property (strong, nonatomic) IBOutlet UIView *lightupCityView;
@property (strong, nonatomic) IBOutlet UIView *noticeView;

- (IBAction)locationAction:(id)sender;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _cityArray = @[@"郑州", @"洛阳", @"开封", @"驻马店", @"新乡",@"上海", @"北京", @"广州"];
    [self refreshUI];
    [self refreshCityView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"选择城市"];
}

- (void)refreshUI {
    self.currentLabel.font = SKIN_FONT_FROMNAME(14);
    self.currentLabel.textColor = SKIN_TEXT_COLOR2;
    self.hintLabel.font = SKIN_FONT_FROMNAME(14);
    self.hintLabel.textColor = SKIN_TEXT_COLOR2;
    self.cityLabel.font = SKIN_FONT_FROMNAME(14);
    self.cityLabel.textColor = SKIN_TEXT_COLOR2;
    self.noticeLabel.font = SKIN_FONT_FROMNAME(14);
    self.noticeLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.currentCityButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.currentCityButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.currentCityButton.layer setMasksToBounds:YES];
    [self.currentCityButton.layer setCornerRadius:4.0];
    [self.currentCityButton.layer setBorderWidth:0.5];
    [self.currentCityButton.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
}

- (void)refreshCityView {
    CGRect frame = self.hintLabel.frame;
    frame.origin.x = self.currentCityButton.frame.size.width + 24;
    self.hintLabel.frame = frame;
    
    frame = self.lightupCityView.frame;
    
    int index = 0;
    for (NSString *cityStr in self.cityArray) {
        CGFloat width = (SCREEN_WIDTH - 24 - 30)/3;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(12 + (index%3)*(width + 15), (index/3)*(34+12) + 42, width, 34)];
        button.titleLabel.font = SKIN_FONT_FROMNAME(14);
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle: cityStr forState: UIControlStateNormal];
        [button setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0];
        [button.layer setBorderWidth:0.5];
        [button.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
        [button addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.lightupCityView addSubview:button];
        if (index > 5) {
            frame.size.height = 134 + (index/3 - 1)*(34+12);
            self.lightupCityView.frame = frame;
        }
        index ++;
    }
    frame = self.noticeView.frame;
    frame.origin.y = self.lightupCityView.frame.origin.y + self.lightupCityView.frame.size.height;
    self.noticeView.frame = frame;
    
}

- (IBAction)locationAction:(id)sender {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDelegate.mainTabViewController.tabBar selectIndex:0];
}

@end
