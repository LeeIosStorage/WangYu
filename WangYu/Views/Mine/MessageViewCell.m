//
//  MessageViewCell.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MessageViewCell.h"
#import "UIImageView+WebCache.h"

@implementation MessageViewCell

- (void)awakeFromNib {
    // Initialization code
    self.messageAvatarImageView.layer.masksToBounds = YES;
    self.messageAvatarImageView.layer.cornerRadius = 4;
    self.messageAvatarImageView.clipsToBounds = YES;
    self.messageAvatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.titleLabel.font = SKIN_FONT_FROMNAME(15);
    self.descriptionLabel.textColor = SKIN_TEXT_COLOR2;
    self.descriptionLabel.font = SKIN_FONT_FROMNAME(12);
    self.timeLabel.textColor = SKIN_TEXT_COLOR2;
    self.timeLabel.font = SKIN_FONT_FROMNAME(12);
    self.descriptionLabel.lineHeightMultiple = 0.8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessageInfo:(WYMessageInfo *)messageInfo{
    _messageInfo = messageInfo;
    
    self.titleLabel.text = messageInfo.title;
    self.descriptionLabel.text = messageInfo.content;
    self.timeLabel.text = [WYUIUtils dateDiscriptionFromNowBk:messageInfo.createDate];
    if (messageInfo.type == SYS_NOTIFY) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_system_icon"];
    } else if (messageInfo.type == SYS_REDBAG) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_pactket_icon"];
    } else if (messageInfo.type == SYS_MEMBER) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_vip_icon"];
    } else if (messageInfo.type == ORDER_RESERVE) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_netbar_icon"];
    } else if (messageInfo.type == ORDER_PAY) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_book_icon"];
    } else if (messageInfo.type == ACTIVITY_MATCH) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_activity_icon"];
    } else if (messageInfo.type == ACTIVITY_FIGHT) {
        self.messageAvatarImageView.image = [UIImage imageNamed:@"message_fight_icon"];
    }
    if (messageInfo.isRead) {
        self.badgeImageView.hidden = YES;
    }else {
        self.badgeImageView.hidden = NO;
    }
}

@end
