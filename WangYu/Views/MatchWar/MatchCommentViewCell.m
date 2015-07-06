//
//  MatchCommentViewCell.m
//  WangYu
//
//  Created by Leejun on 15/7/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchCommentViewCell.h"
#import "UIImageView+WebCache.h"
#import "WYCommonUtils.h"

#define test_content @"内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容"

@implementation MatchCommentViewCell

+ (float)heightForCommentInfo:(WYMatchCommentInfo *)commentInfo{
    NSString* content = commentInfo.content;
    if (!content) {
        content = @"";
    }
    CGSize topicTextSize = [WYCommonUtils sizeWithText:content font:[UIFont systemFontOfSize:12] width:SCREEN_WIDTH-49-12];
    
    if (topicTextSize.height < 16) {
        topicTextSize.height = 16;
    }
    float height = topicTextSize.height;
    height += 40;
    if (height < 56) {
        height = 56;
    }
    return height;
}

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width/2;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.nickNameLabel.font = SKIN_FONT_FROMNAME(14);
    self.nickNameLabel.textColor = SKIN_TEXT_COLOR1;
    self.dateLabel.font = SKIN_FONT_FROMNAME(12);
    self.dateLabel.textColor = UIColorToRGB(0xc7c7c7);
    self.contentLabel.textColor = SKIN_TEXT_COLOR2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCommentInfo:(WYMatchCommentInfo *)commentInfo{
    _commentInfo = commentInfo;
    
    [_avatarImageView sd_setImageWithURL:commentInfo.smallAvatarUrl placeholderImage:[UIImage imageNamed:@"personal_avatar_default_icon_small"]];
    _nickNameLabel.text = _commentInfo.nickName;
    _dateLabel.text = [WYUIUtils dateDiscriptionFromNowBk:_commentInfo.createDate];
    
    NSString* content = commentInfo.content;
    if (!content) {
        content = @"";
    }
    _contentLabel.text = content;
    CGSize textSize = [WYCommonUtils sizeWithText:content font:[UIFont systemFontOfSize:12] width:SCREEN_WIDTH-49-12];
    CGRect frame = self.contentLabel.frame;
    frame.size.height = textSize.height;
    self.contentLabel.frame = frame;
}

@end
