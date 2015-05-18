//
//  WYShareActionSheet.m
//  WangYu
//
//  Created by KID on 15/5/18.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYShareActionSheet.h"
#import "WYCustomerWindow.h"

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
            
        }
    }
}

@end
