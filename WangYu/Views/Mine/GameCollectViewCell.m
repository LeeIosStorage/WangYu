//
//  GameCollectViewCell.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameCollectViewCell.h"
#import "UIImageView+WebCache.h"

@implementation GameCollectViewCell

- (void)awakeFromNib {
    // Initialization code
    self.gameImageView.layer.masksToBounds = YES;
    self.gameImageView.layer.cornerRadius = 4;
    self.gameImageView.clipsToBounds = YES;
    self.gameImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.gameTitleLabel.textColor = SKIN_TEXT_COLOR1;
    self.gameTitleLabel.font = SKIN_FONT_FROMNAME(15);
    self.gameIntroLabel.textColor = SKIN_TEXT_COLOR2;
    self.gameIntroLabel.font = SKIN_FONT_FROMNAME(13);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setGameInfo:(WYGameInfo *)gameInfo{
    _gameInfo = gameInfo;
    [self.gameImageView sd_setImageWithURL:gameInfo.gameIconUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    self.gameTitleLabel.text = gameInfo.gameName;
    
    self.gameIntroLabel.lineHeightMultiple = 0.8;
    self.gameIntroLabel.text = gameInfo.gameIntro;
}

@end
