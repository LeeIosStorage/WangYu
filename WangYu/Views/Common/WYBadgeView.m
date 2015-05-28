//
//  WYBadgeView.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYBadgeView.h"
#import "WYCommonUtils.h"

@interface WYBadgeView ()
@property(nonatomic, strong) UIImageView* imageView;
@property(nonatomic, strong) UILabel* label;
@end

@implementation WYBadgeView

- (void)initSubview{
    self.userInteractionEnabled = YES;
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _imageView.userInteractionEnabled = YES;
    _imageView.image = [[UIImage imageNamed:@"s_n_round_red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self addSubview:_imageView];
    CGRect labelFrame = self.bounds;
    labelFrame.origin.x = 5;
    labelFrame.size.width -= 10;
    
    _label = [[UILabel alloc] initWithFrame:labelFrame];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.userInteractionEnabled = YES;
    _font = [UIFont systemFontOfSize:13];
    _label.font = _font;
    _label.textColor = [UIColor whiteColor];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.backgroundColor = [UIColor clearColor];
    [self addSubview:_label];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubview];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSubview];
    }
    return self;
}
- (void)resetViewsFrame {
    CGRect badgeViewFrame = self.frame;
//    float rightEdge = badgeViewFrame.origin.x + badgeViewFrame.size.width;
    float padding = 9;
    
    int width = 20;
    if (_unreadNum > 9) {
        width = 24;
    }
    
    float fwidth = [WYCommonUtils widthWithText:self.text font:self.font lineBreakMode:NSLineBreakByWordWrapping] + padding;
    badgeViewFrame.size.width = fwidth;
    if (badgeViewFrame.size.width < width) {
        badgeViewFrame.size.width = width;
    }
//    badgeViewFrame.origin.x = rightEdge - badgeViewFrame.size.width;
    self.frame = badgeViewFrame;
    
    CGRect labelFrame = self.bounds;
    labelFrame.origin.x = (labelFrame.size.width - (fwidth-padding))/2;
    labelFrame.size.width = fwidth - padding;
    _label.frame = labelFrame;
}

-(void)setUnreadNum:(int)unreadNum{
    if (_unreadNum == unreadNum) {
        return;
    }
    _unreadNum = unreadNum;
    
    if (unreadNum > 99) {
        _text = @"99+";
    }else{
        _text = [NSString stringWithFormat:@"%d", unreadNum];
    }
    _label.text = _text;
    [self resetViewsFrame];
}

- (void)setText:(NSString *)text{
    _text = text;
    _label.text = _text;
    [self resetViewsFrame];
}
- (void)setFont:(UIFont *)font{
    _font = font;
    _label.font = _font;
    [self resetViewsFrame];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//更新背景色
-(void)updateBadgeViewImage:(NSString *) imageName
{
    if (!imageName.length) {
        imageName = @"s_n_round_red";
    }
    _imageView.image = [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
}

@end
