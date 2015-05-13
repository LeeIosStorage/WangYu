//
//  WYSearchBar.m
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSearchBar.h"

@interface WYSearchBar ()
{
    UIImageView *_customBgImageView;
}
@end

@implementation WYSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSearchBar];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSearchBar];
    }
    return self;
}

-(void) setupSearchBar
{
    UIColor *bgColor = [UIColor clearColor];
    for (UIView *v in self.subviews) {
        NSArray *subViews = v.subviews;
        for (id view in subViews) {
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
                [view removeFromSuperview];
            }
        }
    }
    [self setBackgroundColor:bgColor];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UITextField *searchField;
    for (UIView *v in self.subviews) {
        NSArray *subViews = v.subviews;
        for (id view in subViews) {
            if ([view isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                searchField = view;
            }
        }
    }
//    NSUInteger numViews = [self.subviews count];
//    for(int i = 0; i < numViews; i++) {
//        UIView *view = [self.subviews objectAtIndex:i];
//        NSArray *views = view.subviews;
//        if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
//            searchField = [self.subviews objectAtIndex:i];
//            
////            //自定义leftView大小
////            //            CGRect seaFrame = searchField.leftView.frame;
////            //            seaFrame.size.width = 30;
////            //            seaFrame.size.height = 15;
////            //            searchField.leftView.frame = seaFrame;
////            //            searchField.leftView.backgroundColor = [UIColor clearColor];
////            
////            //            UIImageView *iView = [[UIImageView alloc] init];
////            //            iView.backgroundColor = [UIColor redColor];
////            //            iView.frame = CGRectMake(0, 0, 30, 16);
////            //            UIImageView *icon_View = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchBar_icon.png"]];
////            //            icon_View.frame = CGRectMake(10, 0, 16, 16);
////            //            [iView addSubview:icon_View];
////            //            [searchField.leftView addSubview:iView];
////            //            searchField.leftView.hidden = YES;
////            
////            //自定义searchField大小
////            CGRect frame = searchField.frame;
////            frame.size.height = SearchField_CustomHeight;
////            searchField.frame = frame;
//        }
//    }
    if(!(searchField == nil)) {
        
        searchField.background = nil;
        searchField.backgroundColor = UIColorRGB(254, 234, 141);
        searchField.borderStyle = UITextBorderStyleNone;
        CGRect frame = self.bounds;
        
        
        //背景
        if (!_customBgImageView) {
            _customBgImageView = [[UIImageView alloc] init];
            _customBgImageView.backgroundColor = UIColorRGB(254, 234, 141);
            _customBgImageView.frame = CGRectMake(frame.origin.x + 6, frame.origin.y + 6, self.bounds.size.width-12, frame.size.height - 13);
            [_customBgImageView.layer setMasksToBounds:YES];
            [_customBgImageView.layer setCornerRadius:4.0];
            [self insertSubview:_customBgImageView atIndex:0];
        }else{
            _customBgImageView.frame = CGRectMake(frame.origin.x + 6, frame.origin.y + 6, self.bounds.size.width-12, frame.size.height - 13);
        }
        
    }
    
    [self setImage:[UIImage imageNamed:@"searchBar_icon.png"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self layoutSubviews];
    
}


@end
