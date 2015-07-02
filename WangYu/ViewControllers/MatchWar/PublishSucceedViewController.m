//
//  PublishSucceedViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "PublishSucceedViewController.h"
#import "NetbarDetailViewController.h"
#import "WYShareActionSheet.h"
#import "MatchWarDetailViewController.h"

@interface PublishSucceedViewController ()<WYShareActionSheetDelegate>
{
    WYShareActionSheet *_shareAction;
}
@property (nonatomic, strong) IBOutlet UILabel *succeedTipLabel;
@property (nonatomic, strong) IBOutlet UIButton *showDetailsButton;
@property (nonatomic, strong) IBOutlet UILabel *netbarLabel;
@property (nonatomic, strong) IBOutlet UIButton *orderNetbarButton;

-(IBAction)showDetailAction:(id)sender;
-(IBAction)orderNetbarAction:(id)sender;
@end

@implementation PublishSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    [self refreshViewUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@""];
    [self setRightButtonWithImageName:@"netbar_detail_share_icon" selector:@selector(shareAction:)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)refreshViewUI{
    self.succeedTipLabel.font = SKIN_FONT_FROMNAME(18);
    self.succeedTipLabel.textColor = SKIN_TEXT_COLOR1;
    
    self.showDetailsButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.showDetailsButton.titleLabel.textColor = UIColorToRGB(0xf03f3f);
    [self.showDetailsButton.layer setMasksToBounds:YES];
    [self.showDetailsButton.layer setCornerRadius:4.0];
    [self.showDetailsButton.layer setBorderWidth:0.5];
    [self.showDetailsButton.layer setBorderColor:UIColorToRGB(0xf03f3f).CGColor];
    
    UIColor *labelColor = SKIN_TEXT_COLOR1;
    self.netbarLabel.font = SKIN_FONT_FROMNAME(12);
    self.netbarLabel.textColor = labelColor;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:@"去约战网吧预定机位"];
    NSRange contentRange = {0, [content length]};
    
    [content addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:contentRange];
    [content addAttribute:NSUnderlineColorAttributeName value:labelColor range:contentRange];
    self.netbarLabel.attributedText = content;
    
    self.orderNetbarButton.hidden = NO;
    self.netbarLabel.hidden = NO;
    if (_matchWarInfo.netbarId.length > 0) {
        self.orderNetbarButton.hidden = NO;
        self.netbarLabel.hidden = NO;
    }
}

-(IBAction)showDetailAction:(id)sender{
    if (_matchWarInfo.mId.length == 0) {
        return;
    }
    MatchWarDetailViewController *mVc = [[MatchWarDetailViewController alloc] init];
    mVc.matchWarInfo = _matchWarInfo;
    [self.navigationController pushViewController:mVc animated:YES];
}

-(IBAction)orderNetbarAction:(id)sender{
    if (_matchWarInfo.netbarId.length == 0) {
        return;
    }
    NetbarDetailViewController *ndVc = [[NetbarDetailViewController alloc] init];
    WYNetbarInfo *netbarInfo = [[WYNetbarInfo alloc] init];
    netbarInfo.nid = _matchWarInfo.netbarId;
    ndVc.netbarInfo = netbarInfo;
    [self.navigationController pushViewController:ndVc animated:YES];
}

-(void)shareAction:(id)sender{
    _shareAction = [[WYShareActionSheet alloc] init];
    _shareAction.matchWarInfo = _matchWarInfo;
    _shareAction.owner = self;
    [_shareAction showShareAction];
}

@end
