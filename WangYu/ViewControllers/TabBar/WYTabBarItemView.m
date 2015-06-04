//
//  WYTabBarItemView.m
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import "WYTabBarItemView.h"

@interface WYTabBarItemView ()

@property (strong, nonatomic) UIImageView* redIconView;
@end

@implementation WYTabBarItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _itemLabel.font = SKIN_FONT_FROMNAME(11);
        _itemLabel.textColor = SKIN_TEXT_COLOR1;
        CGRect frameLine = _lineImageView.frame;
        frameLine.size.height = 0.1f;
        _lineImageView.frame = frameLine;
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
        CGRect frame = self.itemIconImageView.frame;
        frame.origin.x = frame.origin.x+17;
        frame.origin.y = 5;
        frame.size.height = 10;
        frame.size.width = 10;
        _redIconView = [[UIImageView alloc] initWithFrame:frame];
        _redIconView.image = [UIImage imageNamed:@"s_n_round_red.png"];
        [_itemIconImageView.superview addSubview:_redIconView];
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
