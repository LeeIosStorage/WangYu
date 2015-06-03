//
//  LocationViewController.m
//  WangYu
//
//  Created by KID on 15/5/15.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "LocationViewController.h"
#import "AppDelegate.h"
#import "WYEngine.h"
#import "WYProgressHUD.h"
#import "WYLocationServiceUtil.h"

@interface LocationViewController ()

@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, strong) NSString *cityCode;
@property (nonatomic, strong) NSMutableArray *cityArray;

@property (strong, nonatomic) IBOutlet UILabel *currentLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
@property (strong, nonatomic) IBOutlet UILabel *hintLabel;
@property (strong, nonatomic) IBOutlet UIButton *currentCityButton;
@property (strong, nonatomic) IBOutlet UIView *lightupCityView;
@property (strong, nonatomic) IBOutlet UIScrollView *cityScrollView;
@property (strong, nonatomic) IBOutlet UIView *noticeView;

- (IBAction)locationAction:(id)sender;

@end

@implementation LocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _cityArray = [[NSMutableArray alloc] init];
//    _cityArray = @[@"郑州", @"洛阳", @"开封", @"驻马店", @"新乡",@"上海", @"北京", @"广州"];
    [self refreshUI];
    
    [self getCacheValidCitys];
    [self refreshValidCityList];
    
    [self refreshLocationViewUI:0];
    WS(weakSelf);
    //获取用户位置
    [[WYLocationServiceUtil shareInstance] getUserCurrentLocation:^(NSString *errorString) {
        [self refreshLocationViewUI:1];
    } location:^(CLLocation *location) {
        [weakSelf placemarkReverseLocation:location];
    }];
}

- (void)placemarkReverseLocation:(CLLocation *)location{
    WS(weakSelf);
    [[WYLocationServiceUtil shareInstance] placemarkReverseGeoLocation:location placemark:^(CLPlacemark *placemark) {
        weakSelf.placemark = placemark;
        NSDictionary *addressDictionary = weakSelf.placemark.addressDictionary;
        WYLog(@"Placemark addressDictionary: %@ %@", addressDictionary,weakSelf.placemark.locality);
        [weakSelf refreshLocationViewUI:2];
        [weakSelf validateArea:weakSelf.placemark.locality];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initNormalTitleNavBarSubviews{
    [self setTitle:@"选择城市"];
}

-(void)getCacheValidCitys{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] addGetCacheTag:tag];
    [[WYEngine shareInstance] getAllValidCityListWithTag:tag];
    [[WYEngine shareInstance] getCacheReponseDicForTag:tag complete:^(NSDictionary *jsonRet){
        if (jsonRet == nil) {
            //...
        }else{
            weakSelf.cityArray = [[NSMutableArray alloc] init];
            NSArray *citys = [jsonRet arrayObjectForKey:@"object"];
            for (NSDictionary *dic in citys) {
                [weakSelf.cityArray addObject:dic];
            }
            [weakSelf refreshCityView];
        }
    }];
}

-(void)refreshValidCityList{
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] getAllValidCityListWithTag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            return;
        }
        weakSelf.cityArray = [[NSMutableArray alloc] init];
        NSArray *citys = [jsonRet arrayObjectForKey:@"object"];
        for (NSDictionary *dic in citys) {
            [weakSelf.cityArray addObject:dic];
        }
        [weakSelf refreshCityView];
    }tag:tag];
}

- (void)validateArea:(NSString *)city{
    if (!city) {
        city = self.placemark.locality;
    }
    WS(weakSelf);
    int tag = [[WYEngine shareInstance] getConnectTag];
    [[WYEngine shareInstance] validateAreaWithAreaName:city tag:tag];
    [[WYEngine shareInstance] addOnAppServiceBlock:^(NSInteger tag, NSDictionary *jsonRet, NSError *err) {
        NSString* errorMsg = [WYEngine getErrorMsgWithReponseDic:jsonRet];
        if (!jsonRet || errorMsg) {
            if (!errorMsg.length) {
                errorMsg = @"请求失败";
            }
//            [WYProgressHUD AlertError:errorMsg At:weakSelf.view];
            int code = [jsonRet intValueForKey:@"code"];
            if (code == 1){
                weakSelf.hintLabel.text = @"未开通";
                weakSelf.currentCityButton.enabled = NO;
            }
            return;
        }
        int code = [jsonRet intValueForKey:@"code"];
        if (code == 0) {
            weakSelf.hintLabel.text = @"已开通";
            weakSelf.currentCityButton.enabled = YES;
            weakSelf.cityCode = [jsonRet stringObjectForKey:@"object"];
        }
        
    }tag:tag];
}

- (void)refreshLocationViewUI:(int)type{
    if (type == 0) {
        //定位中
        [self.currentCityButton setTitle:@"定位中..." forState:0];
        self.currentCityButton.enabled = NO;
        self.hintLabel.text = @"定位中...";
    }else if (type == 1){
        //定位失败
        [self.currentCityButton setTitle:@"定位失败" forState:0];
        self.currentCityButton.enabled = NO;
        self.hintLabel.text = @"获取地址位置失败，请选择城市";
    }else if (type == 2){
        //定位成功
        [self.currentCityButton setTitle:self.placemark.locality forState:0];
        self.currentCityButton.enabled = NO;
        self.hintLabel.text = @"";
    }
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
    if (self.cityScrollView.superview) {
        [self.cityScrollView removeFromSuperview];
    }
    self.cityScrollView.frame = CGRectMake(0, 42, SCREEN_WIDTH, 177);
    [self.lightupCityView addSubview:self.cityScrollView];
    
    CGRect frame = self.hintLabel.frame;
    frame.origin.x = self.currentCityButton.frame.size.width + 24;
    self.hintLabel.frame = frame;
    
//    frame = self.lightupCityView.frame;
    
    int index = 0;
    for (NSDictionary *cityInfo in self.cityArray) {
        CGFloat width = (SCREEN_WIDTH - 24 - 30)/3;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(12 + (index%3)*(width + 15), (index/3)*(34+12), width, 34)];
        button.titleLabel.font = SKIN_FONT_FROMNAME(14);
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle:[cityInfo stringObjectForKey:@"name"] forState: UIControlStateNormal];
        button.tag = index;
        [button setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0];
        [button.layer setBorderWidth:0.5];
        [button.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
        [button addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.cityScrollView addSubview:button];
        if (index > 5) {
//            frame.size.height = 134 + (index/3 - 1)*(34+12);
//            self.lightupCityView.frame = frame;
            self.cityScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, (index/3 + 1)*(34+12));
        }
        index ++;
    }
    frame = self.noticeView.frame;
    frame.origin.y = self.lightupCityView.frame.origin.y + self.lightupCityView.frame.size.height;
    self.noticeView.frame = frame;
}

- (IBAction)locationAction:(id)sender {
//    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    [appDelegate.mainTabViewController.tabBar selectIndex:0];
    
    NSMutableDictionary *cityDic = nil;
    if (sender == self.currentCityButton) {
        cityDic = [[NSMutableDictionary alloc] init];
        if (_cityCode.length > 0) {
            [cityDic setObject:_cityCode forKey:@"areaCode"];
        }
        if (self.placemark.locality.length > 0) {
            [cityDic setObject:self.placemark.locality forKey:@"name"];
        }
    }else{
        UIButton *button = (UIButton*)sender;
        NSInteger index = button.tag;
        if (index >= 0 && index < self.cityArray.count) {
            cityDic = [self.cityArray objectAtIndex:index];
        }
    }
    if ([self.delagte respondsToSelector:@selector(locationViewControllerWith:selectCity:)]) {
        [self.delagte locationViewControllerWith:self selectCity:cityDic];
    }
}

@end
