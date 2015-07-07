//
//  GameListViewCell.m
//  WangYu
//
//  Created by Leejun on 15/7/7.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "GameListViewCell.h"
#import "UIImageView+WebCache.h"

@implementation GameListViewCell

- (void)awakeFromNib {
    // Initialization code
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.nameLabel.font = SKIN_FONT_FROMNAME(15);
    self.nameLabel.textColor = SKIN_TEXT_COLOR1;
    self.introLabel.font = SKIN_FONT_FROMNAME(12);
    self.introLabel.textColor = SKIN_TEXT_COLOR2;
    
    self.downloadButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
//    self.downloadButton.titleLabel.textColor = SKIN_TEXT_COLOR1;
    [self.downloadButton setTitleColor:SKIN_TEXT_COLOR1 forState:0];
    [self.downloadButton.layer setMasksToBounds:YES];
    [self.downloadButton.layer setCornerRadius:4.0];
    [self.downloadButton.layer setBorderWidth:0.5]; //边框宽度
    [self.downloadButton.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setGameInfo:(WYGameInfo *)gameInfo{
    _gameInfo = gameInfo;
    
    [self.avatarImageView sd_setImageWithURL:gameInfo.gameIconUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    
    _nameLabel.text = gameInfo.gameName;
    NSString *gameSizeText = [NSString stringWithFormat:@"%dM",_gameInfo.iosFileSize];
    NSString *downloadText = [NSString stringWithFormat:@"%d",_gameInfo.downloadCount];
    
    NSString *string = [NSString stringWithFormat:@"%@  %@次下载",gameSizeText,downloadText];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    NSUInteger length = [downloadText length];
    UIColor *color = UIColorToRGB(0xf03f3f);
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:NSMakeRange(gameSizeText.length+2, length)];
    self.introLabel.attributedText = attrString;
    
}

@end
