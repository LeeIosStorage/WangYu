//
//  WYPageControl.m
//  WangYu
//
//  Created by XuLei on 15/6/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYPageControl.h"
#import "WYCommonUtils.h"

@interface WYPageControl()

@property (nonatomic, strong) UIImage *activeImage;
@property (nonatomic, strong) UIImage *inactiveImage;
@end

@implementation WYPageControl

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _activeImage= [UIImage imageNamed:@"welcome_pagecontrol_select_icon"];
        _inactiveImage= [UIImage imageNamed:@"welcome_pagecontrol_unselect_icon"];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _activeImage= [UIImage imageNamed:@"welcome_pagecontrol_select_icon"];
        _inactiveImage= [UIImage imageNamed:@"welcome_pagecontrol_unselect_icon"];
    }
    return self;
}


- (void)updateDots
{
    for(int i = 0; i< [self.subviews count]; i++) {
        
        
        UIImageView* dot = [self.subviews objectAtIndex:i];
        
        UIView *view = [self.subviews objectAtIndex:i];
        view.backgroundColor = [UIColor clearColor];
        dot =(UIImageView *) [view viewWithTag:101];
            
        if(!dot)
        {
            UIImageView *imageView  = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
            imageView.tag = 101;
            dot = imageView;
            [view addSubview:dot];
                
        }
        dot.backgroundColor = [UIColor clearColor];
        if(i == self.currentPage){
            dot.image= _activeImage;
        }
        else
            dot.image= _inactiveImage;
    }
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

//设置点的颜色
-(void)setDotImage:(UIImage *) dotImage selectedImage:(UIImage *)selectedImage
{
    if (dotImage) {
        _inactiveImage = dotImage;
    }
    
    if (selectedImage) {
        _activeImage = selectedImage;
    }
    
    [self updateDots];
}


@end
