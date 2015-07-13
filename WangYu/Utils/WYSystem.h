//
//  WYSystem.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#ifndef WangYu_WYSystem_h
#define WangYu_WYSystem_h

#import "WYUIKitMacro.h"
#import "NSDictionary+ObjectForKey.h"
#import "WYUIUtils.h"

//第三方参数
#define QQ_ID                       @"1104513102"
#define QQ_Key                      @"L3PVlr3bpXd9I63d"
#define WX_ID                       @"wxb10451ed2c4a6ce3"
#define WX_Secret                   @"d95b2512200cb6696c63e6fec2110a4d"
#define SINA_ID                     @"3734649134"
#define SINA_Secret                 @"57bba34da9bae335b351f2057283bbf1"
#define Sina_RedirectURL            @"http://www.wangyuhudong.com"
#define UMS_APPKEY                  @"556beab167e58e5552001ece"

//支付宝
#define AliPay_PID                      @"2088811682564735"
#define AliPay_Seller                   @"yus@miqtech.com"
#define AliPay_PublicKey                @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBQnpcQZOZbVq3i58T/ubOZxsmmtZrNVsaoYs/CXnQ3Fmqfs0loctzXaItkN1eIGzn2x8BobE2u1Mo82aio3mIxeBsY1PT4ZXHbz62WjJvRNiO/eQKU5y10DPCSeL1OldnWGE6oEYwMTiEXEehy4ax029a+C/x49lB6C7wOX4UkwIDAQAB"
#define AliPay_PrivateKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMFCelxBk5ltWreLnxP+5s5nGyaa1ms1Wxqhiz8JedDcWap+zSWhy3Ndoi2Q3V4gbOfbHwGhsTa7UyjzZqKjeYjF4GxjU9PhlcdvPrZaMm9E2I795ApTnLXQM8JJ4vU6V2dYYTqgRjAxOIRcR6HLhrHTb1r4L/Hj2UHoLvA5fhSTAgMBAAECgYBy/CuzUm0QX2kXReJbUlFfQyd7W6rx1Kgk+zLPScMJyuEquRE0L8TOGkrRE50yUNabSNt07BB1gRUki1VotR0sglIiHmlVmlsjU/BoCMeWL733nX4ZI0muTfT9FD7G82UM0bB/N+gw/cdowuned6d5qQDkzALHISzi8L5FEriZyQJBAPgnGROIz66RQDL92hDb2HCarBul6Fqm9pJ6maGWxV7U35rZnl00JQzjScSmI/dqgIXh7Bi/6F/H1HctfqUuBw8CQQDHXv9Wkm4edqeU/c84aKuRDucb2S5JU6V3217JX9rw5JuJUGCWZqGa8EwZjApNbHvhoqPoY4/tXKiGWsP5Qzo9AkEAwqdotDoNLxIhGd6mv7K0BSBPASETMojlweEJwgdSqyCwhfdOki3lIkboBqmMbPfN+TdOy9s9nGRT9Whqf4erYQJAcqwqU2IP4oe+5gyCZuCVZe7bcQIfBGAPOXw87birloj3CSjpFTjc1OBH9R2+Q0AVlPdWLXEutIjqCbUlKTbIxQJAZXsPnjH9T6INmS4iwBuauobBs6OTtesxu8CFPzLFyKPpps/xBSfCJ0JsJ8HLSmjoqw/d305qHc6/fovL+sdJVw=="

#define SINGLE_CELL_HEIGHT 44.f
#define SINGLE_HEADER_HEADER 6.f

#define MAX_WX_IMAGE_SIZE 32*1024
#define WY_IMAGE_COMPRESSION_QUALITY 0.4

#define DATA_LOAD_PAGESIZE_COUNT 10

#define SKIN_COLOR [UIColor colorWithRed:(1.0*0xfd/0xff) green:(1.0*0xd6/0xff) blue:(1.0*0x44/0xff) alpha:1]

#define SKIN_TEXT_COLOR1 [UIColor colorWithRed:(1.0*0x33/0xff) green:(1.0*0x33/0xff) blue:(1.0*0x33/0xff) alpha:1]
#define SKIN_TEXT_COLOR2 [UIColor colorWithRed:(1.0*0x9a/0xff) green:(1.0*0x9a/0xff) blue:(1.0*0x9a/0xff) alpha:1]
#define SKIN_TEXT_COLOR3 [UIColor colorWithRed:(1.0*0xf0/0xff) green:(1.0*0x3f/0xff) blue:(1.0*0x3f/0xff) alpha:1]
#define SKIN_TEXT_COLOR4 [UIColor colorWithRed:(1.0*0x66/0xff) green:(1.0*0x66/0xff) blue:(1.0*0x66/0xff) alpha:1]
#define SKIN_TEXT_COLOR5 [UIColor colorWithRed:(1.0*0xf1/0xff) green:(1.0*0xf1/0xff) blue:(1.0*0xf1/0xff) alpha:1]
#define SKIN_TEXT_COLORRED [UIColor colorWithRed:(1.0*0xf0/0xff) green:(1.0*0x3f/0xff) blue:(1.0*0x3f/0xff) alpha:1]

#define FONT_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dqw3.otf"]
#define SKIN_FONT(X) [WYUIUtils customFontWithPath:FONT_PATH size:X];

#define FONT_NAME @"HiraginoSansGB-W3"//冬青
#define SKIN_FONT_FROMNAME(X) [WYUIUtils customFontWithFontName:FONT_NAME size:X];

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

//用于block获取弱引用
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

// 自定义Log
#ifdef DEBUG
#define WYLog(...) NSLog(__VA_ARGS__)
#else
#define WYLog(...)
#endif


#define WY_MATCHWAR_OWNER_CANCLE_NOTIFICATION @"WY_MATCHWAR_OWNER_CANCLE_NOTIFICATION" //取消约战通知

#endif
