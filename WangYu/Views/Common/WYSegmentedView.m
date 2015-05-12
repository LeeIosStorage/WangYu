//
//  WYSegmentedView.m
//  WangYu
//
//  Created by KID on 15/5/12.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYSegmentedView.h"

#define BGImageView_Tag        1001
#define SelectedImageView_Tag  1002

@implementation WYSegmentedView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    if (!_borderColor) {
        _borderColor = UIColorToRGB(0xffffff);
    }
    if (!_selectedColor) {
        _selectedColor = UIColorToRGB(0xe4bf23);
    }
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    bgImageView.backgroundColor = [UIColor clearColor];
    [bgImageView.layer setMasksToBounds:YES];
    [bgImageView.layer setCornerRadius:4.0];
    [bgImageView.layer setBorderWidth:0.5]; //边框宽度
    [bgImageView.layer setBorderColor:_borderColor.CGColor];//边框颜色
    bgImageView.tag = BGImageView_Tag;
    [self addSubview:bgImageView];
    
    UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    selectedImageView.backgroundColor = _selectedColor;
    [selectedImageView.layer setMasksToBounds:YES];
    [selectedImageView.layer setCornerRadius:4.0];
    [selectedImageView.layer setBorderWidth:0.5]; //边框宽度
    [selectedImageView.layer setBorderColor:_borderColor.CGColor];//边框颜色
    selectedImageView.tag = SelectedImageView_Tag;
    [self addSubview:selectedImageView];
}

-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    UIImageView *bgImageView = (UIImageView *)[self viewWithTag:BGImageView_Tag];
    UIImageView *selectedImageView = (UIImageView *)[self viewWithTag:SelectedImageView_Tag];
    [bgImageView.layer setBorderColor:_borderColor.CGColor];
    [selectedImageView.layer setBorderColor:_borderColor.CGColor];
}

-(void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
    UIImageView *selectedImageView = (UIImageView *)[self viewWithTag:SelectedImageView_Tag];
    selectedImageView.backgroundColor = _selectedColor;
}

-(void)setItems:(NSArray *)items{
    int itemsCount = (int)items.count;
    UIImageView *selectedImageView = (UIImageView *)[self viewWithTag:SelectedImageView_Tag];
    selectedImageView.frame = CGRectMake(0, 0, self.bounds.size.width/itemsCount, self.bounds.size.height);
    int index = 0;
    for (id title in items) {
        if ([title isKindOfClass:[NSString class]]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(index*selectedImageView.frame.size.width, 0, selectedImageView.frame.size.width, self.bounds.size.height);
            button.backgroundColor = [UIColor clearColor];
            button.titleLabel.font = SKIN_FONT(14);
            [button setTitleColor:SKIN_TEXT_COLOR1 forState:0];
            [button setTitle:title forState:0];
            button.tag = index;
            [button addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            
            index ++;
        }
    }
}

-(void)handleAction:(id)sender{
    UIButton *button = (UIButton*)sender;
    NSInteger tag = button.tag;
    UIImageView *selectedImageView = (UIImageView *)[self viewWithTag:SelectedImageView_Tag];
    CGRect frame = selectedImageView.frame;
    frame.origin.x = tag*frame.size.width;
    selectedImageView.frame = frame;
    
    if (sender) {
        _segmentedButtonClickBlock(tag);
    }
}

@end
