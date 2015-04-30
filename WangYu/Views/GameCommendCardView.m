//
//  GameCommendCardView.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameCommendCardView.h"

@implementation GameCommendCardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Corner Radius
    self.layer.cornerRadius = 10.0;
    
    self.gameImageView.clipsToBounds = YES;
    self.gameImageView.contentMode = UIViewContentModeScaleAspectFill;
}

-(void) setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    [self setNeedsDisplay];
}

@end
