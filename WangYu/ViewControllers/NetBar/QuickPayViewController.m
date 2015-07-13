//
//  QuickPayViewController.m
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "QuickPayViewController.h"
#import "QuickPayCell.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "OrdersViewController.h"
#import "WYPayManager.h"
#import "WYAlertView.h"
#import "AppDelegate.h"
#import "RedPacketViewController.h"
#import "UIImageView+WebCache.h"
#import "WYUserGuideConfig.h"
#import "NetbarDetailViewController.h"

#define myNumbers          @"0123456789\n"

@interface QuickPayViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,WYPayManagerListener>{
    int _redAmount;
    NSMutableArray *_packetIds;
    
    int _discountRule;
    NSString *_needPayAmount;
    UIButton *_pointButton;
}

@property (strong, nonatomic) IBOutlet UITableView *payTable;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UILabel *netbarLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *payforLabel;
@property (strong, nonatomic) IBOutlet UILabel *moneyLabel;
@property (strong, nonatomic) IBOutlet UIButton *payButton;
@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (strong, nonatomic) IBOutlet UILabel *colorLabel;
@property (assign, nonatomic) BOOL isAlipay;
@property (assign, nonatomic) BOOL isWeixin;

@property (strong, nonatomic) IBOutlet UIView *supOriAmountContainerView;

@property (strong, nonatomic) IBOutlet UIView *oriAmountContainerView;
@property (strong, nonatomic) IBOutlet UITextField *amountField;

//红包
@property (strong, nonatomic) IBOutlet UIView *redPacketContainerView;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *packetLabel;

@property (strong, nonatomic) IBOutlet UIView *needAmountContainerView;
@property (strong, nonatomic) IBOutlet UILabel *needPayTipLabel;
@property (strong, nonatomic) IBOutlet UILabel *needPayAmountLabel;

@property (strong, nonatomic) NSMutableArray *packetInfos;
@property (strong, nonatomic) IBOutlet UIView *discountView;
@property (strong, nonatomic) IBOutlet UILabel *discountTitle;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;

@property (strong, nonatomic) IBOutlet UIView *guideView;
@property (strong, nonatomic) IBOutlet UIView *guideImageView;

- (IBAction)payAction:(id)sender;
- (IBAction)packetAction:(id)sender;
- (IBAction)netbarAction:(id)sender;
- (IBAction)newGuideAction:(id)sender;

@end

@implementation QuickPayViewController

- (void)dealloc{
    [[WYPayManager shareInstance] removeListener:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTextChaneg:) name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (!self.isBooked) {
        UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeGestureRecognizer:)];
        [self.oriAmountContainerView addGestureRecognizer:gestureRecongnizer];
    }
    
    self.isAlipay = YES;
    self.isWeixin = NO;
    _discountRule = 0;
    _packetInfos = [NSMutableArray array];
    _packetIds = [NSMutableArray array];
    [[WYPayManager shareInstance] addListener:self];
    
    [self refreshUI];
    [self calculateNeedPayAmount];
    [self.payTable reloadData];
    [self refreshNewGuideView:NO];
    
    [self refreshNetbarInfo];
}

- (void)becomeGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self.amountField becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    _pointButton = [[UIButton alloc] initWithFrame:CGRectMake(-0.5, SCREEN_HEIGHT - 53.5 + keyboardBounds.size.height - (SCREEN_WIDTH > 375?3:0), (SCREEN_WIDTH - 5)/3, keyboardBounds.size.height/4)];
    [_pointButton setImage:[UIImage imageNamed:(SCREEN_WIDTH == 320)?@"keyboard_point_bg":@"keyboard_point6_bg"] forState:UIControlStateNormal];
    [_pointButton setImage:[UIImage imageNamed:(SCREEN_WIDTH == 320)?@"keyboard_point_hover_bg":@"keyboard_point6_hover_bg"] forState:UIControlStateHighlighted];
    [_pointButton addTarget:self action:@selector(pointAction:) forControlEvents:UIControlEventTouchUpInside];
    UIWindow * tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:2];
//    NSLog(@"%@",tempWindow);
    
    if (_pointButton.superview == nil){
        [tempWindow addSubview:_pointButton];
    }
    
    // get a rect for the textView frame
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if (self.amountField.isFirstResponder) {
        CGRect frame = _pointButton.frame;
        frame.origin.y -= keyboardBounds.size.height;
        _pointButton.frame = frame;
    }
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note
{
    [_pointButton removeFromSuperview];
    [self.amountField resignFirstResponder];
}

#pragma mark -
- (void)pointAction:(UIButton *)btn{
    NSUInteger nDotLoc = [self.amountField.text rangeOfString:@"."].location;
    if (NSNotFound == nDotLoc) {
        if (self.amountField.text.length > 0){
            self.amountField.text = [self.amountField.text stringByAppendingString:@"."];
        }else {
            self.amountField.text = [self.amountField.text stringByAppendingString:@"0."];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    if (self.isBooked) {
        [self setTitle:@"支付加价"];
        self.amountField.text = self.orderInfo.amount;
        self.amountField.enabled = NO;
    }else{
        [self setTitle:@"一键支付"];
    }
}

- (void)refreshNewGuideView:(BOOL)isNext {
    self.guideView.frame = [UIScreen mainScreen].bounds;
    BOOL isShow = [[WYUserGuideConfig shareInstance] newPeopleGuideShowForVcType:@"quickPayView"];
    if (isShow) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.window addSubview:self.guideView];
        UITapGestureRecognizer *gestureRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizer:)];
        [self.guideImageView addGestureRecognizer:gestureRecongnizer];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.guideView.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.guideView.superview) {
                [self.guideView removeFromSuperview];
                if (isNext) {
                    //...
                }
            }
        }];
    }
}

- (void)gestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"quickPayView"];
    [self refreshNewGuideView:NO];
}


- (IBAction)newGuideAction:(id)sender{
    [[WYUserGuideConfig shareInstance] setNewGuideShowYES:@"quickPayView"];
    [self refreshNewGuideView:NO];
}

-(void)refreshNetbarInfo{
    if (self.netbarInfo.nid.length == 0) {
        return;
    }
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getNetbarDetailWithUid:[WYEngine shareInstance].uid netbarId:self.netbarInfo.nid tag:tag];
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
        [weakSelf.netbarInfo setNetbarInfoByJsonDic:dic];
        [weakSelf refreshUI];
    }tag:tag];
}

- (void)refreshUI{
    
    self.netbarImage.layer.cornerRadius = 4.0;
    self.netbarImage.layer.masksToBounds = YES;
    
    self.netbarLabel.font = SKIN_FONT_FROMNAME(15);
    self.netbarLabel.textColor = SKIN_TEXT_COLOR1;
    self.addressLabel.font = SKIN_FONT_FROMNAME(12);
    self.addressLabel.textColor = SKIN_TEXT_COLOR2;
    self.payforLabel.font = SKIN_FONT_FROMNAME(15);
    self.payforLabel.textColor = SKIN_TEXT_COLOR1;
    self.priceLabel.font = SKIN_FONT_FROMNAME(12);
    self.priceLabel.textColor = SKIN_TEXT_COLOR1;
    self.packetLabel.font = SKIN_FONT_FROMNAME(12);
    self.packetLabel.textColor = SKIN_TEXT_COLOR1;
    
    self.needPayTipLabel.textColor = SKIN_TEXT_COLOR1;
    self.needPayTipLabel.font = SKIN_FONT_FROMNAME(12);
    self.needPayAmountLabel.textColor = UIColorToRGB(0xff0000);
    self.needPayAmountLabel.font = SKIN_FONT_FROMNAME(17);
    
    self.colorLabel.backgroundColor = UIColorToRGB(0xfac402);
    self.colorLabel.layer.cornerRadius = 1.0;
    self.colorLabel.layer.masksToBounds = YES;
    
    [self.payButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.payButton.titleLabel.font = SKIN_FONT_FROMNAME(18);
    self.payButton.backgroundColor = SKIN_COLOR;
    self.payButton.layer.cornerRadius = 4.0;
    self.payButton.layer.masksToBounds = YES;
    
    if (![self.netbarInfo.smallImageUrl isEqual:[NSNull null]]) {
        [self.netbarImage sd_setImageWithURL:self.netbarInfo.smallImageUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }else{
        [self.netbarImage sd_setImageWithURL:nil];
        [self.netbarImage setImage:[UIImage imageNamed:@"netbar_load_icon"]];
    }
    self.addressLabel.text = self.netbarInfo.address;
    self.netbarLabel.text = self.netbarInfo.netbarName;
    
    
    CGRect frame = self.headerView.frame;
    float headViewHeight = 137 + 44;
    if (self.isBooked) {
        self.redPacketContainerView.hidden = YES;
        self.priceLabel.text = @"加价金额：";
        frame = self.supOriAmountContainerView.frame;
        frame.size.height = self.redPacketContainerView.frame.origin.y;
        self.supOriAmountContainerView.frame = frame;
        
    }else{
        self.priceLabel.text = @"输入上网金额：";
        frame = self.supOriAmountContainerView.frame;
        frame.size.height = self.redPacketContainerView.frame.origin.y + self.redPacketContainerView.frame.size.height;
        self.supOriAmountContainerView.frame = frame;
        //红包
        self.redPacketContainerView.hidden = NO;
        headViewHeight += self.redPacketContainerView.frame.size.height;
        
        //折扣
        self.discountView.hidden = YES;
        if(self.netbarInfo.isDiscount){
            self.discountView.hidden = NO;
            
            _discountRule = self.netbarInfo.rebate/10;
            self.discountLabel.text = [NSString stringWithFormat:@"%d折",_discountRule];
            self.discountTitle.font = SKIN_FONT_FROMNAME(12);
            self.discountTitle.textColor = SKIN_TEXT_COLOR1;
            self.discountLabel.font = SKIN_FONT_FROMNAME(12);
            self.discountLabel.textColor = UIColorToRGB(0xff0000);
            
            frame = self.discountView.frame;
            frame.origin.y = headViewHeight;
            self.discountView.frame = frame;
            [self.headerView addSubview:self.discountView];
            headViewHeight += self.discountView.frame.size.height;
        }
        
        //还需支付
        self.needAmountContainerView.hidden = NO;
        frame = self.needAmountContainerView.frame;
        frame.origin.y = headViewHeight;
        self.needAmountContainerView.frame = frame;
        [self.headerView addSubview:self.needAmountContainerView];
        headViewHeight += self.needAmountContainerView.frame.size.height;
        
        self.needPayAmountLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        NSString *needPayAmountText = [NSString stringWithFormat:@"%@元",_needPayAmount];
        float width = [WYCommonUtils widthWithText:needPayAmountText font:self.needPayAmountLabel.font lineBreakMode:NSLineBreakByTruncatingMiddle];
        if (width > 108) {
            width = 108;
        }
        frame = self.needPayTipLabel.frame;
        frame.origin.x = SCREEN_WIDTH - 12-width - frame.size.width - 2;
        self.needPayTipLabel.frame = frame;
        self.needPayTipLabel.text = @"需要支付现金:";
    }
    
    frame = self.headerView.frame;
    frame.size.height = headViewHeight;
    self.headerView.frame = frame;
    
    self.payTable.tableHeaderView = self.headerView;
    self.payTable.tableFooterView = self.footerView;
}

- (void)checkTextChaneg:(NSNotification *)notif
{
//    UITextField *textField = notif.object;
//    //修正ios7键盘输入中文超过长度崩溃
//    if (self.amountField.markedTextRange != nil) {
//        return;
//    }
//    if (textField.text.length > 4 && self.amountField.markedTextRange == nil) {
//        self.amountField.text = [LSCommonUtils getHanziTextWithText:_inputText maxLength:_maxTextLength];
//    }
    
    [self calculateNeedPayAmount];
}

-(void)calculateNeedPayAmount{
    double payAmount = [self.amountField.text doubleValue];
    if (self.netbarInfo.isDiscount) {
        
        if (self.netbarInfo.algorithm == 1) {
            //先打折再减红包
            payAmount = payAmount*_discountRule/10;
            if (_redAmount > 0) {
                payAmount = payAmount - _redAmount;
            }
        }else if (self.netbarInfo.algorithm == 2){
            //先减红包再打折
            if (_redAmount > 0) {
                payAmount = payAmount - _redAmount;
            }
            payAmount = payAmount*_discountRule/10;
        }
    }else{
        //无折扣只计算红包
        if (_redAmount > 0) {
            payAmount = payAmount - _redAmount;
        }
    }
    if (payAmount <= 0) {
        payAmount = 0;
    }else if (payAmount >0 && payAmount <= 0.01){
        payAmount = 0.01;
    }
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    _needPayAmount = [formatter stringFromNumber:[NSNumber numberWithDouble:payAmount]];
    
    NSString *needPayAmountText = [NSString stringWithFormat:@"%@元",_needPayAmount];
    _needPayAmountLabel.text = needPayAmountText;
    
    float width = [WYCommonUtils widthWithText:needPayAmountText font:self.needPayAmountLabel.font lineBreakMode:NSLineBreakByTruncatingMiddle];
    if (width > 108) {
        width = 108;
    }
    CGRect frame = self.needPayTipLabel.frame;
    frame.origin.x = SCREEN_WIDTH - 12-width - frame.size.width - 8;
    self.needPayTipLabel.frame = frame;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *cs;
    if (NSNotFound == [textField.text rangeOfString:@"0"].location && range.location == 0 && [string isEqualToString:@"0"]) {//第一位不允许输入0
        return NO;
    }
    
    NSUInteger nDotLoc = [textField.text rangeOfString:@"."].location;
    if (NSNotFound == nDotLoc && 0 != range.location) {
        cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers] invertedSet];
        if ([string isEqualToString:@"."]) {
            return YES;
        }
        if (textField.text.length>=6) {  //小数点前面6位
            return NO;
        }
    }
    else {
        cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers] invertedSet];
    }
    NSString *filtered1 = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest1 = [string isEqualToString:filtered1];
    if (!basicTest1) {
        WYLog(@"只能输入数字和小数点");
        return NO;
    }
    if (NSNotFound != nDotLoc && range.location > nDotLoc+1) {
        WYLog(@"小数点后最多1位");
        return NO;
    }
    
    cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];
    if (!basicTest) {
        WYLog(@"只能输入数字");
        return NO;
    }
    if (!string.length && range.length > 0) {
        return YES;
    }
    NSString *oldString = [textField.text copy];
    NSString *newString = [oldString stringByReplacingCharactersInRange:range withString:string];
    if (textField == _amountField && textField.markedTextRange == nil) {
        WYLog(@"textField.text = %@",textField.text);
        if (NSNotFound != nDotLoc) {
            if (newString.length > 5) return NO;
        }else {
            if (newString.length > 3) return NO;
        }
    }
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"QuickPayCell";
    QuickPayCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:nil options:nil];
        cell = [cells objectAtIndex:0];
    }
    
    if (indexPath.row == 0) {
        [cell.payImage setImage:[UIImage imageNamed:@"netbar_orders_alipay_icon"]];
        cell.payLabel.text = @"支付宝";
        if (self.isAlipay) {
            [cell.checkButton setImage:[UIImage imageNamed:@"netbar_orders_check_icon"] forState:UIControlStateNormal];
        }else {
            [cell.checkButton setImage:[UIImage imageNamed:@"netbar_orders_uncheck_icon"] forState:UIControlStateNormal];
        }
        [cell setbottomLineWithType:0];
    } else if (indexPath.row == 1) {
       [cell.payImage setImage:[UIImage imageNamed:@"netbar_orders_weixin_icon"]];
        cell.payLabel.text = @"微信支付";
        if (self.isWeixin) {
            [cell.checkButton setImage:[UIImage imageNamed:@"netbar_orders_check_icon"] forState:UIControlStateNormal];
        }else {
            [cell.checkButton setImage:[UIImage imageNamed:@"netbar_orders_uncheck_icon"] forState:UIControlStateNormal];
        }
        cell.topline.hidden = YES;
        [cell setbottomLineWithType:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath* selIndexPath = [tableView indexPathForSelectedRow];
    [tableView deselectRowAtIndexPath:selIndexPath animated:YES];
    if (indexPath.row == 0) {
        self.isAlipay = YES;
        self.isWeixin = NO;
    }else if (indexPath.row == 1) {
        self.isAlipay = NO;
        self.isWeixin = YES;
    }
    [self.payTable reloadData];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self doforEndEdit];
}

- (void)doforEndEdit{
    if (self.amountField.isFirstResponder) {
        self.payTable.contentOffset = CGPointMake(0, 0);
    }
    if (self.amountField.isFirstResponder) {
        [self.amountField resignFirstResponder];
    }
}

- (IBAction)netbarAction:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)payAction:(id)sender {
    if ([[WYEngine shareInstance] needUserLogin:@"注册或登录后才能支付费用"]) {
        return;
    }
    
    if ([_amountField.text doubleValue] == 0) {
        [WYProgressHUD lightAlert:@"请输入上网金额"];
        return;
    }
    
    if (self.isWeixin && ![WXApi isWXAppInstalled]) {
        [WYUIUtils showAlertWithMsg:@"微信支付失败！"];
        return;
    }
    self.payButton.enabled = NO;
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    if (self.isBooked) {
        [WYProgressHUD AlertLoading:@"请求中..." At:weakSelf.view];
        [[WYEngine shareInstance] reservePayWithUid:[WYEngine shareInstance].uid body:self.orderInfo.netbarName orderId:self.orderInfo.orderId packetsId:nil type:self.isWeixin?0:1 tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//            [WYProgressHUD AlertLoadDone];
            weakSelf.payButton.enabled = YES;
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic = (NSMutableDictionary *)[jsonRet dictionaryObjectForKey:@"object"];
            if (weakSelf.isWeixin) {
                [[WYPayManager shareInstance] payForWinxinWith:dic];
            }else {
                
                NSMutableDictionary *alipayDic = [NSMutableDictionary dictionary];
                if ([dic stringObjectForKey:@"orderId"]) {
                    [alipayDic setValue:[dic stringObjectForKey:@"orderId"] forKey:@"orderId"];
                }
                if ([dic stringObjectForKey:@"out_trade_no"]) {
                    [alipayDic setValue:[dic stringObjectForKey:@"out_trade_no"] forKey:@"out_trade_no"];
                }
                if (weakSelf.netbarInfo.netbarName.length > 0) {
                    [alipayDic setValue:weakSelf.netbarInfo.netbarName forKey:@"netbarName"];
                }
                if (weakSelf.amountField.text.length > 0) {
                    [alipayDic setValue:weakSelf.amountField.text forKey:@"amount"];
                }
                [[WYPayManager shareInstance] payForAlipayWith:alipayDic];
            }
        }tag:tag];
    }else {
        if (_amountField.text.length == 0) {
            [WYProgressHUD lightAlert:@"请输入上网金额"];
            return;
        }
//        [WYProgressHUD AlertLoading:@"请求中..." At:weakSelf.view];
        [[WYEngine shareInstance] orderPayWithUid:[WYEngine shareInstance].uid body:self.netbarInfo.netbarName amount:[_needPayAmount doubleValue] netbarId:self.netbarInfo.nid packetsId:_packetIds type:self.isWeixin?0:1 origAmount:[_amountField.text doubleValue] tag:tag];
        [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
//            [WYProgressHUD AlertLoadDone];
            weakSelf.payButton.enabled = YES;
            NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
            if (!jsonRet || errorMsg) {
                if (!errorMsg.length) {
                    errorMsg = @"请求失败";
                }
                [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
                return;
            }
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic = (NSMutableDictionary *)[jsonRet dictionaryObjectForKey:@"object"];
            if ([[dic stringObjectForKey:@"return_code"] isEqualToString:@"FAIL"]) {
                [WYProgressHUD AlertError:@"支付失败" At:weakSelf.view];
                return;
            }
            if ([dic intValueForKey:@"self_pay"] == 1) {
                [WYProgressHUD AlertSuccess:@"支付成功" At:weakSelf.view];
                [weakSelf performSelector:@selector(goToOrderViewController) withObject:nil afterDelay:1.0];
                return;
            }
            if (weakSelf.isWeixin) {
//                [WYProgressHUD AlertLoadDone];
                [[WYPayManager shareInstance] payForWinxinWith:dic];
            }else {
//                [WYProgressHUD AlertLoadDone];
                
                NSMutableDictionary *alipayDic = [NSMutableDictionary dictionary];
                if ([dic stringObjectForKey:@"orderId"]) {
                    [alipayDic setValue:[dic stringObjectForKey:@"orderId"] forKey:@"orderId"];
                }
                if ([dic stringObjectForKey:@"out_trade_no"]) {
                    [alipayDic setValue:[dic stringObjectForKey:@"out_trade_no"] forKey:@"out_trade_no"];
                }
                if (weakSelf.netbarInfo.netbarName.length > 0) {
                    [alipayDic setValue:weakSelf.netbarInfo.netbarName forKey:@"netbarName"];
                }
                if (_needPayAmount.length > 0) {
                    [alipayDic setValue:_needPayAmount forKey:@"amount"];
                }
                [[WYPayManager shareInstance] payForAlipayWith:alipayDic];
            }
        }tag:tag];
    }
}

- (IBAction)packetAction:(id)sender {
    [self doforEndEdit];
    if (!_isBooked && _amountField.text.length == 0) {
        [WYProgressHUD lightAlert:@"请先输入上网金额"];
        return;
    }
    WS(weakSelf);
    RedPacketViewController *rpVc = [[RedPacketViewController alloc] init];
    rpVc.bChooseRed = YES;
    if (_packetInfos.count > 0) {
        rpVc.packetInfos = _packetInfos;
    }
    rpVc.sendRedPacketCallBack = ^(NSArray *array){
        if (array != nil) {
            _redAmount = 0;
            _packetIds = [[NSMutableArray alloc]init];
            for (RedPacketInfo *info in array) {
                _redAmount += info.money;
                [_packetIds addObject:info.rid];
            }
            weakSelf.moneyLabel.hidden = NO;
            weakSelf.moneyLabel.text = [NSString stringWithFormat:@"￥%d",_redAmount];
            if (_redAmount == 0) {
                weakSelf.moneyLabel.hidden = YES;
            }
            weakSelf.packetInfos = [NSMutableArray arrayWithArray:array];
        }else{
            weakSelf.moneyLabel.hidden = YES;
            [weakSelf.packetInfos removeAllObjects];
            [_packetIds removeAllObjects];
        }
        [self calculateNeedPayAmount];
    };
    [self.navigationController pushViewController:rpVc animated:YES];
}

//-(UINavigationController *) navigationController
//{
//    AppDelegate *appDele = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    return appDele.mainTabViewController.navigationController;
//}

-(void)goToOrderViewController{
    OrdersViewController *orderVc = [[OrdersViewController alloc] init];
    orderVc.isShowPayPage = YES;
    
    UINavigationController *navVc = [self navigationController];
    //去掉衍生出来的部分viewController
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (id vc in navVc.viewControllers) {
        if ([NSStringFromClass([vc class]) isEqualToString:@"WYTabBarViewController"]) {
            [viewControllers addObject:vc];
            break;
        }
    }
    [viewControllers addObject:orderVc];
    [[self navigationController] setViewControllers:viewControllers animated:YES];
}

#pragma mark -WYPayManagerListener
- (void)payManagerResultStatus:(int)status payType:(int)payType{
    [[WYPayManager shareInstance] removeListener:self];
    if (self.isBooked) {
        if (status == 1) {
            //预订订单加价支付成功 返回订单页。
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else{
        //一键支付 成功或失败都会生成支付订单 所以都跳支付订单页。
//        [self performSelector:@selector(goToOrderViewController) withObject:nil afterDelay:1.0];
        [self goToOrderViewController];
    }
}

@end
