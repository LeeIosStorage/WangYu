//
//  PullToRefreshView.m
//  Grant Paul (chpwn)
//
//  (based on EGORefreshTableHeaderView)
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
// 
// The MIT License (MIT)
// Copyright © 2012 Sonny Parlin, http://sonnyparlin.com
// 
// //  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullToRefreshView.h"
//#import "LSMediaPlayer.h"

#define PULL_NOTE   @"下拉刷新" //@"Pull down to refresh..."
#define RELEASE_NOTE    @"释放更新" //@"Release to refresh..."
#define LAST_UPDATE_NOTE    @"最后更新: %@"
#define LOADING_INFO    @"加载中..."

//#define TEXT_COLOR	 [UIColor colorWithRed:(87.0/255.0) green:(108.0/255.0) blue:(137.0/255.0) alpha:1.0]
#define TEXT_COLOR  [UIColor colorWithRed:(1.0*0x9a/0xff) green:(1.0*0x9a/0xff) blue:(1.0*0x9a/0xff) alpha:1]
#define FLIP_ANIMATION_DURATION 0.18f


@interface PullToRefreshView (Private)

@property (nonatomic, assign) PullToRefreshViewState state;

@end

@implementation PullToRefreshView
@synthesize delegate, scrollView;

- (void)showActivity:(BOOL)shouldShow animated:(BOOL)animated {
    if (shouldShow) [activityView startAnimating];
    else [activityView stopAnimating];
    
    [UIView animateWithDuration:(animated ? 0.1f : 0.0) animations:^{
        arrowImage.opacity = (shouldShow ? 0.0 : 1.0);
    }];
}

- (void)setImageFlipped:(BOOL)flipped {
    [UIView animateWithDuration:0.1f animations:^{
        arrowImage.transform = (flipped ? CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f) : CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f));
    }];
}

- (id)initWithScrollView:(UIScrollView *)scroll {
    CGRect frame = CGRectMake(0.0f, 0.0f - scroll.bounds.size.height, scroll.bounds.size.width, scroll.bounds.size.height);
    
    if ((self = [super initWithFrame:frame])) {
        scrollView = scroll;
        _oldOriginalTopInset = scrollView.contentInset.top;
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
        self.backgroundColor = scroll.backgroundColor;
        
		lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
		lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastUpdatedLabel.font = SKIN_FONT_FROMNAME(12);
		lastUpdatedLabel.textColor = TEXT_COLOR;
//		lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		lastUpdatedLabel.backgroundColor = [UIColor clearColor];
		lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:lastUpdatedLabel];
        
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
		statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		statusLabel.font = SKIN_FONT_FROMNAME(13);
		statusLabel.textColor = TEXT_COLOR;
//		statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:statusLabel];
        
		arrowImage = [[CALayer alloc] init];
		arrowImage.frame = CGRectMake(10.0f, frame.size.height - 60.0f, 24.0f, 52.0f);
		arrowImage.contentsGravity = kCAGravityResizeAspect;
//		arrowImage.contents = (id) [UIImage imageNamed:@"arrow"].CGImage;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			arrowImage.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
        
		[self.layer addSublayer:arrowImage];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake(20.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
		[self addSubview:activityView];
		
			self.enabled = YES;
		[self setState:PullToRefreshViewStateNormal];
    }
    
    return self;
}

#pragma mark -
#pragma mark Setters

- (void)setEnabled:(BOOL)enabled
{
	if (enabled == _enabled)
		return;
	
	_enabled = enabled;
	[UIView animateWithDuration:0.25
									 animations:
	 ^{
		 self.alpha = enabled ? 1 : 0;
	 }];
}

- (void)refreshLastUpdatedDate {
    NSDate *date = [NSDate date];
    
	if ([delegate respondsToSelector:@selector(pullToRefreshViewLastUpdated:)])
		date = [delegate pullToRefreshViewLastUpdated:self];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateStyle:(NSInteger)kCFDateFormatterShortStyle];
    [formatter setTimeStyle:(NSInteger)kCFDateFormatterShortStyle];
    lastUpdatedLabel.text = [NSString stringWithFormat:LAST_UPDATE_NOTE, [formatter stringFromDate:date]];
}

- (void)setState:(PullToRefreshViewState)state_ {
    state = state_;
    NSLog(@"state=%d", state);
    
    UIEdgeInsets contentInset = scrollView.contentInset;

	switch (state) {
		case PullToRefreshViewStateReady:
			statusLabel.text = RELEASE_NOTE;
			[self showActivity:NO animated:NO];
            [self setImageFlipped:YES];
            contentInset.top = _oldOriginalTopInset;
            scrollView.contentInset = contentInset;
			break;
            
		case PullToRefreshViewStateNormal:
			statusLabel.text = PULL_NOTE;
			[self showActivity:NO animated:NO];
            [self setImageFlipped:NO];
			[self refreshLastUpdatedDate];
            contentInset.top = _oldOriginalTopInset;
            scrollView.contentInset = contentInset;
			break;
            
		case PullToRefreshViewStateLoading:
			statusLabel.text = LOADING_INFO;
			[self showActivity:YES animated:YES];
            [self setImageFlipped:NO];
            contentInset.top = 60.0f + _oldOriginalTopInset;
            scrollView.contentInset = contentInset;
			break;
            
		default:
			break;
	}
}
- (void)triggerPullToRefresh{
    self.state = PullToRefreshViewStateReady;
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -(65.0f+_oldOriginalTopInset)) animated:NO];
    //self.state = PullToRefreshViewStateLoading;
}
#pragma mark -
#pragma mark UIScrollView

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //NSLog(@"contentOffset=%f", scrollView.contentOffset.y);
    if ([keyPath isEqualToString:@"contentOffset"] && self.isEnabled) {
        if (scrollView.isDragging) {
            if (state == PullToRefreshViewStateReady) {
                if (scrollView.contentOffset.y > -(65.0f+_oldOriginalTopInset) && scrollView.contentOffset.y < 0.0f)
                    [self setState:PullToRefreshViewStateNormal];
            } else if (state == PullToRefreshViewStateNormal) {
                if (scrollView.contentOffset.y < -(65.0f+_oldOriginalTopInset))
                    [self setState:PullToRefreshViewStateReady];
            } else if (state == PullToRefreshViewStateLoading) {
                UIEdgeInsets contentInset = scrollView.contentInset;
                if (scrollView.contentOffset.y >= 0){
                    contentInset.top = 0;
                    scrollView.contentInset = contentInset;
                }     
                else {
                    contentInset.top = MIN(-scrollView.contentOffset.y, 60.0f);
                    scrollView.contentInset = contentInset; 
                }
                    
            }
        } else {
            if (state == PullToRefreshViewStateReady) {
                [UIView animateWithDuration:0.2f animations:^{
                    [self setState:PullToRefreshViewStateLoading];
                }];
                
                if ([delegate respondsToSelector:@selector(pullToRefreshViewShouldRefresh:)])
                    [delegate pullToRefreshViewShouldRefresh:self];
            }
        }
        self.frame = CGRectMake(scrollView.contentOffset.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
}

- (void)finishedLoading {
//    [[LSMediaPlayer shareInstance] playRefreshSound]; //暂时去掉，等统一声音以后再加上
    if (state == PullToRefreshViewStateLoading) {
        [UIView animateWithDuration:0.3f animations:^{
            [self setState:PullToRefreshViewStateNormal];
        }];
    }
}
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *lscrollView = (UIScrollView *)self.superview;
        [lscrollView removeObserver:self forKeyPath:@"contentOffset"];

    }
}
#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	//[scrollView removeObserver:self forKeyPath:@"contentOffset"];
	//scrollView = nil;
}

@end
