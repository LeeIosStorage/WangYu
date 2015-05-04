//
//  WYTitleNavBarView.m
//  Xiaoer
//
//  Created by KID on 14/12/31.
//
//

#import "WYTitleNavBarView.h"
#import "WYUIUtils.h"

@interface WYTitleNavBarView ()

@property (nonatomic, weak) id owner;
//titleLabel
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
//background image
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
//line image
@property (nonatomic, strong) IBOutlet UIImageView *lineImageView;

@end

@implementation WYTitleNavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init:(id)owner{
    self = [[[NSBundle mainBundle] loadNibNamed:@"WYTitleNavBarView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        //load view
        _owner = owner;
        self.backgroundImageView.backgroundColor = SKIN_COLOR;
        self.lineImageView.hidden = YES;
    }
    return self;
}

-(id) setTitle:(NSString *) title
{
    _titleLabel.text = title;
    return _titleLabel;
}
-(id) setTitle:(NSString *) title font:(UIFont *) font;
{
    _titleLabel.text = title;
    _titleLabel.font = font;
    return _titleLabel;
}

-(void) setBarBackgroundColor:(UIColor *)bgColor showLine:(BOOL)showLine{
    self.backgroundImageView.backgroundColor = bgColor;
    self.lineImageView.hidden = !showLine;
    self.lineImageView.backgroundColor = UIColorToRGB(0xadadad);
}
@end
