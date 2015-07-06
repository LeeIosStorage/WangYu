//
//  ManageMatchWarViewController.m
//  WangYu
//
//  Created by Leejun on 15/7/3.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "ManageMatchWarViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYMatchApplyInfo.h"
#import "SettingViewCell.h"
#import "UIImageView+WebCache.h"
#import "WYActionSheet.h"

@interface ManageMatchWarViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *applyPeoples;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIButton *cancelMatchButton;

- (IBAction)cancelMatchWar:(id)sender;

@end

@implementation ManageMatchWarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIEdgeInsets inset = UIEdgeInsetsMake(self.titleNavBar.frame.size.height + 12, 0, 0, 0);
    [self setContentInsetForScrollView:self.tableView inset:inset];
    
    _applyPeoples = [[NSMutableArray alloc] initWithArray:_applys];
    [self.tableView reloadData];
    
    [self refreshViewUI];
    
    [self getCacheApplys];
    [self refreshApplyPeople];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"人员管理"];
    [self setRightButtonWithTitle:@"邀请" selector:@selector(inviteAction:)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma custom
- (IBAction)cancelMatchWar:(id)sender{
    
    self.cancelMatchButton.enabled = NO;
    __weak ManageMatchWarViewController *weakSelf = self;
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] cancelApplyMatchWarWithUid:[WYEngine shareInstance].uid matchId:_matchWarInfo.mId tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        self.cancelMatchButton.enabled = YES;
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        [WYProgressHUD AlertSuccess:@"取消约战成功" At:weakSelf.view];
        [weakSelf performSelector:@selector(cancelFinished) withObject:nil afterDelay:1.5];
        
    } tag:tag];
}
-(void)cancelFinished{
//    if (self.navigationController.viewControllers.count > 2) {
//        UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
//        if ([vc isKindOfClass:[PublishMatchWarViewController class]]) {
//            [self.navigationController popToViewController:vc animated:YES];
//        }
//    }
}

-(void)inviteAction:(id)sender{
    
}

-(void)refreshViewUI{
    self.cancelMatchButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    [self.cancelMatchButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    [self.cancelMatchButton.layer setMasksToBounds:YES];
    [self.cancelMatchButton.layer setCornerRadius:4.0];
    self.cancelMatchButton.backgroundColor = SKIN_COLOR;
}

-(void)getCacheApplys{
    
}
-(void)refreshApplyPeople{
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.applyPeoples.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
        UIImageView *actionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-14-18, (49-14)/2, 14, 14)];
        actionImageView.image = [UIImage imageNamed:@"match_invite_phone_icon"];
        [cell addSubview:actionImageView];
    }
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:0];
    }else if (indexPath.row == self.applyPeoples.count-1){
        [cell setLineImageViewWithType:2];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = YES;
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = YES;
    
    CGFloat rowHeight = 49;
    CGRect frame = cell.avatarImageView.frame;
    frame.origin.y = (rowHeight-30)/2;
    frame.size.width = 30;
    frame.size.height = 30;
    cell.avatarImageView.frame = frame;
    
    cell.avatarImageView.layer.masksToBounds = YES;
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width/2;
    cell.avatarImageView.clipsToBounds = YES;
    cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 7;
    cell.titleLabel.frame = frame;
    
    WYMatchApplyInfo *applyInfo = _applyPeoples[indexPath.row];
    
    cell.titleLabel.text = applyInfo.nickName;
    [cell.avatarImageView sd_setImageWithURL:applyInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"wangyu_message_icon"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    WYMatchApplyInfo *applyInfo = _applyPeoples[indexPath.row];
//    __weak ManageMatchWarViewController *weakSelf = self;
    WYActionSheet *sheet = [[WYActionSheet alloc] initWithTitle:nil actionBlock:^(NSInteger buttonIndex) {
        if (2 == buttonIndex) {
            return;
        }
        if (buttonIndex == 0) {
            [WYCommonUtils usePhoneNumAction:applyInfo.telephone];
        }else if (buttonIndex == 1){
            
        }
    } cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"电话联系", @"短信联系", nil];
    [sheet showInView:self.view];
}

@end
