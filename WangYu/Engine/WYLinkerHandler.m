//
//  WYLinkerHandler.m
//  WangYu
//
//  Created by KID on 15/6/1.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYLinkerHandler.h"
#import "WYCommonWebVc.h"
#import "WYEngine.h"
#import "WYAlertView.h"
#import "WYSettingConfig.h"

@implementation WYLinkerHandler

+(id)handleDealWithHref:(NSString *)href From:(UINavigationController*)nav{
    NSURL *realUrl = [NSURL URLWithString:href];
    if (realUrl == nil) {
        realUrl = [NSURL URLWithString:[href stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString* scheme = [realUrl.scheme lowercaseString];
    if ([scheme isEqualToString:@"wycategory"]) {
        NSString *lastCompment = [[realUrl path] lastPathComponent];
        WYLog(@"lastCompment = %@",lastCompment);
        NSDictionary *paramDic = [WYCommonUtils getParamDictFrom:realUrl.query];
        WYLog(@"paramDic = %@",paramDic);
        if ([[realUrl host] isEqualToString:@"sys"]) {
            //系统消息
            
        }else if ([[realUrl host] isEqualToString:@"redbag"]){
            // 红包消息
//            WYAlertView *alertView = [[WYAlertView alloc] initWithTitle:@"推送" message:@"收到红包消息" cancelButtonTitle:@"好的"];
//            [alertView show];
        }else if ([[realUrl host] isEqualToString:@"reservation"]){
            // 预定订单消息
            
        }else if ([[realUrl host] isEqualToString:@"pay"]){
            // 支付消息
            
        }else if ([[realUrl host] isEqualToString:@"activity"]){
            // 活动赛事消息
            
        }else if ([[realUrl host] isEqualToString:@"match"]){
            //约战消息
            
        }else if ([[realUrl host] isEqualToString:@"redbag_weekly"]){
            //每周红包推送消息
            [[WYSettingConfig staticInstance] setWeekRedBagMessageUnreadEvent:YES];
        }
        return nil;
        
    }else if([scheme hasPrefix:@"http"]){
        //        NSString *lastCompment = [[realUrl path] lastPathComponent];
        //        NSDictionary *paramDic = [XECommonUtils getParamDictFrom:realUrl.query];
        //if...else
        
        if (nav) {
            NSString *url = [realUrl description];
            WYCommonWebVc *webvc = [[WYCommonWebVc alloc] initWithAddress:url];
            
//            if ([url hasPrefix:[NSString stringWithFormat:@"%@/info/detail",[XEEngine shareInstance].baseUrl]]) {
//                NSDictionary *paramDic = [XECommonUtils getParamDictFrom:realUrl.query];
//                NSString *openId = [paramDic stringObjectForKey:@"id"];
//                webvc.isShareViewOut = YES;
//                webvc.openId = openId;
//            }
//            if ([url hasPrefix:[NSString stringWithFormat:@"%@/eva/test/start",[XEEngine shareInstance].baseUrl]]) {
//                webvc.isCanClosed = YES;
//            }
//            if ([url hasPrefix:[NSString stringWithFormat:@"%@/eva/result",[XEEngine shareInstance].baseUrl]]) {
//                webvc.isCanClosed = YES;
//                webvc.isResult = YES;
//            }
//            if ([url hasPrefix:[NSString stringWithFormat:@"%@/train/cat",[XEEngine shareInstance].baseUrl]]) {
//                webvc.isFullScreen = YES;
//            }
            //            webvc.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsOpenInChrome | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
            [nav pushViewController:webvc animated:YES];
        }
        return nil;
    }
    
    return nil;
}

@end
