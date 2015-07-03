//
//  MatchTeamsCell.m
//  WangYu
//
//  Created by XuLei on 15/7/2.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchTeamsCell.h"
#import "WYCommonUtils.h"

@implementation MatchTeamsCell

- (void)awakeFromNib {
    // Initialization code
    self.totalCountLabel.textColor = SKIN_TEXT_COLOR2;
    self.totalCountLabel.font = SKIN_FONT_FROMNAME(12);
    self.applyCountLabel.textColor = UIColorToRGB(0xf03f3f);
    self.applyCountLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.teamNameLabel.textColor = SKIN_TEXT_COLOR1;
    self.teamNameLabel.font = SKIN_FONT_FROMNAME(14);
    self.teamLeaderLabel.textColor = SKIN_TEXT_COLOR2;
    self.teamLeaderLabel.font = SKIN_FONT_FROMNAME(12);
    
    [self.joinButton.layer setMasksToBounds:YES];
    [self.joinButton.layer setCornerRadius:4.0];
    [self.joinButton.layer setBorderWidth:0.5];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTeamInfo:(WYTeamInfo *)teamInfo{
    self.teamNameLabel.text = teamInfo.teamName;
    self.teamLeaderLabel.text = [NSString stringWithFormat:@"发起者：%@",teamInfo.teamLeader];
    
    NSString *applyCount = [NSString stringWithFormat:@"%d",teamInfo.applyNum];
    NSString *totalCount = [NSString stringWithFormat:@"/%d",teamInfo.totalNum];
    
    self.applyCountLabel.text = applyCount;
    self.totalCountLabel.text = totalCount;
    
    if (teamInfo.isJoin) {
        self.joinButton.enabled = NO;
        [self.joinButton.layer setBorderColor:SKIN_TEXT_COLOR2.CGColor];
        self.joinButton.titleLabel.text = @"我已加入";
        [self.joinButton setTitleColor:SKIN_TEXT_COLOR2 forState:UIControlStateNormal];
    }else {
        self.joinButton.enabled = YES;
        [self.joinButton.layer setBorderColor:SKIN_TEXT_COLORRED.CGColor];
        self.joinButton.titleLabel.text = @"我要加入";
        [self.joinButton setTitleColor:SKIN_TEXT_COLORRED forState:UIControlStateNormal];
    }
}

- (IBAction)joinAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(MatchTeamsCellJoinClickWithCell:)]) {
        [self.delegate MatchTeamsCellJoinClickWithCell:self];
    }
}

@end
