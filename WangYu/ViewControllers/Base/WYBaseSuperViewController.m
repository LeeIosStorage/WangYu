//
//  WYBaseSuperViewController.m
//  Xiaoer
//
//  Created by KID on 14/12/31.
//
//

#import "WYBaseSuperViewController.h"
#import "WYTitleNavBarView.h"

@interface WYBaseSuperViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton  *titleNavBarLeftButton;
@property (nonatomic, strong) UIButton  *titleNavBarLeftButton2;
@property (nonatomic, strong) UIView  *titleNavBarLeftCustomView;

@end

@implementation WYBaseSuperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];//UIColorRGB(240, 240, 240)
    self.view.clipsToBounds = YES;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    BOOL isAddTitleNavBar = NO;
    if (!_titleNavBar) {
        isAddTitleNavBar = YES;
        [self initTitleNavBar];
        
        [self.view insertSubview:_titleNavBar atIndex:0];
    }
    //不让系统给边缘view添加偏移
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    //ios7.0以上的系统都要改变下位置
    BOOL isNeedOffset = YES;
    for (UIView *subview in [self.view subviews]) {
        if ([self.titleNavBar isEqual:subview]) {
            [self.view bringSubviewToFront:self.titleNavBar];
            if (isNeedOffset) {
                [WYUIUtils updateFrameWithView:subview superView:self.view isAddHeight:YES];
            }
        }else{
            BOOL isChange = YES;
            if (isNeedOffset) {
                isChange = [WYUIUtils updateFrameWithView:subview superView:self.view isAddHeight:NO];
            }else{
                //7.0以前的只要判断size是否跟父view 一样
                isChange = !(subview.frame.size.height >= self.view.frame.size.height || (isAddTitleNavBar && subview.frame.origin.y < self.titleNavBar.frame.size.height));
            }
            
            //如果view是tableview或其子view的时候设置contentInset
            if (!isChange && [subview isKindOfClass:[UIScrollView class]]){
                [self setContentInsetForScrollView:((UIScrollView *)subview)];
            }
        }
    }
    
    //normal title view
    if ([_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        [self initNormalTitleNavBarSubviews];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(BOOL) isHasNormalTitle
{
    return YES;
}

-(void) initTitleNavBar
{
    if (![self isHasNormalTitle]) {
        return;
    }
    _titleNavBar = [[WYTitleNavBarView alloc] init:self];
    
    if ([_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        _titleNavBarLeftButton = ((WYTitleNavBarView *) _titleNavBar).toolBarLeftButton;
        _titleNavBarLeftButton2 = ((WYTitleNavBarView *) _titleNavBar).toolBarLeftButton2;
        _titleNavBarRightBtn = ((WYTitleNavBarView *) _titleNavBar).toolBarRightButton;
        _titleNavBarRightBtn2 = ((WYTitleNavBarView *) _titleNavBar).toolBarRightButton2;
        _segmentedControl = ((WYTitleNavBarView *) _titleNavBar).segmentedControl;
        _titleNavImageView = ((WYTitleNavBarView *) _titleNavBar).navImageView;
        _segmentedControl.hidden = YES;
    }
}

//title
-(void) setTitle:(NSString *) title
{
    if (!_titleLabel) {
        if ([_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
            _titleLabel = [((WYTitleNavBarView *) _titleNavBar) setTitle:title];
        }else{
            super.title = title;
        }
    }else{
        [_titleLabel setText:title];
    }
}
-(void) setTitle:(NSString *) title font:(UIFont *) font
{
    if (!_titleLabel) {
        if ([_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
            _titleLabel = [((WYTitleNavBarView *) _titleNavBar) setTitle:title font:font];
        }
    }else{
        [_titleLabel setText:title];
        _titleLabel.font = font;
    }
    
}

-(void) initNormalTitleNavBarSubviews{
    
}

-(void) setTilteLeftViewHide:(BOOL)isHide{
    
    if (_titleNavBarLeftButton) {
        _titleNavBarLeftButton.hidden = isHide;
    }
    
    if (_titleNavBarLeftCustomView) {
        _titleNavBarLeftCustomView.hidden = isHide;
    }
}

-(void) setSegmentedControlWithSelector:(SEL) selector items:(NSArray *)items{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (!_segmentedControl) {
        _segmentedControl = ((WYTitleNavBarView *) _titleNavBar).segmentedControl;
    }
    if (_segmentedControl) {
        _segmentedControl.hidden = NO;
        _titleLabel.hidden = YES;
        for (int index = 0; index < items.count; index ++ ) {
            id title = [items objectAtIndex:index];
            if ([title isKindOfClass:[NSString class]]) {
                [_segmentedControl setTitle:title forSegmentAtIndex:index];
            }
        }
        _segmentedControl.tintColor = [UIColor whiteColor];
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:selector forControlEvents:UIControlEventValueChanged];
    }
}

//返回按钮, 前面默认是的back

-(void) setLeftButtonTitle:(NSString *) buttonTitle
{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (_titleNavBarLeftButton) {
        [_titleNavBarLeftButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

-(void) setLeftButtonWithSelector:(SEL) selector
{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    if (_titleNavBarLeftButton) {
        _titleNavBarLeftButton.hidden = NO;
        [_titleNavBarLeftButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void) setLeftButtonWithTitle:(NSString *) buttonTitle selector:(SEL) selector
{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (_titleNavBarLeftButton2) {
        _titleNavBarLeftButton2.hidden = NO;
        [_titleNavBarLeftButton2 setTitle:buttonTitle forState:UIControlStateNormal];
        [_titleNavBarLeftButton2 addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void) setLeftButtonWithImageName:(NSString *) butonImageName
{
    [self setLeftButtonWithImage:[UIImage imageNamed:butonImageName]];
}
-(void) setLeftButtonWithImage:(UIImage *) butonImage
{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]])
    {
        return;
    }
    if (_titleNavBarLeftButton) {
        [_titleNavBarLeftButton setImage:butonImage forState:UIControlStateNormal];
    }
}
-(void) setLeftButtonWithImageName:(NSString *) butonImageName selector:(SEL) selector
{
    [self setLeftButtonWithImage:[UIImage imageNamed:butonImageName] selector:selector];
}
-(void) setLeftButtonWithImage:(UIImage *) butonImage selector:(SEL) selector
{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]])
    {
        return;
    }
    if (_titleNavBarLeftButton) {
        _titleNavBarLeftButton.hidden = NO;
        [_titleNavBarLeftButton setImage:butonImage forState:UIControlStateNormal];
        [_titleNavBarLeftButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}


//right button
-(void) setRightButtonWithTitle:(NSString *) buttonTitle{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (_titleNavBarRightBtn) {
        _titleNavBarRightBtn.hidden = NO;
        [_titleNavBarRightBtn setTitle:buttonTitle forState:UIControlStateNormal];
    }
}
-(void) setRightButtonWithTitle:(NSString *) buttonTitle selector:(SEL) selector
{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (_titleNavBarRightBtn) {
        _titleNavBarRightBtn.hidden = NO;
        [_titleNavBarRightBtn setTitle:buttonTitle forState:UIControlStateNormal];
        [_titleNavBarRightBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

//customview

-(void) setRightButtonWithImageName:(NSString *) butonImageName selector:(SEL) selector
{
    return [self setRightButtonWithImage:[UIImage imageNamed:butonImageName] selector:selector];
}
-(void) setRightButtonWithImage:(UIImage *) butonImage selector:(SEL) selector
{
    if ([_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        _titleNavBarRightBtn.hidden = NO;
        [_titleNavBarRightBtn setImage:butonImage forState:UIControlStateNormal];
        [_titleNavBarRightBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void) setRight2ButtonWithTitle:(NSString *) buttonTitle selector:(SEL) selector{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (_titleNavBarRightBtn2) {
        _titleNavBarRightBtn2.hidden = NO;
        [_titleNavBarRightBtn2 setTitle:buttonTitle forState:UIControlStateNormal];
        [_titleNavBarRightBtn2 addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}
-(void) setRight2ButtonWithImageName:(NSString *) butonImageName selector:(SEL) selector{
    if ([_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        _titleNavBarRightBtn2.hidden = NO;
        [_titleNavBarRightBtn2 setImage:[UIImage imageNamed:butonImageName] forState:UIControlStateNormal];
        [_titleNavBarRightBtn2 addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void) setLeft2ButtonWithImageName:(NSString *) butonImageName selector:(SEL) selector{
    if (![_titleNavBar isMemberOfClass:[WYTitleNavBarView class]]) {
        return;
    }
    
    if (_titleNavBarLeftButton2) {
        _titleNavBarLeftButton2.hidden = NO;
        [_titleNavBarLeftButton2 setImage:[UIImage imageNamed:butonImageName] forState:UIControlStateNormal];
        [_titleNavBarLeftButton2 addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - ScrollViewContentInset
-(void) setContentInsetForScrollView:(UIScrollView *) scrollview
{
    if (![scrollview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    CGFloat topInset = 0;
    if (!self.titleNavBar) {
        topInset = WY_Default_TitleNavBar_Height;
    }else{
        topInset = self.titleNavBar.frame.size.height;
    }
    
    UIEdgeInsets inset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    
    [self setContentInsetForScrollView:scrollview inset:inset];
}

-(void) setContentInsetForScrollView:(UIScrollView *) scrollview inset:(UIEdgeInsets) inset
{
    if (![scrollview isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    [scrollview setContentInset:inset];
    [scrollview setScrollIndicatorInsets:inset];
}

@end
