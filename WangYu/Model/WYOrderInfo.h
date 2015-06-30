//
//  WYOrderInfo.h
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYOrderInfo : NSObject

typedef enum RESERVESTATUS_{
    RESERVE_WAIT,                  //订单待处理           0
    RESERVE_CANCELLED,             //订单已取消(网吧未接单)
    RESERVE_RECEIVE,               //网吧已接单
    RESERVE_REFUSE,                //网吧已拒单
    RESERVE_CANCEL,                //订单已取消(网吧接单后)
    RESERVE_FAILURE,               //订单支付失败
    RESERVE_PAYUP,                 //订单已支付
    RESERVE_CONFIRM,               //订单已确认
    RESERVE_FINISH,                //网吧确认用户已到店
}RESERVESTATUS;

@property(nonatomic, strong) NSString* orderId;                     //支付订单id
@property(nonatomic, strong) NSString* reserveId;                   //预订订单id
@property(nonatomic, strong) NSString* amount;                      //金额
@property(nonatomic, assign) int price;
@property(nonatomic, assign) int isReceive;                         // 1已接单0待处理-1已拒单
@property(nonatomic, assign) int isValid;                           // 0已取消1待处理2支付成功
@property(nonatomic, assign) int isRelated;                         //
@property(nonatomic, assign) int overpay;                           //多付款金额
@property(nonatomic, assign) int seating;                           //座位
@property(nonatomic, assign) int hours;                             //上网时间
@property(nonatomic, assign) int status;                            //状态 -1支付失败0新建订单1支付成功
@property(nonatomic, strong) NSDate* createDate;                    //下单时间
@property(nonatomic, strong) NSDate* reservationDate;               //上机时间
@property(nonatomic, strong) NSDate* beginTime;                     //上机开始时间
@property(nonatomic, strong) NSDate* endTime;                       //上机结束时间
@property(nonatomic, assign) int rStatus;                           //预定订单状态
@property(nonatomic, assign) int oStatus;                           //支付订单状态 -1支付失败0待支付1支付成功

//支付订单
@property(nonatomic, assign) int totalAmount;                       //总金额
@property(nonatomic, assign) int type;                              //支付类型:1-支付宝;2-财付通
@property(nonatomic, strong) NSString *outTradeNo;                  //支付宝支付需要
@property(nonatomic, strong) NSString *nonceStr;                    //微信支付需要
@property(nonatomic, strong) NSString *prepayId;                    //微信支付需要

@property(nonatomic, assign) int scoreAmount;                       //积分抵消金额
@property(nonatomic, assign) double redbagAmount;                   //红包抵消金额
@property(nonatomic, assign) int rebate;                            //打折力度


@property(nonatomic, strong) NSString* netbarId;                    //网吧id
@property(nonatomic, strong) NSString* netbarName;                  //网吧名称
@property(nonatomic, strong) NSString* icon;                        //网吧图片
@property(nonatomic, readonly) NSURL* netbarImageUrl;               //网吧图片地址
@property(nonatomic, strong) NSString* netbarTel;                   //网吧联系电话

@property(nonatomic, strong) NSString* userId;
@property(nonatomic, strong) NSString* telephone;

@property(nonatomic, strong) NSDictionary* orderInfoByJsonDic;     //网吧字典

@end
