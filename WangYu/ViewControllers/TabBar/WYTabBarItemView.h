//
//  WYTabBarItemView.h
//  Xiaoer
//
//  Created by KID on 14/12/30.
//
//

#import <UIKit/UIKit.h>

@protocol WYTabBarItemViewProtocol;

@interface WYTabBarItemView : UIView

@property (strong, nonatomic) IBOutlet UIButton *itemBtn;
@property (strong, nonatomic) IBOutlet UIImageView *itemIconImageView;
@property (strong, nonatomic) IBOutlet UILabel *itemLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bkImageView;

@property(nonatomic,assign) id<WYTabBarItemViewProtocol> delegate;
@property(nonatomic,assign) bool selected;
@property(nonatomic,assign) int badgeNum;//0表示不显示badgeview，大于0展示数字badge，-1展示成红点

- (IBAction)itemTouchDown:(id)sender ;
@end

@protocol WYTabBarItemViewProtocol <NSObject>
- (void)selectForItemView:(id)view;

@end
