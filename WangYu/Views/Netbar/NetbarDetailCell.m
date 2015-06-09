//
//  NetbarDetailCell.m
//  WangYu
//
//  Created by KID on 15/5/11.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NetbarDetailCell.h"
#import "WYCommonUtils.h"

@interface NetbarDetailCell()

@property (nonatomic, weak) UIFont *font;

@end

@implementation NetbarDetailCell

- (void)awakeFromNib {
    // Initialization code
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.font = SKIN_FONT_FROMNAME(12);
        dispatch_async(dispatch_get_main_queue(),^{
            self.titleLabel.font = self.font;
            self.dateLabel.font = self.font;
            self.totalCountLabel.font = self.font;
            self.nameLabel.font = self.font;
        });
    });
    self.titleLabel.textColor = SKIN_TEXT_COLOR1;
    self.dateLabel.textColor = SKIN_TEXT_COLOR2;
    self.nameLabel.textColor = SKIN_TEXT_COLOR1;
    self.totalCountLabel.textColor = SKIN_TEXT_COLOR2;
    self.totalCountLabel.font = SKIN_FONT_FROMNAME(12);
    self.applyCountLabel.textColor = UIColorToRGB(0xf03f3f);
    self.applyCountLabel.font = SKIN_FONT_FROMNAME(12);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setMatchWarInfo:(WYMatchWarInfo *)matchWarInfo {
    _matchWarInfo = matchWarInfo;
    self.titleLabel.text = matchWarInfo.title;
    self.dateLabel.text = [WYUIUtils dateDiscriptionFromDate:matchWarInfo.startTime];;
    
    self.nameLabel.text = matchWarInfo.itemName;
    
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
