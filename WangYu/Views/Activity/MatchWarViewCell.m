//
//  MatchWarViewCell.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchWarViewCell.h"
#import "UIImageView+WebCache.h"
#import "WYCommonUtils.h"

@implementation MatchWarViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.gameImageView.layer.masksToBounds = YES;
    self.gameImageView.layer.cornerRadius = self.gameImageView.frame.size.width/2;
    self.gameImageView.clipsToBounds = YES;
    self.gameImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.matchWarTitleLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchWarTitleLabel.font = SKIN_FONT_FROMNAME(15);
    self.matchWarTimeLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchWarTimeLabel.font = SKIN_FONT_FROMNAME(12);
    self.matchWarWayLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchWarWayLabel.font = SKIN_FONT_FROMNAME(12);
    self.matchWarSpoilsLabel.textColor = SKIN_TEXT_COLOR1;
    self.matchWarSpoilsLabel.font = SKIN_FONT_FROMNAME(12);
    self.gameNameLabel.textColor = SKIN_TEXT_COLOR1;
    self.gameNameLabel.font = SKIN_FONT_FROMNAME(13);
    self.totalCountLabel.textColor = SKIN_TEXT_COLOR2;
    self.totalCountLabel.font = SKIN_FONT_FROMNAME(12);
    self.applyCountLabel.textColor = UIColorToRGB(0xf03f3f);
    self.applyCountLabel.font = SKIN_FONT_FROMNAME(12);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMatchWarInfo:(WYMatchWarInfo *)matchWarInfo{
    _matchWarInfo = matchWarInfo;
    
    [self.gameImageView sd_setImageWithURL:matchWarInfo.itemPicURL placeholderImage:[UIImage imageNamed:@"wangyu_message_icon"]];
    self.gameNameLabel.text = matchWarInfo.itemName;
    
    self.matchWarTitleLabel.text = matchWarInfo.title;
    self.matchWarTimeLabel.text = [WYUIUtils dateDiscriptionFromDate:matchWarInfo.startTime];
    self.matchWarWayLabel.text = @"";
    if (matchWarInfo.way == 1) {
        self.matchWarWayLabel.text = @"线上";
    }else if (matchWarInfo.way == 2){
        self.matchWarWayLabel.text = @"线下";
    }
    self.matchWarSpoilsLabel.text = matchWarInfo.spoils;
    
    NSString *applyCount = [NSString stringWithFormat:@"%d",matchWarInfo.applyCount];
    NSString *totalCount = [NSString stringWithFormat:@"/%d",matchWarInfo.peopleNum];
    self.applyCountLabel.text = applyCount;
    self.totalCountLabel.text = totalCount;
    
    float width = [WYCommonUtils widthWithText:totalCount font:self.totalCountLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = self.totalCountLabel.frame;
    frame.origin.x = SCREEN_WIDTH - width - 12;
    frame.size.width = width;
    self.totalCountLabel.frame = frame;
    
    width = [WYCommonUtils widthWithText:applyCount font:self.applyCountLabel.font lineBreakMode:NSLineBreakByWordWrapping];
    frame = self.applyCountLabel.frame;
    frame.origin.x = self.totalCountLabel.frame.origin.x - width;
    frame.size.width = width;
    self.applyCountLabel.frame = frame;
    
    frame = self.matchWarHotIocnImgView.frame;
    frame.origin.x = self.applyCountLabel.frame.origin.x -self.matchWarHotIocnImgView.frame.size.width - 7;
    self.matchWarHotIocnImgView.frame = frame;
}

@end
