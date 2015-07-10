//
//  WYShareActionSheet.m
//  WangYu
//
//  Created by KID on 15/5/18.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYShareActionSheet.h"
#import "WYCustomerWindow.h"
#import "WYShareManager.h"
#import "SDImageCache.h"
#import "WYEngine.h"

@interface WYShareActionSheet() <WYCustomerWindowDelg>
{
    NSMutableDictionary* _actionSheetIndexSelDic;
    WYCustomerWindow *_csheet;
}

@property (nonatomic, strong) NSString *shareTitle;
@property (nonatomic, strong) NSString *shareDescription;
@property (nonatomic, strong) NSString *shareWebpageUrl;
@property (nonatomic, strong) UIImage *shareImage;

@end

@implementation WYShareActionSheet

-(void)dealloc
{
    _owner = nil;
    _csheet = nil;
}

-(void) showShareAction
{
    _csheet = [[[NSBundle mainBundle] loadNibNamed:@"WYCustomerWindow" owner:nil options:nil] objectAtIndex:0];
    _csheet.sheetDelg = self;
    [_csheet setCustomerSheet];
    
    [self shareContent];
}

- (void)shareContent{
    if (self.netbarInfo) {
        self.shareTitle = [NSString stringWithFormat:@"网娱大师-%@|快来定座吧",_netbarInfo.netbarName];
        self.shareDescription = [NSString stringWithFormat:@"上网价格￥%@/小时\n%@",_netbarInfo.price,_netbarInfo.address];
        self.shareWebpageUrl = [NSString stringWithFormat:@"%@/share/netbar/%@",[WYEngine shareInstance].baseUrl,_netbarInfo.nid];
        
        if (![self.netbarInfo.smallImageUrl isEqual:[NSNull null]]) {
            self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.netbarInfo.smallImageUrl absoluteString]];
        }
        if (!self.shareImage) {
            self.shareImage = [UIImage imageNamed:@"netbar_load_icon"];
        }
    }
    if (self.activityInfo) {
        self.shareTitle = [NSString stringWithFormat:@"网娱大师-%@|快来加入约战吧",_activityInfo.title];
        self.shareDescription = [NSString stringWithFormat:@"开始时间：%@结束时间：\n%@",_activityInfo.startTime,_activityInfo.endTime];
        self.shareWebpageUrl = [NSString stringWithFormat:@"%@/share/activity/%@",[WYEngine shareInstance].baseUrl,_activityInfo.aId];
        
        if (![self.activityInfo.activityImageUrl isEqual:[NSNull null]]) {
            self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.activityInfo.smallImageURL absoluteString]];
        }
        if (!self.shareImage) {
            self.shareImage = [UIImage imageNamed:@"activity_load_icon"];
        }
    }
    if (self.gameInfo) {
        self.shareTitle = [NSString stringWithFormat:@"网娱大师-最热手游,抢先推荐-%@",_gameInfo.gameName];
        self.shareDescription = _gameInfo.gameDes;
        self.shareWebpageUrl = [NSString stringWithFormat:@"%@/share/game/%@",[WYEngine shareInstance].baseUrl,_gameInfo.gameId];
        
        if (![self.gameInfo.gameCoverUrl isEqual:[NSNull null]]) {
            self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.gameInfo.gameCoverUrl absoluteString]];
        }
        if (![self.gameInfo.gameIconUrl isEqual:[NSNull null]]) {
            self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.gameInfo.gameIconUrl absoluteString]];
        }
        if (!self.shareImage) {
            self.shareImage = [UIImage imageNamed:@"netbar_load_icon"];
        }
    }
    if (self.matchWarInfo) {
        self.shareTitle = [NSString stringWithFormat:@"网娱大师-%@",_matchWarInfo.title];
        self.shareDescription = [NSString stringWithFormat:@"游戏类型:%@ 开始时间:%@ 服务器:%@",_matchWarInfo.itemName,[WYUIUtils dateDiscriptionFromDate:_matchWarInfo.startTime],_matchWarInfo.itemServer];
        self.shareWebpageUrl = [NSString stringWithFormat:@"%@/share/match/%@",[WYEngine shareInstance].baseUrl,_matchWarInfo.mId];
        
        if (![self.matchWarInfo.itemPicURL isEqual:[NSNull null]]) {
            self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.matchWarInfo.itemPicURL absoluteString]];
        }
        if (!self.shareImage) {
            self.shareImage = [UIImage imageNamed:@"netbar_load_icon"];
        }
    }
    if (self.newsInfo) {
        self.shareTitle = [NSString stringWithFormat:@"网娱大师-电竞赛事独家报名,资讯直播-%@",_newsInfo.title];
        self.shareDescription = self.newsInfo.brief;
        self.shareWebpageUrl = [NSString stringWithFormat:@"%@/activity/info/web/detail?id=%@",[WYEngine shareInstance].baseUrl,_newsInfo.nid];
        if (![self.newsInfo.newsImageUrl isEqual:[NSNull null]]) {
            NSURL *smallImageURL = [NSURL URLWithString:[[NSString stringWithFormat:@"%@/%@", [[WYEngine shareInstance] baseImgUrl], self.newsInfo.newsImageUrl] stringByReplacingOccurrencesOfString:@".png" withString:@"_thumb.png"]];
            self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[smallImageURL absoluteString]];
        }
        if (!self.shareImage) {
            self.shareImage = [UIImage imageNamed:@"activity_load_icon"];
        }
    }
}

#pragma mark -- LSCustomerSheetDelg
-(void)customerWindowClickAt:(NSIndexPath *)indexPath action:(NSString *)action{
    int row = (int)indexPath.row;
    if (indexPath.section == 2) {
        if (action) {
            //            SEL opAction = NSSelectorFromString(action);
            //            if ([self respondsToSelector:opAction]) {
            //                objc_msgSend(self, opAction);
            //                return;
            //            }
        }
    }else if (indexPath.section == 1){
        if (row == 0) {
            [self shareToWX:WXSceneSession];
        }else if (row == 1){
            [self shareToWX:WXSceneTimeline];
        }else if (row == 2){
            [self shareToQQ];
        }else if (row == 3){
            [self shareToWeiBo];
        }
    }
}

#pragma mark - share
-(void)shareToWX:(int)scene{
    [[WYShareManager shareInstance] shareToWXWithScene:scene title:self.shareTitle description:self.shareDescription webpageUrl:self.shareWebpageUrl image:self.shareImage];
}

-(void)shareToWeiBo{
    [[WYShareManager shareInstance] shareToWb:^(WBSendMessageToWeiboResponse *response) {
        
    } title:self.shareTitle description:self.shareDescription webpageUrl:self.shareWebpageUrl image:self.shareImage VC:_owner];
}

-(void)shareToQQ{
    [[WYShareManager shareInstance] shareToQQTitle:self.shareTitle description:self.shareDescription webpageUrl:self.shareWebpageUrl image:self.shareImage];
}
@end
