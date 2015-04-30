//
//  WYTabBarView.m
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import "WYTabBarView.h"

@interface WYTabBarView ()<WYTabBarItemViewProtocol>

@end

@implementation WYTabBarView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.bounds];
//        imageView.contentMode = UIViewContentModeScaleToFill;
//        [imageView setImage:[UIImage imageNamed:@"tabbar_bg"]];
        self.backgroundColor = [UIColor whiteColor];
//        [self addSubview:imageView];
    }
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setItems:(NSArray *)newItems{
    for (WYTabBarItemView *tabBarItem in self.items) {
        [tabBarItem removeFromSuperview];
    }
    _items = [NSArray arrayWithArray:newItems];
    
    if ([self.items count]) {
        [(WYTabBarItemView *)[self.items objectAtIndex:self.initialIndex] setSelected:YES];
        self.selectedTabBarItem = [self.items objectAtIndex:self.initialIndex];
        [self.delegate tabBar:self didSelectTabAtIndex:self.initialIndex];
    }
    for (WYTabBarItemView *tabBarItem in self.items) {
        tabBarItem.userInteractionEnabled = YES;
        tabBarItem.delegate = self;
    }
    [self setNeedsLayout];
}

-(void)selectForItemView:(id)view{
    
    WYTabBarItemView* sender = (WYTabBarItemView*)view;
    for (WYTabBarItemView *tab in self.items) {
        if (tab == sender) {
            continue;
        }
        tab.selected = NO;
        //[tab.bkImageView setBackgroundColor:[UIColor whiteColor]];
        tab.itemLabel.textColor = SKIN_TEXT_COLOR1;
    }
    if (!sender.selected) {
        sender.selected = YES;
        self.selectedTabBarItem = sender;
//        [self.selectedTabBarItem.bkImageView setBackgroundColor:SKIN_COLOR];
        self.selectedTabBarItem.itemLabel.textColor = SKIN_TEXT_COLOR1;
    }
    
    [self.delegate tabBar:self didSelectTabAtIndex:[self.items indexOfObject:sender]];
    
}
- (void)selectIndex:(NSUInteger)anIndex{
    self.simulateSelected = YES;
    WYTabBarItemView *tab = [self.items objectAtIndex:anIndex];
    [tab itemTouchDown:nil];
    self.simulateSelected = NO;
}
#pragma mark UIView

-(void) layoutSubviews {
    [super layoutSubviews];
    
    CGRect currentBounds = self.bounds;
    
//    UIImageView *bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"s_n_foundgroup_bottom_bg.png"]];
//    bgImg.frame = currentBounds;
//    [self addSubview:bgImg];
    
    int width = self.bounds.size.width/self.items.count;
    currentBounds.size.width = width;
    int index = 0;
    for (WYTabBarItemView *tab in self.items) {
        if (index == self.items.count -1) {
            currentBounds.size.width += self.bounds.size.width - self.items.count*width;
        }
        tab.frame = currentBounds;
        currentBounds.origin.x += currentBounds.size.width;
        
        [self addSubview:tab];
        index++;
    }
    
    [self.selectedTabBarItem setSelected:YES];
//    [self.selectedTabBarItem.bkImageView setBackgroundColor:SKIN_COLOR];
    self.selectedTabBarItem.itemLabel.textColor = SKIN_TEXT_COLOR1;
}

-(void) setFrame:(CGRect)aFrame {
    [super setFrame:aFrame];
    [self setNeedsDisplay];
}

@end
