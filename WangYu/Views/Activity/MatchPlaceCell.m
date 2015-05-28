//
//  MatchPlaceCell.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchPlaceCell.h"

@implementation MatchPlaceCell

- (void)awakeFromNib {
    // Initialization code
    [self.containerView.layer setMasksToBounds:YES];
    [self.containerView.layer setCornerRadius:4.0];
    [self.containerView.layer setBorderWidth:0.5]; //边框宽度
    [self.containerView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
    
    [self.applyButton.layer setMasksToBounds:YES];
    [self.applyButton.layer setCornerRadius:4.0];
    [self.applyButton.layer setBorderWidth:0.5]; //边框宽度
    [self.applyButton.layer setBorderColor:UIColorToRGB(0xf03f3f).CGColor];//边框颜色
    [self.applyButton setTitleColor:UIColorToRGB(0xf03f3f) forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMatchInfo:(WYMatchInfo *)matchInfo{
    _matchInfo = matchInfo;
    self.roundLabel.text = [NSString stringWithFormat:@"第%d场",_matchInfo.round];
    self.timeLabel.text = [NSString stringWithFormat:@"%@～%@",_matchInfo.startTime,_matchInfo.endTime];
    self.placeLabel.text = _matchInfo.areas;
    _matchInfo.isApply = NO;
    if(_matchInfo.isApply){
        self.applyButton.enabled = NO;
    }else{
        self.applyButton.enabled = YES;
    }
}

- (IBAction)applyAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(matchPlaceCellClickWithCell:)]) {
        [self.delegate matchPlaceCellClickWithCell:self];
    }
}

@end
