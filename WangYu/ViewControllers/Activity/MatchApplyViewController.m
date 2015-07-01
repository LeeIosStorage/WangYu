//
//  MatchApplyViewController.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchApplyViewController.h"
#import "MatchApplyCell.h"
#import "MatchMemberViewController.h"
#import "WYProgressHUD.h"
#import "WYEngine.h"
#import "MatchMemberViewController.h"
#import "SelectNetbarViewController.h"

@interface MatchApplyViewController ()<UITableViewDelegate, UITableViewDataSource,MatchApplyCellDelegate>{
    NSString *_netbarName;
    NSString *_teamName;
    NSString *_serviceName;
    NSString *_myName;
    NSString *_idCard;
    NSString *_telephone;
    NSString *_qqStr;
    NSString *_laborStr;
}

@property (strong, nonatomic) IBOutlet UIButton *commitButton;
@property (strong, nonatomic) IBOutlet UITableView *applyTableView;
@property (strong, nonatomic) WYNetbarInfo *netbarInfo;

- (IBAction)commitAction:(id)sender;

@end

@implementation MatchApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNormalTitleNavBarSubviews {
    [self setTitle:@"创建战队"];
}

- (void)refreshUI {
    self.commitButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.commitButton.backgroundColor = SKIN_COLOR;
    self.commitButton.layer.cornerRadius = 4;
    self.commitButton.layer.masksToBounds = YES;
}

- (void)createTeam {
    WS(weakSelf);
    [WYProgressHUD AlertLoading:@"创建中..." At:weakSelf.view];
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] createMatchTeamWithUid:[WYEngine shareInstance].uid activityId:self.activityId netbarId:self.netbarInfo.nid name:_myName telephone:_telephone idcard:_idCard qqNum:_qqStr labor:_laborStr round:self.matchInfo.round server:_serviceName tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        NSDictionary *dic = [jsonRet objectForKey:@"object"];
        NSLog(@"=========%@",dic);
        [WYProgressHUD AlertSuccess:@"创建成功" At:weakSelf.view];
        MatchMemberViewController *mmVc = [[MatchMemberViewController alloc] init];
        [self.navigationController pushViewController:mmVc animated:YES];
    }tag:tag];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return 2;
    }else if (section == 2){
        return 5;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1 || section == 2) {
        return 24;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColorToRGB(0xf1f1f1);
    if(section == 0) {
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    }else{
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 24);
        UILabel *indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, 100, view.frame.size.height)];
        indexLabel.backgroundColor = [UIColor clearColor];
        indexLabel.textColor = SKIN_TEXT_COLOR2;
        indexLabel.font = SKIN_FONT_FROMNAME(12);
        if (section == 1) {
            indexLabel.text = @"战队资料";
        }else if(section == 2){
            indexLabel.text = @"个人资料";
        }
        [view addSubview:indexLabel];
    }
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MatchApplyCell";
    MatchApplyCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    cell.rightImageView.hidden = YES;
    cell.delegate = self;
    
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"参赛网吧";
                [cell setbottomLineWithType:1];
                cell.rightImageView.hidden = NO;
                cell.textField.enabled = NO;
                cell.textField.text = _netbarName;
            }
        }
            break;
        case 1:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"战队名";
                cell.textField.text = _teamName;
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 1){
                cell.titleLabel.text = @"大区";
                cell.textField.text = _serviceName;
                [cell setbottomLineWithType:1];
            }
        }
            break;
        case 2:{
            if (indexPath.row == 0){
                cell.titleLabel.text = @"姓名";
                cell.textField.text = _myName;
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 1) {
                cell.titleLabel.text = @"身份证";
                cell.textField.text = _idCard;
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 2) {
                cell.titleLabel.text = @"手机";
                cell.textField.text = _telephone;
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 3) {
                cell.titleLabel.text = @"QQ";
                cell.textField.text = _qqStr;
                [cell setbottomLineWithType:0];
            }else if (indexPath.row == 4) {
                cell.titleLabel.text = @"擅长位置";
                cell.textField.text = _laborStr;
                [cell setbottomLineWithType:1];
            }
        }
            break;
        default:
            break;
    }
    
    if (indexPath.row == 0) {
         cell.topline.hidden = NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WS(weakSelf);
    if(indexPath.section == 0) {
        if (indexPath.row == 0){
            SelectNetbarViewController *snVc = [[SelectNetbarViewController alloc] init];
            snVc.netbarInfos = self.matchInfo.netbars;
            snVc.sendNetbarCallBack = ^(WYNetbarInfo *info){
                if (info) {
                _netbarName = info.netbarName;
                [weakSelf.applyTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    weakSelf.netbarInfo = info;
                }
            };
            [self.navigationController pushViewController:snVc animated:YES];
        }
    }
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

#pragma mark -- MatchApplyCellDelegate
-(void) textDidChanged:(id) cell cellContent:(NSString *)content
{
    NSLog(@"textFiledChanged");
    NSIndexPath *indexPath = [self.applyTableView indexPathForCell:cell];
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            _teamName = content;
        }else if (indexPath.row == 1){
            _serviceName = content;
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0){
            _myName = content;
        }else if (indexPath.row == 1) {
            _idCard = content;
        }else if (indexPath.row == 2) {
            _telephone = content;
        }else if (indexPath.row == 3) {
            _qqStr = content;
        }else if (indexPath.row == 4) {
            _laborStr = content;
        }
    }
}

-(void) textDidEditing:(id)cell{
    NSLog(@"textDidEditing");
}

- (void)keyboardWillShown:(NSNotification *) notification {
    if ([WYCommonUtils isIphone4]) {
        NSDictionary* userInfo = [notification userInfo];
        NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        CGRect keyboardRect = [aValue CGRectValue];
        keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
        
        CGFloat keyboardTop = keyboardRect.origin.y;
        CGRect newTableViewFrame = self.applyTableView.bounds;
        newTableViewFrame.size.height = keyboardTop - self.applyTableView.bounds.origin.y;
        
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        _applyTableView.frame = newTableViewFrame;
        [UIView commitAnimations];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *) notification{
    if ([WYCommonUtils isIphone4]) {
        NSDictionary* userInfo = [notification userInfo];
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        _applyTableView.frame = self.view.bounds;
        [UIView commitAnimations];
    }
}

- (IBAction)commitAction:(id)sender {
    if (_netbarName.length == 0) {
        [WYProgressHUD lightAlert:@"请选择参赛网吧"];
        return;
    }
    if (_teamName.length == 0) {
        [WYProgressHUD lightAlert:@"请输入战队名"];
        return;
    }
    if (_serviceName.length == 0) {
        [WYProgressHUD lightAlert:@"请输入大区名"];
        return;
    }
    if (_myName.length == 0) {
        [WYProgressHUD lightAlert:@"请输入姓名"];
        return;
    }
    if (_idCard.length == 0) {
        [WYProgressHUD lightAlert:@"请输入身份证"];
        return;
    }
    if (_telephone.length == 0) {
        [WYProgressHUD lightAlert:@"请输入手机号"];
        return;
    }
    if (_qqStr.length == 0) {
        [WYProgressHUD lightAlert:@"请输入QQ号"];
        return;
    }
    if (_laborStr.length == 0) {
        [WYProgressHUD lightAlert:@"请确定擅长位置"];
        return;
    }
    [self createTeam];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
