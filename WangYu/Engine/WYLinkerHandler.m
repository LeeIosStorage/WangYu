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

@implementation WYLinkerHandler

+(id)handleDealWithHref:(NSString *)href From:(UINavigationController*)nav{
    NSURL *realUrl = [NSURL URLWithString:href];
    if (realUrl == nil) {
        realUrl = [NSURL URLWithString:[href stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    NSString* scheme = [realUrl.scheme lowercaseString];
    if ([scheme isEqualToString:@"XXX"]) {
        //        NSString *lastCompment = [[realUrl path] lastPathComponent];
        //        NSDictionary *paramDic = [XECommonUtils getParamDictFrom:realUrl.query];
        //        if ([[realUrl host] isEqualToString:@"AAA"]) {
        //            return nil;
        //        }
        //        //else if...
        
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
