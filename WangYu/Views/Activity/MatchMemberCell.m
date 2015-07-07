//
//  MatchMemberCell.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchMemberCell.h"
#import "UIImageView+WebCache.h"

@implementation MatchMemberCell

- (void)awakeFromNib {
    // Initialization code

    self.phoneLable.textColor = SKIN_TEXT_COLOR1;
    self.phoneLable.font = SKIN_FONT_FROMNAME(14);
    
    self.statusLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)setMemberInfo:(WYMemberInfo *)memberInfo{
    [self.avatarImageView sd_setImageWithURL:memberInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"wangyu_message_icon"]];
    self.phoneLable.text = memberInfo.telephone;
    if (memberInfo.isCompleted) {
        self.statusLabel.textColor = SKIN_TEXT_COLORRED;
        self.statusLabel.text = @"已完善";
    }else {
        self.statusLabel.textColor = SKIN_TEXT_COLOR2;
        self.statusLabel.text = @"未完善";
    }
}

@end
