//
//  CustomMapCell.h
//  WangYu
//
//  Created by KID on 15/5/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomMapCell : UIView
@property (strong, nonatomic) IBOutlet UIImageView *netbarImage;
@property (nonatomic,strong)IBOutlet UILabel *title;
@property (nonatomic,strong)IBOutlet UILabel *subtitle;
@property (nonatomic,strong)IBOutlet UILabel *hoursLabel;

@end
