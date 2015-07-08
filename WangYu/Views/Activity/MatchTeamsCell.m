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
    
    self.teamNameLabel.font = SKIN_FONT_FROMNAME(14);
    self.teamLeaderLabel.textColor = SKIN_TEXT_COLOR2;
    self.teamLeaderLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.roundLabel.textColor = SKIN_TEXT_COLOR2;
    self.roundLabel.font = SKIN_FONT_FROMNAME(14);
    
    [self.joinButton.layer setMasksToBounds:YES];
    [self.joinButton.layer setCornerRadius:4.0];
    [self.joinButton.layer setBorderWidth:0.5];
    
    [self.exitButton.layer setMasksToBounds:YES];
    [self.exitButton.layer setCornerRadius:4.0];
    [self.exitButton.layer setBorderWidth:0.5];
    [self.exitButton.layer setBorderColor:UIColorToRGB(0Xadadad).CGColor];
    [self.exitButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    
    [self.editButton.layer setMasksToBounds:YES];
    [self.editButton.layer setCornerRadius:4.0];
    [self.editButton.layer setBorderWidth:0.5];
    [self.editButton.layer setBorderColor:UIColorToRGB(0Xadadad).CGColor];
    [self.editButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setTeamInfo:(WYTeamInfo *)teamInfo{
    self.roundLabel.text = [NSString stringWithFormat:@"第%d场",teamInfo.round];
    NSString *applyCount = [NSString stringWithFormat:@"%d",teamInfo.applyNum];
    NSString *totalCount = [NSString stringWithFormat:@"/%d",teamInfo.totalNum];
    
    self.applyCountLabel.text = applyCount;
    self.totalCountLabel.text = totalCount;
    
    if (self.isMine) {
        self.teamNameLabel.textColor = SKIN_TEXT_COLOR2;
        self.teamNameLabel.text = teamInfo.title;
        self.teamLeaderLabel.text = [NSString stringWithFormat:@"战队名：%@",teamInfo.teamName];
        self.joinButton.hidden = YES;
        self.exitButton.hidden = NO;
        if (teamInfo.isLeader) {
            [self.exitButton setTitle:@"解散" forState:UIControlStateNormal];
            self.editButton.hidden = NO;
        }else {
            [self.exitButton setTitle:@"退出" forState:UIControlStateNormal];
            self.editButton.hidden = YES;
        }
    }else {
        self.teamNameLabel.textColor = SKIN_TEXT_COLOR1;
        self.teamNameLabel.text = teamInfo.teamName;
        self.teamLeaderLabel.text = [NSString stringWithFormat:@"发起者：%@",teamInfo.teamLeader];
        self.joinButton.hidden = NO;
        self.exitButton.hidden = YES;
        self.editButton.hidden = YES;
        if (teamInfo.isJoin) {
            self.joinButton.enabled = NO;
            [self.joinButton.layer setBorderColor:SKIN_TEXT_COLOR2.CGColor];
            [self.joinButton setTitle:@"我已加入" forState:UIControlStateNormal];
            [self.joinButton setTitleColor:SKIN_TEXT_COLOR2 forState:UIControlStateNormal];
        }else {
            self.joinButton.enabled = YES;
            [self.joinButton.layer setBorderColor:SKIN_TEXT_COLORRED.CGColor];
            [self.joinButton setTitle:@"我要加入" forState:UIControlStateNormal];
            [self.joinButton setTitleColor:SKIN_TEXT_COLORRED forState:UIControlStateNormal];
        }
    }
}

- (IBAction)joinAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(MatchTeamsCellJoinClickWithCell:)]) {
        [self.delegate MatchTeamsCellJoinClickWithCell:self];
    }
}

- (IBAction)exitAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(MatchTeamsCellExitClickWithCell:)]) {
        [self.delegate MatchTeamsCellExitClickWithCell:self];
    }
}

- (IBAction)editAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(MatchTeamsCellEditClickWithCell:)]) {
        [self.delegate MatchTeamsCellEditClickWithCell:self];
    }
}

@end
