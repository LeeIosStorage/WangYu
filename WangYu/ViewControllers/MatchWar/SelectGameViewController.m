//
//  SelectGameViewController.m
//  WangYu
//
//  Created by Leejun on 15/6/29.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "SelectGameViewController.h"
#import "SettingViewCell.h"
#import "WYInputViewController.h"
#import "PublishMatchWarViewController.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "UIImageView+WebCache.h"

@interface SelectGameViewController ()<WYInputViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *gameLists;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) IBOutlet UIView *headView;
@property (nonatomic, strong) IBOutlet UILabel *tipLabel;

@end

@implementation SelectGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _gameLists = [[NSMutableArray alloc] init];
//    [_gameLists addObject:@{@"icon":@"game_crossFire_icon",@"gameName":@"英雄联盟"}];
//    [_gameLists addObject:@{@"icon":@"game_crossFire_icon",@"gameName":@"DOTA2"}];
//    [_gameLists addObject:@{@"icon":@"game_crossFire_icon",@"gameName":@"星际争霸"}];
//    [_gameLists addObject:@{@"icon":@"game_crossFire_icon",@"gameName":@"穿越火线"}];
//    [self.tableView reloadData];
    
    [self getCacheMatchGames];
    [self refreshMatchGameList];
    
    [self refreshViewUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"选择游戏"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)getCacheMatchGames{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getMatchGameItemsWithUid:[WYEngine shareInstance].uid tag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.gameLists = [[NSMutableArray alloc] init];
            NSArray *object = [jsonRet arrayObjectForKey:@"object"];
            for (NSDictionary *dic in object) {
                if (![dic isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                [weakSelf.gameLists addObject:dic];
            }
            
            [weakSelf.tableView reloadData];
        }
    }];
    
}
-(void)refreshMatchGameList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getMatchGameItemsWithUid:[WYEngine shareInstance].uid tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.gameLists = [[NSMutableArray alloc] init];
        NSArray *object = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in object) {
            if (![dic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            [weakSelf.gameLists addObject:dic];
        }
        
        [weakSelf.tableView reloadData];
        
    }tag:tag];
}

-(void)refreshViewUI{
    self.tipLabel.font = SKIN_FONT_FROMNAME(12);
    self.tipLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.tipLabel.text = @"•根据你的约战游戏进行选择";
    
    self.tableView.tableHeaderView = self.headView;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _gameLists.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingViewCell";
    SettingViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    if (indexPath.row == 0) {
        [cell setLineImageViewWithType:0];
    }else if (indexPath.row == _gameLists.count-1){
        [cell setLineImageViewWithType:2];
    }else{
        [cell setLineImageViewWithType:1];
    }
    
    cell.rightLabel.hidden = YES;
    cell.avatarImageView.hidden = NO;
    cell.indicatorImage.hidden = NO;
    cell.avatarImageView.clipsToBounds = YES;
    cell.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGRect frame = cell.avatarImageView.frame;
    frame.origin.y = (44-42)/2;
    frame.size.width = 59;
    frame.size.height = 42;
    cell.avatarImageView.frame = frame;
    
    frame = cell.titleLabel.frame;
    frame.origin.x = cell.avatarImageView.frame.origin.x + cell.avatarImageView.frame.size.width + 9;
    cell.titleLabel.frame = frame;
    
    NSDictionary *rowDicts = _gameLists[indexPath.row];
    cell.titleLabel.text = [rowDicts objectForKey:@"item_name"];
    NSURL *itemUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[WYEngine shareInstance].baseImgUrl,[rowDicts objectForKey:@"item_icon"]]];
    [cell.avatarImageView sd_setImageWithURL:itemUrl placeholderImage:[UIImage imageNamed:@"activity_load_icon"]];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    NSDictionary *rowDicts = _gameLists[indexPath.row];
    
    WYInputViewController *lvc = [[WYInputViewController alloc] init];
    lvc.delegate = self;
    lvc.maxTextLength = 15;
    lvc.toolRightType = @"wy_Server";
    lvc.titleText = @"选择服务器";
    lvc.gameDic = rowDicts;
    [self.navigationController pushViewController:lvc animated:YES];
}

#pragma mark - WYInputViewControllerDelegate
- (void)inputViewControllerWithGameDic:(NSDictionary*)gameDic{
    
    if (self.navigationController.viewControllers.count > 2) {
        UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
        if ([vc isKindOfClass:[PublishMatchWarViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectGameViewControllerWithGameDic:)]) {
        [self.delegate selectGameViewControllerWithGameDic:gameDic];
    }
}

@end
