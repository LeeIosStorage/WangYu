//
//  NewsViewCell.m
//  WangYu
//
//  Created by KID on 15/5/28.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "NewsViewCell.h"
#import "UIImageView+WebCache.h"
#import "WYCommonUtils.h"

@implementation NewsViewCell

- (void)awakeFromNib {
    // Initialization code
    self.newsImageView.layer.masksToBounds = YES;
    self.newsImageView.layer.cornerRadius = 4;
    self.newsImageView.clipsToBounds = YES;
    self.newsImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.newsTitleLabel.textColor = SKIN_TEXT_COLOR1;
    self.newsTitleLabel.font = SKIN_FONT_FROMNAME(15);
    self.newsBriefLabel.textColor = SKIN_TEXT_COLOR2;
    self.newsBriefLabel.font = SKIN_FONT_FROMNAME(12);
    
    self.featureLabel.layer.masksToBounds = YES;
    self.featureLabel.layer.cornerRadius = 2.;
    self.featureLabel.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNewsInfo:(WYNewsInfo *)newsInfo{
    _newsInfo = newsInfo;
    [self.newsImageView sd_setImageWithURL:newsInfo.smallImageURL placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
    self.newsTitleLabel.lineHeightMultiple = 0.8;
    self.newsTitleLabel.text = newsInfo.title;
    //self.newsBriefLabel.text = newsInfo.brief;
    
    CGRect frame = self.newsTitleLabel.frame;
    CGSize textSize = [WYCommonUtils sizeWithText:newsInfo.title font:self.newsTitleLabel.font width:SCREEN_WIDTH-117];
    frame.origin.y = 12;
    frame.size.height = textSize.height + 10;
    self.newsTitleLabel.frame = frame;
    
    if (newsInfo.isSubject) {
        self.featureLabel.hidden = NO;
    }else{
        self.featureLabel.hidden = YES;
    }
}

@end
