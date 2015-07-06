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
#import "OrdersViewController.h"
#import "RedPacketViewController.h"
#import "MessageDetailsViewController.h"
#import "BookDetailViewController.h"
#import "OrderDetailViewController.h"
#import "WYMessageInfo.h"
#import "MatchWarDetailViewController.h"

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
            MessageDetailsViewController *mdVc = [[MessageDetailsViewController alloc] init];
            WYMessageInfo *messageInfo = [[WYMessageInfo alloc] init];
            messageInfo.msgId = [[paramDic objectForKey:@"msgId"] description];
            mdVc.messageInfo = messageInfo;
            return mdVc;
        }else if ([[realUrl host] isEqualToString:@"redbag"]){
            //红包消息
            RedPacketViewController *rpVc = [[RedPacketViewController alloc] init];
            return rpVc;
        }else if ([[realUrl host] isEqualToString:@"reservation"]){
            //预定订单消息
            BookDetailViewController *bdVc = [[BookDetailViewController alloc] init];
            WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
            orderInfo.reserveId = [[paramDic objectForKey:@"objId"] description];
            bdVc.orderInfo = orderInfo;
            return bdVc;
        }else if ([[realUrl host] isEqualToString:@"pay"]){
            //支付消息
            OrderDetailViewController *odVc = [[OrderDetailViewController alloc] init];
            WYOrderInfo *orderInfo = [[WYOrderInfo alloc] init];
            orderInfo.orderId = [[paramDic objectForKey:@"objId"] description];
            odVc.orderInfo = orderInfo;
            return odVc;
        }else if ([[realUrl host] isEqualToString:@"activity"]){
            //活动赛事消息
            
        }else if ([[realUrl host] isEqualToString:@"match"]){
            //约战消息
            
        }else if ([[realUrl host] isEqualToString:@"redbag_weekly"]){
            //每周红包推送消息
            [[WYSettingConfig staticInstance] setWeekRedBagMessageUnreadEvent:YES];
        }else if ([[realUrl host] isEqualToString:@"member"]){
            //会员消息
        }
        return nil;
        
    }else if ([scheme isEqualToString:@"wydsopen"]){
        NSDictionary *paramDic = [WYCommonUtils getParamDictFrom:realUrl.query];
        NSLog(@"query dict = %@", paramDic);
        
        NSString *action = [[realUrl.host lowercaseString] description];
        if ([action isEqualToString:@"showmatch"]) {
            //约战详情
            MatchWarDetailViewController *matchDetailVc = [[MatchWarDetailViewController alloc] init];
            WYMatchWarInfo *matchWarInfo = [[WYMatchWarInfo alloc] init];
            matchWarInfo.mId = [[paramDic objectForKey:@"matchId"] description];
            matchDetailVc.matchWarInfo = matchWarInfo;
            return matchDetailVc;
        }
        
    }else if([scheme hasPrefix:@"http"]){
        //        NSString *lastCompment = [[realUrl path] lastPathComponent];
        //        NSDictionary *paramDic = [XECommonUtils getParamDictFrom:realUrl.query];
        //if...else
        
        if (nav) {
            NSString *url = [realUrl description];
            WYCommonWebVc *webvc = [[WYCommonWebVc alloc] initWithAddress:url];
            [nav pushViewController:webvc animated:YES];
        }
        return nil;
    }
    
    return nil;
}

@end
