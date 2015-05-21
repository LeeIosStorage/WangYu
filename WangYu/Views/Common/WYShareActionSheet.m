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
    self.shareTitle = [NSString stringWithFormat:@"网娱大师网吧-%@",_netbarInfo.netbarName];
    self.shareDescription = [NSString stringWithFormat:@"网娱大师-%@",@"任性开黑，美女约战"];
    self.shareWebpageUrl = [NSString stringWithFormat:@"%@",@"http://xiaor123.cn:801/api/share/topic/0/318"];
    
    if (![self.netbarInfo.smallImageUrl isEqual:[NSNull null]]) {
        self.shareImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self.netbarInfo.smallImageUrl absoluteString]];
    }
    if (!self.shareImage) {
        self.shareImage = [UIImage imageNamed:@"netbar_load_icon"];
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
