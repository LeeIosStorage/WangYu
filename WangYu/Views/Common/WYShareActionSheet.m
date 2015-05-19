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

@interface WYShareActionSheet() <WYCustomerWindowDelg>
{
    NSMutableDictionary* _actionSheetIndexSelDic;
    WYCustomerWindow *_csheet;
}

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
            
        }else if (row == 3){
            [self shareToWeiBo];
        }
    }
}

#pragma mark - share
-(void)shareToWX:(int)scene{
    [WYShareManager shareToWXWithScene:scene title:@"网娱大师" description:@"一款前所未有的网吧产品" webpageUrl:@"http://www.baidu.com" image:nil];
}

-(void)shareToWeiBo{
    [[WYShareManager shareInstance] shareToWb:^(WBSendMessageToWeiboResponse *response) {
        
    } title:@"网娱大师" description:@"一款前所未有的网吧产品" webpageUrl:@"http://xiaor123.cn:801/api/share/topic/0/318" image:nil];
}

@end
