//
//  WYPayManager.m
//  WangYu
//
//  Created by KID on 15/5/20.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYPayManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "WYProgressHUD.h"

#define APP_ID          @"wxb10451ed2c4a6ce3"
//商户号
#define MCH_ID          @"1233963002"
//商户API密钥
#define PARTNER_ID      @"313F422AC583444BA6045CD122653B0E"

static WYPayManager* wy_payManager = nil;

@interface WYPayManager ()
{
    NSMutableArray* _listeners;
}
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

- (void)addListener:(id<WYPayManagerListener>)listener{
    [_listeners addObject:listener];
}
- (void)removeListener:(id<WYPayManagerListener>)listener{
    [_listeners removeObject:listener];
}
- (void)login {
    _listeners = [[NSMutableArray alloc] init];
}
- (void)logout {
    [_listeners removeAllObjects];
}

- (void)payForWinxinWith:(NSDictionary *)dictionary {
    NSString *partnerId = MCH_ID;
    NSString *prepayId = [dictionary objectForKey:@"prepay_id"];
    NSString *package, *time_stamp, *nonce_str;
    time_t now;
    time(&now);
    time_stamp  = [NSString stringWithFormat:@"%ld", now];
    nonce_str	= [dictionary objectForKey:@"nonce_str"];
    package         = @"Sign=WXPay";
    
    //第二次签名参数列表
    NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
    [signParams setObject:APP_ID        forKey:@"appid"];
    [signParams setObject:nonce_str!=nil?nonce_str:@""  forKey:@"noncestr"];
    [signParams setObject:package      forKey:@"package"];
    [signParams setObject:partnerId        forKey:@"partnerid"];
    [signParams setObject:time_stamp   forKey:@"timestamp"];
    [signParams setObject:prepayId!=nil?prepayId:@""     forKey:@"prepayid"];
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

- (void)payForAlipayWith:(NSDictionary *)dictionary {
    Order *order = [[Order alloc] init];
    order.partner = AliPay_PID;
    order.seller = AliPay_Seller;
//    order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.tradeNO = [dictionary objectForKey:@"out_trade_no"]; //订单ID
    order.productName = [dictionary objectForKey:@"netbarName"]; //商品标题
    order.productDescription = @"上网费用"; //商品描述
    order.amount = [dictionary objectForKey:@"amount"]; //商品价格
    order.notifyURL =  @"http://api.test.wangyuhudong.com/pay/alipayNotify"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    NSString *appScheme = @"WY";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(AliPay_PrivateKey);
    NSString *signedString = [signer signString:orderSpec];
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    NSArray *array = [[UIApplication sharedApplication] windows];
    UIWindow* win=[array objectAtIndex:0];
    [win setHidden:NO];
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic)
         {
             NSLog(@"reslut = %@", resultDic);
             NSInteger status = [[resultDic objectForKey:@"resultStatus"] integerValue];
             switch (status) {
                 case 9000:
                 {
//                     NSLog(@"===============支付成功");
                     [WYProgressHUD AlertSuccess:@"支付宝支付成功"];
                     //通知lisnteners
                     NSArray* listeners = [_listeners copy];
                     for (id<WYPayManagerListener> listener in listeners) {
                         if ([listener respondsToSelector:@selector(payManagerResultStatus:payType:)]) {
                             [listener payManagerResultStatus:1 payType:0];
                         }
                     }
                 }
                     break;
                 default:
                 {
                     [WYProgressHUD AlertError:@"支付宝支付失败"];
                     NSLog(@"===============支付失败%@", [resultDic objectForKey:@"memo"]);
                     NSArray* listeners = [_listeners copy];
                     for (id<WYPayManagerListener> listener in listeners) {
                         if ([listener respondsToSelector:@selector(payManagerResultStatus:payType:)]) {
                             [listener payManagerResultStatus:0 payType:0];
                         }
                     }
                 }
                     break;
             }
             [win setHidden:YES];
         }];
        
    }
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
                [WYProgressHUD AlertSuccess:@"微信支付成功"];
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                //通知lisnteners
                NSArray* listeners = [_listeners copy];
                for (id<WYPayManagerListener> listener in listeners) {
                    if ([listener respondsToSelector:@selector(payManagerResultStatus:payType:)]) {
                        [listener payManagerResultStatus:1 payType:1];
                    }
                }
            }
                break;
                
            default:
                [WYProgressHUD AlertError:@"微信支付失败"];
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                NSArray* listeners = [_listeners copy];
                for (id<WYPayManagerListener> listener in listeners) {
                    if ([listener respondsToSelector:@selector(payManagerResultStatus:payType:)]) {
                        [listener payManagerResultStatus:0 payType:1];
                    }
                }
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

- (NSString *)generateTradeNO
{
    static int kNumber = 20;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((int)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

@end
