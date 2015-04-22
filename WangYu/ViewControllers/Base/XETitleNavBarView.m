//
//  XETitleNavBarView.m
//  Xiaoer
//
//  Created by KID on 14/12/31.
//
//

#import "XETitleNavBarView.h"

@interface XETitleNavBarView ()

@property (nonatomic, weak) id owner;
//titleLabel
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
//background image
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;

@end

@implementation XETitleNavBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)init:(id)owner{
    self = [[[NSBundle mainBundle] loadNibNamed:@"XETitleNavBarView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        //load view
        _owner = owner;
        self.backgroundImageView.backgroundColor = SKIN_COLOR;
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

@end
