//
//  WYPayManager.m
//  WangYu
//
//  Created by KID on 15/5/20.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYPayManager.h"
#import <CommonCrypto/CommonDigest.h>

#define APP_ID          @"wxb10451ed2c4a6ce3"
//商户号
#define MCH_ID          @"1233963002"
//商户API密钥
#define PARTNER_ID      @"313F422AC583444BA6045CD122653B0E"

static WYPayManager* wy_payManager = nil;

@interface WYPayManager ()

@end

@implementation WYPayManager

+ (WYPayManager*)shareInstance {
    @synchronized(self) {
        if (wy_payManager == nil) {
            wy_payManager = [[WYPayManager alloc] init];
        }
    }
    return wy_payManager;
}

- (id)init{
    self = [super init];
    if (self) {
        [WXApi registerApp:WX_ID withDescription:@"WY"];
    }
    return self;
}

- (void)payForWinxinWith:(NSDictionary *)dic {
    NSString *partnerId = MCH_ID;
    NSString *prepayId = [dic objectForKey:@"prepay_id"];
    NSString *package, *time_stamp, *nonce_str;
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [dic objectForKey:@"nonce_str"];
    package         = @"Sign=WXPay";
    
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:APP_ID        forKey:@"appid"];
    [signParams setObject:nonce_str    forKey:@"noncestr"];
    [signParams setObject:package      forKey:@"package"];
    [signParams setObject:partnerId        forKey:@"partnerid"];
    [signParams setObject:time_stamp   forKey:@"timestamp"];
    [signParams setObject:prepayId     forKey:@"prepayid"];
    //生成签名
    NSString *sign  = [self createMd5Sign:signParams];
    //添加签名
    [signParams setObject:sign forKey:@"sign"];
    
    NSMutableDictionary *dict = signParams;
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = [time_stamp intValue];
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    [WXApi sendReq:req];
}

-(void) onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    }
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        
        switch (resp.errCode) {
            case WXSuccess:{
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                //                PayResp *payResp = (PayResp *)resp;
                //                NSDictionary *respDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:payResp.errCode],@"code",payResp.returnKey,@"message", nil];
                //                CDVPluginResult* pluginResult = [CDVPluginResult
                //                                                 resultWithStatus:CDVCommandStatus_OK
                //                                                 messageAsDictionary:respDic];
                //                [self writeJavascript:[pluginResult
                //                                       toSuccessCallbackString:self.callbackID]];
            }
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                //                NSDictionary *respDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:resp.errCode],@"code",resp.errStr,@"message", nil];
                //                CDVPluginResult* pluginResult = [CDVPluginResult
                //                                                 resultWithStatus:CDVCommandStatus_ERROR
                //                                                 messageAsDictionary:respDic];
                //                [self writeJavascript:[pluginResult
                //                                       toErrorCallbackString:self.callbackID]];
                
                break;
        }
    }
}

//md5 encode
- (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];

    return output;
}

//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
            && ![categoryId isEqualToString:@"sign"]
            && ![categoryId isEqualToString:@"key"]
            )
        {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
    }
    //添加key字段
    [contentString appendFormat:@"key=%@", PARTNER_ID];
    //得到MD5 sign签名
    NSString *md5Sign =[self md5:contentString];
    
    return md5Sign;
}

@end
