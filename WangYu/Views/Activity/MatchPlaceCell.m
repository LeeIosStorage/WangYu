//
//  MatchPlaceCell.m
//  WangYu
//
//  Created by KID on 15/5/27.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "MatchPlaceCell.h"
#import "WYCommonUtils.h"
#import "UIImageView+WebCache.h"

//@interface MatchPlaceCell ()
//{
//    int index;
//}
//
//@end

@implementation MatchPlaceCell

+ (float)heightForMatchInfo:(WYMatchInfo *)matchInfo {
//    if (matchInfo.netbars.count > 0) {
//        return matchInfo.netbars.count * 44 + 98;
//    }else {
//        return 98;
//    }
    return 292;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMatchInfo:(WYMatchInfo *)matchInfo{
    _matchInfo = matchInfo;
    self.roundLabel.text = [NSString stringWithFormat:@"第%d场",_matchInfo.round];
    if (_matchInfo.startTime.length > 0 && _matchInfo.endTime.length > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@～%@",_matchInfo.startTime,_matchInfo.endTime];
    }else {
        self.timeLabel.text = @"暂无时间";
    }
    CGRect frame = self.roundLabel.frame;
    frame.origin.x = self.roundImage.frame.origin.x + self.roundImage.frame.size.width + 7;
    self.roundLabel.frame = frame;
    
    self.placeLabel.text = _matchInfo.areas;
    frame = self.placeLabel.frame;
    CGSize textSize = [WYCommonUtils sizeWithText:_matchInfo.areas font:self.placeLabel.font width:SCREEN_WIDTH-35];
    frame.size.height = textSize.height;
    self.placeLabel.frame = frame;
    
    
    
//    if(_matchInfo.isApply){
//        self.applyButton.hidden = NO;
//    }else{
//        self.applyButton.hidden = YES;
//    }
    
    [self.applyButton setTitleColor:SKIN_TEXT_COLOR1 forState:UIControlStateNormal];
    self.applyButton.titleLabel.font = SKIN_FONT_FROMNAME(14);
    self.applyButton.layer.cornerRadius = 4.0;
    self.applyButton.layer.masksToBounds = YES;
    
    if (_matchInfo.hasApply == 1) {
        self.applyButton.backgroundColor = UIColorToRGB(0xe4e4e4);
        self.applyButton.enabled = NO;
    }else {
        self.applyButton.backgroundColor = SKIN_COLOR;
        self.applyButton.enabled = YES;
    }

    int index = 0;
    if(matchInfo.netbars.count > 0){
        for (WYNetbarInfo *netbarInfo in matchInfo.netbars) {
            WYLog(@"picUrl = %@",netbarInfo.netbarImageUrl);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12 + index*(80+7), 12, 80, 69)];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:netbarInfo.smallImageUrl placeholderImage:[UIImage imageNamed:@"netbar_load_icon"]];
            [self.imageScrollView addSubview:imageView];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12 + index*(80+7), 93, 80, 30)];
            label.text = netbarInfo.netbarName;
            label.font = SKIN_FONT_FROMNAME(12);
            label.textColor = SKIN_TEXT_COLOR1;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            [self.imageScrollView addSubview:label];
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = imageView.frame;
            button.tag = [netbarInfo.nid integerValue];
            [button addTarget:self action:@selector(handleClickAtAdsButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.imageScrollView addSubview:button];
            index ++;
        }
        if(matchInfo.netbars.count > 3){
            [self.imageScrollView setContentSize:CGSizeMake(12 + matchInfo.netbars.count*(80+7), self.imageScrollView.frame.size.height)];
        }
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
    }
    
//    int index = 0;
//    frame = self.topView.frame;
//    for (WYNetbarInfo *netbarInfo in matchInfo.netbars) {
////        NSLog(@"===========%@=======%@",netbarInfo.nid,netbarInfo.netbarName);
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height + index * 44, SCREEN_WIDTH - 24, 44)];
//        [self.containerView addSubview:view];
//    
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 48, 1)];
//        [imageView setImage:[UIImage imageNamed:@"s_n_set_line"]];
//        [view addSubview:imageView];
//    
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.backgroundColor = [UIColor clearColor];
//        button.frame = CGRectMake(0, 0, SCREEN_WIDTH - 24, 44);
//        button.tag = [netbarInfo.nid integerValue];
//        [button addTarget:self action:@selector(handleClickAtAdsButton:) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:button];
//
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, 12, 200, 20)];
//        label.text = netbarInfo.netbarName;
//        label.font = SKIN_FONT_FROMNAME(12);
//        label.textColor = SKIN_TEXT_COLOR1;
//        [view addSubview:label];
//    
//        UIImageView *indicatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 48, 15, 14, 14)];
//        [indicatorImage setImage:[UIImage imageNamed:@"match_detail_indicator_icon"]];
//        [view addSubview:indicatorImage];
//        
//        index++;
//    }
    
    frame = self.frame;
    frame.size.height = 98 + 44 * index;
    self.frame = frame;
    
//    [self.containerView.layer setMasksToBounds:YES];
//    [self.containerView.layer setCornerRadius:4.0];
//    [self.containerView.layer setBorderWidth:0.5]; //边框宽度
//    [self.containerView.layer setBorderColor:UIColorToRGB(0xadadad).CGColor];//边框颜色
}

- (void)handleClickAtAdsButton:(id)sender{
    UIButton *btn = (UIButton *)sender;
    for (WYNetbarInfo *info in _matchInfo.netbars) {
        if ([info.nid isEqualToString:[NSString stringWithFormat:@"%ld",(long)btn.tag]]) {
            if ([self.delegate respondsToSelector:@selector(matchPlaceCellClickNetbarWithCell:netbarInfo:)]) {
                [self.delegate matchPlaceCellClickNetbarWithCell:self netbarInfo:info];
            }
            break;
        }
    }
}

- (IBAction)applyAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(matchPlaceCellClickWithCell:)]) {
        [self.delegate matchPlaceCellClickWithCell:self];
    }
}

@end
