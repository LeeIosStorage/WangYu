//
//  GameCommendCardView.m
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameCommendCardView.h"

@interface GameCommendCardView ()

- (IBAction)detailsAction:(id)sender;

@end

@implementation GameCommendCardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)init {
//    self = [super init];
    self = [[[NSBundle mainBundle] loadNibNamed:@"GameCommendCardView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Shadow
    self.layer.shadowColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:0.5].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 6);
    self.layer.shadowRadius = 8.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    // Corner Radius
    self.layer.cornerRadius = 6.0;
    
    [self.layer setBorderWidth:0.5]; //边框宽度
    [self.layer setBorderColor:UIColorRGB(173, 173, 173).CGColor];
    
    self.gameImageView.clipsToBounds = YES;
    self.gameImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.gameVersionLabel.font = SKIN_FONT_FROMNAME(12);
    self.gameVersionLabel.textColor = SKIN_TEXT_COLOR2;
    self.gameNameLabel.font = SKIN_FONT_FROMNAME(15);
    self.gameNameLabel.textColor = [UIColor blackColor];
    
    self.gameDesLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.likeLabel.font = SKIN_FONT_FROMNAME(12);
    self.likeView.layer.masksToBounds = YES;
    self.likeView.layer.cornerRadius = 10;
}

-(void) setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    [self setNeedsDisplay];
}

- (IBAction)detailsAction:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(gameCommendCardViewClick)]) {
        [_delegate gameCommendCardViewClick];
    }
}
@end
