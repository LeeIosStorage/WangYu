//
//  SettingViewCell.h
//  Xiaoer
//
//  Created by KID on 15/2/5.
//
//

#import <UIKit/UIKit.h>

@interface SettingViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightLabel;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *indicatorImage;
@property (strong, nonatomic) IBOutlet UIImageView *topLineImage;
@property (strong, nonatomic) IBOutlet UIImageView *bottomLineImage;

- (void) setLineImageViewWithType:(int)type;
@end
