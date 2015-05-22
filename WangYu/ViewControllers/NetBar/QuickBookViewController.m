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
#import "OrdersViewController.h"

#define Tag_date_check       100
#define Tag_time_check       101
#define Tag_duration_check   102
#define Tag_seatnum_check    103
#define Tag_addcost_check    200

@interface QuickBookViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource, UIPickerViewDelegate>{
    int date;
    int hours;
    int seatNum;
    int addCost;
    NSString* dateString;
    NSString* seatString;
    NSString* hourString;
    NSString* timeString;
    NSString* costString;
    NSString* dateTempString;
    NSString* startTimeString;
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
@property (strong, nonatomic) IBOutlet UITextView *descTextView;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIButton *descButton;
@property (nonatomic, weak) UIView *Pickermask;
@property (assign, nonatomic) CGRect keyboardBounds;
@property (strong, nonatomic) IBOutlet UIView *floatView;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)bookAction:(id)sender;
- (IBAction)descAction:(id)sender;
- (IBAction)datePickerValueChanged:(id)sender;

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
    
    self.descTextView.textColor = SKIN_TEXT_COLOR2;
    self.descTextView.font = SKIN_FONT(12);
    [self.descTextView.layer setBorderWidth:0.5];
    [self.descTextView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
    
    self.hintLabel.font = SKIN_FONT_FROMNAME(12);
    self.hintLabel.textColor = SKIN_TEXT_COLOR2;
    seatNum = 1;
    _dateArray = [NSArray arrayWithObjects:@"今天",@"明天",@"后天",nil];
    _durationArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12)];
    _seatnumArray = @[@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10)];
    _addcostArray = @[@(0),@(1),@(2),@(3),@(4),@(5),@(6)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    CGRect frame = _floatView.frame;
    frame.origin.y = self.view.bounds.size.height;
    _floatView.frame = frame;
    
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
    keyboardBounds.origin.y -= 42;
    keyboardBounds.size.height += 42;
    self.keyboardBounds = keyboardBounds;
    
    // get a rect for the textView frame
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if (self.descTextView.isFirstResponder) {
        int diff = self.footerView.frame.origin.y + self.footerView.frame.size.height + keyboardBounds.size.height - self.bookTable.bounds.size.height;
        if(diff > 0)
            self.bookTable.contentOffset = CGPointMake(0, diff);
    }
    if (_floatView.superview == self.view) {
        [_floatView removeFromSuperview];
    }
    
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
    if (self.descTextView.text.length == 0) {
        _descButton.hidden = NO;
    }
    // commit animations
    [UIView commitAnimations];
}

- (void)doReserve {
    if (dateString.length == 0) {
        [WYProgressHUD lightAlert:@"请预订上网日期"];
        return;
    }
    if (timeString.length == 0) {
        [WYProgressHUD lightAlert:@"请预订上网时间"];
        return;
    }
    if (hourString.length == 0) {
        [WYProgressHUD lightAlert:@"请预订上网时长"];
        return;
    }
    if (seatString.length ==0) {
        [WYProgressHUD lightAlert:@"请预订座位数量"];
        return;
    }
    
    NSString *tempString = [NSString stringWithFormat:@"%@ %@",dateTempString, startTimeString];
    //NSLog(@"========%@",tempString);
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] quickBookingWithUid:[WYEngine shareInstance].uid reserveDate:tempString amount:(double)seatNum*addCost netbarId:_netbarInfo.nid hours:hours num:seatNum remark:_descTextView.text tag:tag];
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
        
        OrdersViewController *oVc = [[OrdersViewController alloc] init];
        [self.navigationController pushViewController:oVc animated:YES];
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
            cell.rightLabel.text = dateString;
        } else if (indexPath.row == 1) {
            cell.titleName.text = @"上网时间";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_time_icon"];
            cell.rightLabel.text = timeString;
        } else if (indexPath.row == 2) {
            cell.titleName.text = @"上网时长";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_duration_icon"];
            cell.rightLabel.text = hourString;
        } else if (indexPath.row == 3) {
            cell.titleName.text = @"座位数量";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_seatnum_icon"];
            cell.rightLabel.text = seatString;
        }
    } else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            cell.titleName.text = @"追加费用";
            cell.leftImage.image = [UIImage imageNamed:@"netbar_orders_add_icon"];
            cell.rightLabel.text = costString;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self doforEndEdit];
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
    }else {
        [self setValueByDate:_datePicker.date];
        if (_floatView.superview == self.view) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _floatView.frame;
                rect.origin.y = self.view.frame.size.height;
                _floatView.frame = rect;
            } completion:^(BOOL finished) {
                [self.floatView removeFromSuperview];
            }];
        }else{
            UIView *Pickermask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            Pickermask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
            [[UIApplication sharedApplication].keyWindow addSubview:Pickermask];
            self.Pickermask = Pickermask;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePicker)];
            [Pickermask addGestureRecognizer:tap];
            
            if (_descTextView.isFirstResponder) {
                [_descTextView resignFirstResponder];
            }
            [UIView animateWithDuration:0.3 animations:^{
                CGRect rect = _floatView.frame;
                rect.origin.y = self.view.frame.size.height - _floatView.frame.size.height;
                _floatView.frame = rect;
                [Pickermask addSubview:_floatView];
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
}

-(void)pickerComfirm
{
    if (checkType == Tag_date_check) {
        if (dateString.length == 0) {
            dateString = [_dateArray objectAtIndex:0];
            NSCalendar * calender = [NSCalendar currentCalendar];
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
            NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
            NSDateComponents *compsNow = [calender components:unitFlags fromDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            dateTempString = [dateFormatter stringFromDate:[calender dateFromComponents:compsNow]];
        }
    }else if(checkType == Tag_duration_check){
        if (hourString.length == 0) {
            hours = [_durationArray[0] intValue];
            hourString = [NSString stringWithFormat:@"%@小时",[_durationArray objectAtIndex:0]];
        }
    }else if(checkType == Tag_seatnum_check){
        if (seatString.length == 0) {
            seatNum = [_seatnumArray[0] intValue];
            seatString = [NSString stringWithFormat:@"%@个",[_seatnumArray objectAtIndex:0]];
        }
    }else if(checkType == Tag_addcost_check){
        if (costString.length == 0) {
            addCost = [_addcostArray[0] doubleValue];
            costString = [NSString stringWithFormat:@"%@元",[_addcostArray objectAtIndex:0]];
        }
    }
    NSIndexPath *indexPath;
    if (checkType == Tag_addcost_check) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }else {
        indexPath = [NSIndexPath indexPathForRow:checkType - 100 inSection:0];
    }
    [_bookTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.Pickermask removeFromSuperview];
}

-(void)closePicker
{
    [self.Pickermask removeFromSuperview];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self doforEndEdit];
}

- (void)doforEndEdit{
    if (self.descTextView.isFirstResponder) {
        self.bookTable.contentOffset = CGPointMake(0, 0);
    }
    if (self.descTextView.isFirstResponder) {
        [self.descTextView resignFirstResponder];
    }
    if (self.floatView.superview) {
        [self.floatView removeFromSuperview];
    }
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
        return [NSString stringWithFormat:@"%d元",[[_addcostArray objectAtIndex:row] intValue]*seatNum];
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
    NSIndexPath *indexPath;
    if (checkType == Tag_addcost_check) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }else {
        indexPath = [NSIndexPath indexPathForRow:checkType - 100 inSection:0];
    }
    
    if (checkType == Tag_date_check) {
        dateString = [_dateArray objectAtIndex:row];
        NSCalendar * calender = [NSCalendar currentCalendar];
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit |
        NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
        NSDateComponents *compsNow = [calender components:unitFlags fromDate:[NSDate date]];
        compsNow.day += row;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        dateTempString = [dateFormatter stringFromDate:[calender dateFromComponents:compsNow]];
    }else if(checkType == Tag_duration_check){
        hours = [_durationArray[row] intValue];
        hourString = [NSString stringWithFormat:@"%@小时",[_durationArray objectAtIndex:row]];
    }else if(checkType == Tag_seatnum_check){
        seatNum = [_seatnumArray[row] intValue];
        seatString = [NSString stringWithFormat:@"%@个",[_seatnumArray objectAtIndex:row]];
        //价格联动
        if (costString.length != 0) {
            int amount = 0;
            amount = seatNum*addCost;
            costString = [NSString stringWithFormat:@"%d元",amount];
            [_bookTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else if(checkType == Tag_addcost_check){
        addCost = [_addcostArray[row] intValue];
        costString = [NSString stringWithFormat:@"%d元",[[_addcostArray objectAtIndex:row] intValue]*seatNum];
    }
    [_bookTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (IBAction)bookAction:(id)sender {
    [self doforEndEdit];
    [self doReserve];
}

- (IBAction)descAction:(id)sender {
    _descButton.hidden = YES;
    [self.descTextView becomeFirstResponder];
}

- (IBAction)datePickerValueChanged:(id)sender {
    [self setValueByDate:_datePicker.date];
}

- (void)setValueByDate:(NSDate*)pickerDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH时mm分"];
    timeString = [dateFormatter stringFromDate:pickerDate];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm:ss"];
    startTimeString = [dateFormatter2 stringFromDate:pickerDate];
    [_bookTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
