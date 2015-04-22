//
//  XETabBarItemView.m
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import "XETabBarItemView.h"

@interface XETabBarItemView ()

@property (strong, nonatomic) UIImageView* redIconView;
@end

@implementation XETabBarItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)itemTouchDown:(id)sender {
    if (self.delegate) {
        [self.delegate selectForItemView:self];
    }
}

-(bool)selected{
    return self.itemBtn.selected;
}

-(void)setSelected:(bool)selected{
    
    self.itemBtn.selected = selected;
    self.bkImageView.highlighted = selected;
    self.itemIconImageView.highlighted = selected;
    //[self setNeedsLayout];
}

- (UIImageView *)redIconView {
    if (_redIconView == nil) {
        _redIconView = [[UIImageView alloc] init];
        _redIconView.image = [UIImage imageNamed:@"s_n_round_red.png"];
        _redIconView.hidden = YES;
    }
    return _redIconView;
}


- (void)setBadgeNum:(int)badgeNum {
    _badgeNum = badgeNum;
    if (badgeNum > 0) {
        self.redIconView.hidden = YES;
    } else if (badgeNum == -1) {
        self.redIconView.hidden = NO;
    } else if (badgeNum == 0) {
        self.redIconView.hidden = YES;
    }
}

@end
