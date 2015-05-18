//
//  QuickBookViewController.m
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "QuickBookViewController.h"
#import "QuickBookCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"

#define Tag_date_check       100
#define Tag_time_check       101
#define Tag_duration_check   102
#define Tag_seatnum_check    103
#define Tag_addcost_check    200

@interface QuickBookViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>{
    NSArray *_dateArray;
    NSArray *_timeArray;
    NSArray *_durationArray;
    NSArray *_seatnumArray;
    NSArray *_addcostArray;
    NSInteger checkType;
}

@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UITableView *bookTable;
@property (strong, nonatomic) IBOutlet UIButton *bookButton;
@property (strong, nonatomic) IBOutlet UITextField *specialField;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIButton *descButton;

@property (nonatomic, weak) UIView *Pickermask;

- (IBAction)bookAction:(id)sender;
- (IBAction)descAction:(id)sender;

@end

@implementation QuickBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.bookTable.tableFooterView = self.footerView;
    
    [self.bookButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.bookButton.titleLabel.font = SKIN_FONT(18);
    self.bookButton.backgroundColor = SKIN_COLOR;
    self.bookButton.layer.cornerRadius = 4.0;
    self.bookButton.layer.masksToBounds = YES;
    
    self.specialField.textColor = SKIN_TEXT_COLOR2;
    self.specialField.font = SKIN_FONT(12);
    [self.specialField.layer setBorderWidth:0.5];
    [self.specialField.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
    
    self.hintLabel.font = SKIN_FONT_FROMNAME(12);
    self.hintLabel.textColor = SKIN_TEXT_COLOR2;
    
    _dateArray = [NSArray arrayWithObjects:@"今天",@"明天",@"后天",nil];
    _timeArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8)];
    _durationArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12)];
    _seatnumArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10)];
    _addcostArray = @[@(1),@(2),@(3),@(4),@(5),@(6)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"一键预订"];
}

-(void) keyboardWillShow:(NSNotification *)note{
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // commit animations
    [UIView commitAnimations];
}

- (void)doReserve {
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] quickBookingWithUid:[WYEngine shareInstance].uid reserveDate:@"" amount:12 netbarId:_netbarInfo.nid hours:2 num:2 remark:@"头号" tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        [WYProgressHUD AlertLoadDone];
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
    }tag:tag];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuickBookCell";
    QuickBookCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.titleName.text = @"预订日期";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_date_icon"];
            cell.rightLabel.text = @"今天";
        } else if (indexPath.row == 1) {
            cell.titleName.text = @"上网时间";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_time_icon"];
            cell.rightLabel.text = @"11时00分";
        } else if (indexPath.row == 2) {
            cell.titleName.text = @"上网时长";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_duration_icon"];
            cell.rightLabel.text = @"6小时";
        } else if (indexPath.row == 3) {
            cell.titleName.text = @"座位数量";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_seatnum_icon"];
            cell.rightLabel.text = @"2个";
        }
    } else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.titleName.text = @"追加费用";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_add_icon"];
            cell.rightLabel.text = @"0元";
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    checkType = indexPath.row + 100 + indexPath.section * 100;
    if (checkType != Tag_time_check) {
        UIView *Pickermask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        Pickermask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [[UIApplication sharedApplication].keyWindow addSubview:Pickermask];
        self.Pickermask = Pickermask;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePicker)];
        [Pickermask addGestureRecognizer:tap];
        
        UIPickerView *countPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-230, SCREEN_WIDTH, 200)];
        countPicker.backgroundColor = [UIColor whiteColor];
        countPicker.layer.cornerRadius = 5;
        countPicker.delegate = self;
        countPicker.dataSource = self;
        [Pickermask addSubview:countPicker];
        
        UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
        confirmBtn.backgroundColor = [UIColor whiteColor];
        confirmBtn.layer.cornerRadius = 5;
        [confirmBtn addTarget:self action:@selector(pickerComfirm) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
        [Pickermask addSubview:confirmBtn];
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

-(void)pickerComfirm
{
    if (checkType == Tag_date_check) {
//        bDirection = YES;
//        if ([self.direLabel.text isEqualToString:@"房间朝向"]) {
//            self.direLabel.text = [_direTextArray objectAtIndex:0];
//            direction = 1;
//        }
    }else if(checkType == Tag_duration_check){
//        bFitment = YES;
//        if ([self.fitmentLabel.text isEqualToString:@"房间装修"]) {
//            self.fitmentLabel.text = [_fitmentTextArray objectAtIndex:0];
//            fitment = 1;
//        }
    }else if(checkType == Tag_seatnum_check){
//        bPayType = YES;
//        if ([self.payTypeLabel.text isEqualToString:@"支付形式"]) {
//            self.payTypeLabel.text = [_payTextArray objectAtIndex:0];
//            payType = 1;
//        }
    }else if(checkType == Tag_addcost_check){
        
    }
    [self.Pickermask removeFromSuperview];
}

-(void)closePicker
{
    [self.Pickermask removeFromSuperview];
}

#pragma -UIPickerView代理

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (checkType == Tag_date_check) {
        return [_dateArray objectAtIndex:row];
    }else if(checkType == Tag_duration_check){
        return [NSString stringWithFormat:@"%@小时",[_durationArray objectAtIndex:row]];
    }else if(checkType == Tag_seatnum_check){
        return [NSString stringWithFormat:@"%@个",[_seatnumArray objectAtIndex:row]];
    }else if(checkType == Tag_addcost_check){
        return [NSString stringWithFormat:@"%@元",[_addcostArray objectAtIndex:row]];
    }
    return nil;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (checkType == Tag_date_check) {
        return _dateArray.count;
    }else if(checkType == Tag_duration_check){
        return _durationArray.count;
    }else if(checkType == Tag_seatnum_check){
        return _seatnumArray.count;
    }else {
        return _addcostArray.count;
    }
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    if (checkType == Tag_date_check) {
//        self.direLabel.text = [_direTextArray objectAtIndex:row];
//        direction = (int)_direArray[row];
    }else if(checkType == Tag_duration_check){
//        self.fitmentLabel.text = [_fitmentTextArray objectAtIndex:row];
//        fitment = (int)_fitmentArray[row];
    }else if(checkType == Tag_seatnum_check){
//        self.payTypeLabel.text = [_payTextArray objectAtIndex:row];
//        payType = (int)_payArray[row];
    }else if(checkType == Tag_addcost_check){
        
    }
}

- (IBAction)bookAction:(id)sender {
    [self doReserve];
}

- (IBAction)descAction:(id)sender {
    _descButton.hidden = YES;
    [_specialField resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
