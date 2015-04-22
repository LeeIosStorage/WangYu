//
//  HotUpButton.m
//  WangYu
//
//  Created by KID on 15/3/26.
//
//

#import "HotUpButton.h"

@implementation HotUpButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect bounds = self.bounds;
    //若原热区小于88x88，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(88.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(88.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end
