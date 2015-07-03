//
//  WYNetbarInfo.h
//  WangYu
//
//  Created by KID on 15/5/13.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYNetbarInfo : NSObject

@property(nonatomic, strong) NSString* nid;                         //网吧id
@property(nonatomic, strong) NSString* netbarName;                  //名称
@property(nonatomic, strong) NSString* netbarImageUrl;              //图片地址
@property(nonatomic, strong) NSString* address;                     //位置
@property(nonatomic, strong) NSString* distance;                    //距离
@property(nonatomic, strong) NSString* telephone;                   //电话
@property(nonatomic, strong) NSString* latitude;                    //纬度
@property(nonatomic, strong) NSString* longitude;                   //经度
@property(nonatomic, strong) NSMutableArray* picIds;                //图片信息
@property(nonatomic, strong) NSMutableArray* matches;               //战队信息
@property(nonatomic, assign) BOOL isOrder;                          //是否支持预订
@property(nonatomic, assign) BOOL isPay;                            //是否支持支付
@property(nonatomic, assign) BOOL isRecommend;                      //是否被推荐
@property(nonatomic, assign) BOOL isFaved;                          //是否收藏
@property(nonatomic, assign) BOOL isDiscount;                       //是否打折
@property(nonatomic, assign) int rebate;                            //打折力度
@property(nonatomic, assign) int algorithm;                         //1 先打折在减红包金额 2先减去红包金额再打折
@property(nonatomic, assign) NSString *price;                       //上网价格
@property(nonatomic, strong) NSString *areaCode;                    //城市code
@property(nonatomic, strong) NSString *city;                        //城市
@property(nonatomic, readonly) NSArray* picURLs;                    //图片信息地址
@property(nonatomic, readonly) NSURL* smallImageUrl;                //图片网络地址
@property(nonatomic, strong) NSDictionary* netbarInfoByJsonDic;     //网吧字典

@end
