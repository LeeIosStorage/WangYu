//
//  MatchMemberCell.m
//  WangYu
//
//  Created by XuLei on 15/6/23.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchMemberCell.h"

@implementation MatchMemberCell

- (void)awakeFromNib {
    // Initialization code
    self.memberTitleLabel.textColor = SKIN_TEXT_COLOR2;
    self.memberTitleLabel.font = SKIN_FONT_FROMNAME(14);
    
    self.phoneLable.textColor = SKIN_TEXT_COLOR1;
    self.phoneLable.font = SKIN_FONT_FROMNAME(14);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
