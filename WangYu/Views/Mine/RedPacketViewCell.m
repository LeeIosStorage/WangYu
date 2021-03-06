//
//  RedPacketViewCell.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "RedPacketViewCell.h"

@implementation RedPacketViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.redPagMoney.font = SKIN_FONT_FROMNAME(30);
    self.redPagStaleLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.redPagIntroLabel.textColor = SKIN_TEXT_COLOR2;
    self.redPagIntroLabel.font = SKIN_FONT_FROMNAME(12);
    self.redPagValidTimeLabel.textColor = SKIN_TEXT_COLOR2;
    self.redPagValidTimeLabel.font = SKIN_FONT_FROMNAME(12);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setRedPacketInfo:(RedPacketInfo *)redPacketInfo{
    _redPacketInfo = redPacketInfo;
    self.redPagMoney.text = [NSString stringWithFormat:@"%d",redPacketInfo.money];
    NSString *validTimeText = [NSString stringWithFormat:@"有效期：%@-%@",[WYUIUtils dateYearToDayDiscriptionFromDate:redPacketInfo.beginDate],[WYUIUtils dateYearToDayDiscriptionFromDate:redPacketInfo.endDate]];
    self.redPagValidTimeLabel.text = validTimeText;
    
    self.redPagIntroLabel.text = redPacketInfo.explain;
    
    self.redPagStaleLabel.hidden = YES;
    UIImage *bgImage;
    if (redPacketInfo.selected) {
        self.selectImage.hidden = NO;
        bgImage = [UIImage imageNamed:@"redpacket_choose_icon"];
    }else{
        self.selectImage.hidden = YES;
        bgImage = [UIImage imageNamed:@"redpacket_kuang_red"];
    }
//    [[UIImage imageNamed:@"redpacket_kuang_red"] stretchableImageWithLeftCapWidth:148 topCapHeight:80];
    if (_isPast) {
        bgImage = [UIImage imageNamed:@"redpacket_kuang_gray"];
//        [[UIImage imageNamed:@"redpacket_kuang_gray"] stretchableImageWithLeftCapWidth:148 topCapHeight:80];
        self.redPagStaleLabel.hidden = NO;
        if (redPacketInfo.cause == 1) {
            self.redPagStaleLabel.text = @"已使用";
        }else if (redPacketInfo.cause == 2){
            self.redPagStaleLabel.text = @"已过期";
        }else{
            self.redPagStaleLabel.text = nil;
        }
    }
    self.redPacketBgImgView.image = bgImage;
}

@end
