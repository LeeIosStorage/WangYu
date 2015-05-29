//
//  XEScrollPage.m
//  Xiaoer
//
//  Created by KID on 15/1/15.
//
//

#import "WYScrollPage.h"
#import "UIImageView+WebCache.h"
//#import "WYThemeInfo.h"
#import "ActivityTabViewController.h"

#define WY_ADS_BASE_TAG 10010
#define UNSelected_Color [UIColor colorWithRed:(1.0 * 172 / 255) green:(1.0 * 177 / 255) blue:(1.0 * 183 / 255) alpha:1]

@interface WYScrollPage ()<UIScrollViewDelegate>{
    NSTimer *_myTimer;
}

@property (strong, nonatomic) IBOutlet UIButton *adsHideBtn;
@property (strong, nonatomic) IBOutlet UIScrollView *adsScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *adsPageControl;

- (IBAction)pageControlValueChanged:(id)sender;
- (IBAction)adsHideAction:(id)sender;

@end

@implementation WYScrollPage

- (id)initWithFrame:(CGRect)frame
{
    self = [[[NSBundle mainBundle] loadNibNamed:@"WYScrollPage" owner:self options:nil] objectAtIndex:0];
    if (self) {
        //.....
        self.frame = frame;
        _adsScrollView.frame = frame;
    }
    return self;
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = [NSMutableArray arrayWithArray:dataArray];
    [self initScrollPage];
}

- (void)initScrollPage{
    
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    
    CGRect frame = self.bounds;
    _adsPageControl.currentPageIndicatorTintColor = SKIN_COLOR;
    _adsPageControl.pageIndicatorTintColor = UNSelected_Color;
//    [_adsPageControl setDotImage:[UIImage imageNamed:@"found_pagecontrol_unselected@2x.png"] selectedImage:[UIImage imageNamed:@"found_pagecontrol_selected@2x.png"]];
//    这两行要加 防止再刷新的时候不更新画面
    _adsPageControl.currentPage = 0;
    _adsScrollView.contentSize = CGSizeMake(frame.size.width, frame.size.height);
    [self refreshWithFrame:frame];
    
    if (_dataArray.count > 1) {
        _myTimer=[NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
        _adsPageControl.hidden = NO;
    }else {
        _adsPageControl.hidden = YES;
    }
}

- (void)refreshWithFrame:(CGRect)frame{
    
    if (_adsType == AdsType_Theme) {
        [_adsHideBtn setHidden:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAdsViewShow:) name:WY_MAIN_SHOW_ADS_VIEW_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setAdsViewStop:) name:WY_MAIN_STOP_ADS_VIEW_NOTIFICATION object:nil];
    }

//    WYThemeInfo *theme;
//    theme = [_dataArray lastObject];
//    [self addSubviewToScrollView:_adsScrollView withURL:theme.originalThemeImageUrl withTag:-1];
//    for (int i = 0; i < [_dataArray count]; i++) {
//        theme = [_dataArray objectAtIndex:i];
//        [self addSubviewToScrollView:_adsScrollView withURL:theme.originalThemeImageUrl withTag:i];
//    }
//    
//    theme = [_dataArray firstObject];
//    [self addSubviewToScrollView:_adsScrollView withURL:theme.originalThemeImageUrl withTag:_dataArray.count];
    
    //多算两屏,默认第二屏
    _adsScrollView.contentSize = CGSizeMake((_dataArray.count + 2)*frame.size.width,frame.size.height);
    [_adsScrollView scrollRectToVisible:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height) animated:NO];
    //设置pageControl属性
    _adsPageControl.numberOfPages = _dataArray.count;
}

- (void)addSubviewToScrollView:(UIScrollView *)scrollView withURL:(NSString *)url withTag:(NSInteger)tag{
    
    UIImage *holderImage = [UIImage imageNamed:@"activity_load_icon"];
    CGRect frame = scrollView.bounds;
    
    CGRect vFrame = frame;
    vFrame.origin.x = (tag+1)*vFrame.size.width;
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    view.frame = vFrame;
    view.clipsToBounds = YES;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = frame;
    if (tag == -1) {
        button.tag = WY_ADS_BASE_TAG + tag + 1;
    }else if(tag == _dataArray.count){
        button.tag = WY_ADS_BASE_TAG + tag - 1;
    }else {
        button.tag = WY_ADS_BASE_TAG + tag;
    }
    [button addTarget:self action:@selector(handleClickAtAdsButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.frame = frame;
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:holderImage];
    
    [view addSubview:button];
    [view addSubview:imageView];
    
    [scrollView addSubview:view];
}

- (IBAction)pageControlValueChanged:(id)sender {
    NSInteger pageNum = _adsPageControl.currentPage;
    CGSize viewSize = _adsScrollView.frame.size;
    [_adsScrollView setContentOffset:CGPointMake((pageNum + 1) * viewSize.width, 0)];
    
    [_myTimer invalidate];
    _myTimer = nil;
}

- (IBAction)adsHideAction:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didTouchHideButton)]) {
        [_delegate didTouchHideButton];
    }
}

#pragma mark -- ads scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (![scrollView isEqual:_adsScrollView]) {
        return;
    }
    
    CGFloat pageWidth  = _adsScrollView.frame.size.width;
    CGFloat pageHeigth = _adsScrollView.frame.size.height;
    int currentPage = floor((_adsScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (currentPage == 0) {
        [_adsScrollView scrollRectToVisible:CGRectMake(pageWidth * _dataArray.count, 0, pageWidth, pageHeigth) animated:NO];
        _adsPageControl.currentPage = _dataArray.count - 1;
        return;
    }else if(currentPage == _dataArray.count + 1){
        [_adsScrollView scrollRectToVisible:CGRectMake(pageWidth, 0, pageWidth, pageHeigth) animated:NO];
        _adsPageControl.currentPage = 0;
        return;
    }
    _adsPageControl.currentPage = currentPage - 1;
}

-(void)scrollToNextPage:(id)sender {
//    NSLog(@"==================================%@",[NSDate date]);
    NSInteger pageNum = _adsPageControl.currentPage;
    CGSize viewSize = _adsScrollView.frame.size;
    CGRect rect = CGRectMake((pageNum + 2)*viewSize.width, 0, viewSize.width, viewSize.height);
    [_adsScrollView scrollRectToVisible:rect animated:YES];
    pageNum++;
    if (pageNum == _dataArray.count) {
        [_adsScrollView setContentOffset:CGPointMake(0, 0)];
        CGRect newRect = CGRectMake(viewSize.width, 0, viewSize.width, viewSize.height);
        [_adsScrollView scrollRectToVisible:newRect animated:YES];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = _adsScrollView.frame.size.width;
    int currentPage = floor((_adsScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (currentPage == 0) {
        _adsPageControl.currentPage = _dataArray.count - 1;
    }else if(currentPage == _dataArray.count + 1){
        _adsPageControl.currentPage = 0;
    }else if(currentPage < 0){//防止限时引起的crash
        _adsPageControl.currentPage = 0;
    }
    _adsPageControl.currentPage = currentPage - 1;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_myTimer invalidate];
    _myTimer = nil;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_dataArray.count > 1) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
    }
}

-(void)handleClickAtAdsButton:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(didTouchPageView:)]) {
        UIButton *btn = (UIButton *)sender;
        NSInteger tag = btn.tag - WY_ADS_BASE_TAG;
        [_delegate didTouchPageView:tag];
    }
}

-(void) setAdsViewShow:(NSNotification *)note{
    if (_myTimer.isValid) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
    if (_dataArray.count > 1) {
        _myTimer = [NSTimer scheduledTimerWithTimeInterval:_duration target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
    }
}

-(void) setAdsViewStop:(NSNotification *)note{
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
        _myTimer = nil;
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
