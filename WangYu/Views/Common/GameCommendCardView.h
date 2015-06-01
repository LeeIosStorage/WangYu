//
//  GameCommendCardView.h
//  WangYu
//
//  Created by KID on 15/4/30.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GameCommendCardViewDelegate <NSObject>

@optional
-(void)gameCommendCardViewClick;

@end

@interface GameCommendCardView : UIView

@property (nonatomic, assign)id<GameCommendCardViewDelegate> delegate;

@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *gameVersionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *gameImageView;
@property (strong, nonatomic) IBOutlet UILabel *gameDesLabel;

@property (strong, nonatomic) IBOutlet UIView *likeView;
@property (strong, nonatomic) IBOutlet UIImageView *likeIconImgView;
@property (strong, nonatomic) IBOutlet UILabel *likeLabel;

- (id)init;

@end
