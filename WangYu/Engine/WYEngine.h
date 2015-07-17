//
//  WYEngine.h
//  WangYu
//
//  Created by KID on 15/4/22.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYUserInfo.h"

#define WY_USERINFO_CHANGED_NOTIFICATION @"WY_USERINFO_CHANGED_NOTIFICATION"

#define UMS_Action_Info_Pay          @"Info_Pay"
#define Pay_Amount                   @"Pay_Amount"

//平台切换宏
typedef enum {
    OnlinePlatform  = 1,    //线上平台
    TestPlatform    = 2,    //测试平台
}ServerPlatform;

typedef void(^onAppServiceBlock)(NSInteger tag, NSDictionary* jsonRet, NSError* err);

@interface WYEngine : NSObject

@property (nonatomic, strong) NSString* uid;
@property (nonatomic, strong) NSString* account;
@property (nonatomic, strong) NSString* userPassword;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) WYUserInfo* userInfo;
@property (nonatomic, readonly) NSDictionary* globalDefaultConfig;

@property (nonatomic, readonly) NSString* baseUrl;
@property (nonatomic, readonly) NSString* baseImgUrl;
@property (nonatomic, assign) BOOL firstLogin;

@property (nonatomic, assign) ServerPlatform serverPlatform;
@property (nonatomic, readonly) NSString* wyInstanceDocPath;

+ (WYEngine *)shareInstance;
+ (NSDictionary*)getReponseDicByContent:(NSData*)content err:(NSError*)err;
+ (NSString*)getErrorMsgWithReponseDic:(NSDictionary*)dic;
+ (NSString*)getErrorCodeWithReponseDic:(NSDictionary*)dic;
+ (NSString*)getSuccessMsgWithReponseDic:(NSDictionary*)dic;

#pragma mark 友盟统计
+ (void)umengEvent:(NSString *)eventID object:(NSString *)object result:(NSDictionary *)resultDic;

- (void)logout;
- (void)logout:(BOOL)removeAccout;

#pragma mark - userInfo
- (void)saveAccount;
- (NSString*)getCurrentAccoutDocDirectory;
- (NSString*)getMemoryLoginedAccout;//获取记忆登录过的Account
- (NSString*)getMemoryLoginedPassword;

- (void)refreshUserInfo;
- (BOOL)hasAccoutLoggedin;

#pragma mark - Visitor
- (void)visitorLogin;
- (BOOL)needUserLogin:(NSString *)message;
- (void)gotoLogin;

#pragma mark - request
- (int)getConnectTag;
- (void)addOnAppServiceBlock:(onAppServiceBlock)block tag:(int)tag;
- (void)removeOnAppServiceBlockForTag:(int)tag;
- (void)addGetCacheTag:(int)tag;
- (onAppServiceBlock)getonAppServiceBlockByTag:(int)tag;

//异步回调
- (void)getCacheReponseDicForTag:(int)tag complete:(void(^)(NSDictionary* jsonRet))complete;
- (void)getCacheReponseDicForUrl:(NSString*)url complete:(void(^)(NSDictionary* jsonRet))complete;

//保存cache
- (void)saveCacheWithString:(NSString*)str url:(NSString*)url;
- (void)clearAllCache;
- (unsigned long long)getUrlCacheSize;

#pragma mark ------ API LIST
- (BOOL)registerWithPhone:(NSString*)phone password:(NSString*)password invitationCode:(NSString*)invitationCode tag:(int)tag;
//获取验证码
- (BOOL)getCodeWithPhone:(NSString*)phone type:(NSString*)type tag:(int)tag;
//校验验证码
- (BOOL)checkCodeWithPhone:(NSString*)phone code:(NSString*)msgcode codeType:(NSString*)type tag:(int)tag;
//重置密码
- (BOOL)resetPassword:(NSString*)password withPhone:(NSString*)phone phoneCode:(NSString*)phoneCode tag:(int)tag;
//校验邀请码
- (BOOL)checkInvitationCodeWithCode:(NSString*)invitationCode tag:(int)tag;

- (BOOL)loginWithPhone:(NSString*)phone password:(NSString*)password tag:(int)tag error:(NSError **)errPtr;
- (BOOL)getUserInfoWithUid:(NSString*)uid tag:(int)tag error:(NSError **)errPtr;
- (BOOL)getAppNewVersionWithTag:(int)tag;

#pragma mark - 网吧
//首页网吧list
- (BOOL)getNetbarListWithUid:(NSString *)uid latitude:(float)latitude longitude:(float)longitude areaCode:(NSString *)areaCode tag:(int)tag;
//网吧详情
- (BOOL)getNetbarDetailWithUid:(NSString *)uid netbarId:(NSString *)nid tag:(int)tag;
//一键预订网吧
- (BOOL)getNetbarAllListForOrderWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize latitude:(float)latitude longitude:(float)longitude areaCode:(NSString *)areaCode type:(int)type tag:(int)tag;
//网吧列表(全部)
- (BOOL)getNetbarAllListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize latitude:(float)latitude longitude:(float)longitude areaCode:(NSString *)areaCode type:(int)type tag:(int)tag;
//搜索网吧(网吧名称)
- (BOOL)searchNetbarWithUid:(NSString *)uid netbarName:(NSString *)netbarName latitude:(float)latitude longitude:(float)longitude type:(int)type tag:(int)tag;
//附近网吧(经纬度)
- (BOOL)searchLocalNetbarWithUid:(NSString *)uid latitude:(float)latitude longitude:(float)longitude tag:(int)tag;
//附近网吧(城市)
- (BOOL)searchMapNetbarWithUid:(NSString *)uid city:(NSString *)city latitude:(float)latitude longitude:(float)longitude tag:(int)tag;
//一键预订
- (BOOL)quickBookingWithUid:(NSString *)uid reserveDate:(NSString *)date amount:(double)amount netbarId:(NSString *)nid hours:(int)hours num:(int)num remark:(NSString *)remark tag:(int)tag;
//预订订单支付
- (BOOL)reservePayWithUid:(NSString *)uid body:(NSString *)body orderId:(NSString *)orderId packetsId:(NSArray*)pids type:(int)type tag:(int)tag;
//支付订单支付 origAmount:原始金额 amount:折扣过的金额
- (BOOL)orderPayWithUid:(NSString *)uid body:(NSString *)body amount:(double)amount netbarId:(NSString *)nid packetsId:(NSArray*)pids type:(int)type origAmount:(double)origAmount tag:(int)tag;
//定金支付
- (BOOL)reserveToOrderWithUid:(NSString *)uid reserveId:(NSString *)reserveId tag:(int)tag;
//确认到店
- (BOOL)confirmReserveWithUid:(NSString *)uid reserveId:(NSString *)reserveId tag:(int)tag;
//预订订单详情
- (BOOL)getReserveDetailWithUid:(NSString *)uid reserveId:(NSString *)reserveId tag:(int)tag;
//支付订单详情
- (BOOL)getOrderDetailwithUid:(NSString *)uid orderId:(NSString *)orderId tag:(int)tag;

//网吧收藏
- (BOOL)collectionNetbarWithUid:(NSString *)uid netbarId:(NSString *)nid tag:(int)tag;
- (BOOL)unCollectionNetbarWithUid:(NSString *)uid netbarId:(NSString *)nid tag:(int)tag;

- (BOOL)getReserveOrderListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
- (BOOL)getPayOrderListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
- (BOOL)cancelReserveOrderWithUid:(NSString *)uid reserveId:(NSString *)reserveId tag:(int)tag;
- (BOOL)deletePayOrderWithUid:(NSString *)uid orderId:(NSString *)orderId tag:(int)tag;
//有效的二级城市
- (BOOL)getAllValidCityListWithTag:(int)tag;
//有效的下一级地区
- (BOOL)getValidChildrenListWithCode:(NSString *)code tag:(int)tag;
//验证城市是否开通
- (BOOL)validateAreaWithAreaName:(NSString *)areaName tag:(int)tag;

#pragma mark - mine
//完善资料
- (BOOL)editUserInfoWithUid:(NSString *)uid nickName:(NSString *)nickName avatar:(NSArray *)avatar userHead:(NSString *)userHead qqNumber:(NSString *)qqNumber  sex:(NSString*)sex realName:(NSString *)realName idCard:(NSString*)idCard tag:(int)tag;
//更换城市
- (BOOL)editUserCityWithUid:(NSString *)uid cityCode:(NSString *)cityCode cityName:(NSString *)cityName tag:(int)tag;
//头像列表
- (BOOL)getHeadAvatarListWithTag:(int)tag;
//未读消息个数
- (BOOL)getUnReadMessageCountWithUid:(NSString *)uid type:(int)type tag:(int)tag;
//新未读消息个数（2.0以后）
- (BOOL)getUnReadMessageCountWithUid:(NSString *)uid tag:(int)tag;
//设置消息已读
- (BOOL)setMessageReadWithUid:(NSString *)uid type:(int)type tag:(int)tag;
//新设置消息已读（2.0以后）
- (BOOL)setMessageReadWithUid:(NSString *)uid msgId:(NSString *)mid type:(int)type tag:(int)tag;
//删除消息
- (BOOL)deleteMessageWithUid:(NSString *)uid msgId:(NSString *)mid type:(int)type tag:(int)tag;
//消息
- (BOOL)getMessageListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize type:(int)type tag:(int)tag;
//收藏的网吧
- (BOOL)getCollectNetBarListWithUid:(NSString *)uid latitude:(float)latitude longitude:(float)longitude page:(int)page pageSize:(int)pageSize tag:(int)tag;
//收藏的游戏
- (BOOL)getCollectGameListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
- (BOOL)getFreeRedPacketListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
- (BOOL)getHistoryRedPacketListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//报名赛事
- (BOOL)getApplyActivityListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//我发布的约战
- (BOOL)getPulishMatchWarListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//我报名的约战
- (BOOL)getApplyMatchWarListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//我的战队
- (BOOL)getMatchTeamListWithUid:(NSString *)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//意见反馈
- (BOOL)feedBackMessageWithUid:(NSString*)uid content:(NSString*)content contact:(NSString*)contact tag:(int)tag;
//填写邀请码
- (BOOL)uploadMineInviteCodeWith:(NSString*)uid invitationCode:(NSString*)invitationCode tag:(int)tag;
//获取首页广告
- (BOOL)getAdvertsWithTag:(int)tag;

#pragma mark - 活动
//赛事列表
- (BOOL)getActivityListWithPage:(int)page pageSize:(int)pageSize tag:(int)tag;
//资讯列表
- (BOOL)getInfoListWithPage:(int)page pageSize:(int)pageSize tag:(int)tag;
//约战列表
- (BOOL)getMatchListWithPage:(int)page pageSize:(int)pageSize tag:(int)tag;
//赛事详情
- (BOOL)getActivityDetailWithUid:(NSString *)uid activityId:(NSString *)aId pageSize:(int)pageSize tag:(int)tag;
//收藏/取消收藏 赛事
- (BOOL)collectionActivityWithUid:(NSString *)uid activityId:(NSString *)aId tag:(int)tag;
//赛事地点
- (BOOL)getActivityAddressWithUid:(NSString *)uid activityId:(NSString *)aId tag:(int)tag;
//热门 赛事资讯
- (BOOL)getActivityHotListWithTag:(int)tag;
//专题详情
- (BOOL)getTopicsInfoWithTag:(int)tag;
//专题资讯列表
- (BOOL)getTopicsListWithTid:(NSString *)tid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//个人报名
- (BOOL)applyMatchWithUid:(NSString *)uid activityId:(NSString *)aId netbarId:(NSString *)nId name:(NSString *)name telephone:(NSString *)telephone idcard:(NSString *)idcard qqNum:(NSString *)qqNum labor:(NSString *)labor round:(int)round tag:(int)tag;
//战队报名(创建战队)
- (BOOL)createMatchTeamWithUid:(NSString *)uid activityId:(NSString *)aId netbarId:(NSString *)nId teamName:(NSString *)teamName name:(NSString *)name telephone:(NSString *)telephone idcard:(NSString *)idcard qqNum:(NSString *)qqNum labor:(NSString *)labor round:(int)round server:(NSString *)server tag:(int)tag;
//已报名战队
- (BOOL)getMatchJoinedTeamWithUid:(NSString *)uid activityId:(NSString *)aId netbarId:(NSString *)nId areaCode:(NSString *)areaCode page:(int)page pageSize:(int)pageSize tag:(int)tag;
//加入战队
- (BOOL)joinMatchTeamWithUid:(NSString *)uid teamId:(NSString *)teamId name:(NSString *)name telephone:(NSString *)telephone idCard:(NSString *)idCard qqNum:(NSString *)qqNum labor:(NSString *)labor tag:(int)tag;
//退出战队
- (BOOL)exitMatchTeamWithUid:(NSString *)uid teamId:(NSString *)teamId tag:(int)tag;
//我的队友
- (BOOL)getMatchTeamMemberWithUid:(NSString *)uid teamId:(NSString *)teamId tag:(int)tag;
//添加队员
- (BOOL)addTeamMemberWithUid:(NSString *)uid activityId:(NSString *)aId teamId:(NSString *)teamId round:(int)round telephone:(NSString *)telephone tag:(int)tag;
//移除队友
- (BOOL)removeMemberWithUid:(NSString *)uid memberId:(NSString *)memberId tag:(int)tag;

#pragma mark - 手游
//手游列表
- (BOOL)getGameListWithUid:(NSString*)uid page:(int)page pageSize:(int)pageSize tag:(int)tag;
//手游详情
- (BOOL)getGameDetailsWithGameId:(NSString *)gameId uid:(NSString*)uid tag:(int)tag;
//收藏-取消收藏
- (BOOL)collectGameWithUid:(NSString *)uid gameId:(NSString *)gameId tag:(int)tag;
- (BOOL)getGameDownloadUrlWithGameId:(NSString*)gameId tag:(int)tag;

#pragma mark - Match
//约战竞技项目
- (BOOL)getMatchGameItemsWithUid:(NSString *)uid tag:(int)tag;
- (BOOL)matchPublishWithUid:(NSString *)uid title:(NSString *)title itemId:(NSString *)itemId server:(NSString *)server way:(int)way netbarId:(NSString *)netbarId netbarName:(NSString*)netbarName beginTime:(NSString *)beginTime num:(int)num contactWay:(NSString *)contactWay intro:(NSString *)intro invitedPhones:(NSArray *)invitedPhones tag:(int)tag;
- (BOOL)getMatchDetailsWithMatchId:(NSString*)matchId uid:(NSString*)uid tag:(int)tag;
- (BOOL)commitCommentMatchWithMatchId:(NSString*)matchId uid:(NSString*)uid content:(NSString*)content tag:(int)tag;
- (BOOL)getMatchCommentInfoWithMatchId:(NSString *)matchId page:(int)page pageSize:(int)pageSize tag:(int)tag;
//报名约战
- (BOOL)applyMatchWarWithUid:(NSString*)uid matchId:(NSString*)matchId tag:(int)tag;
//退出约战
- (BOOL)cancelApplyMatchWarWithUid:(NSString*)uid matchId:(NSString*)matchId tag:(int)tag;
//取消约战
- (BOOL)closeMatchWarWithUid:(NSString *)uid matchId:(NSString*)matchId tag:(int)tag;
//约战管理报名人列表
- (BOOL)manageMatchAppliersWithUid:(NSString*)uid matchId:(NSString *)matchId page:(int)page pageSize:(int)pageSize tag:(int)tag;
//移除约战报名成员
- (BOOL)removeApplyMatchWarPeopleWithMatchId:(NSString*)matchId uid:(NSString *)uid applyId:(NSString*)applyId tag:(int)tag;
//邀请人员
- (BOOL)invitedPbPeopleWithUid:(NSString *)uid matchId:(NSString*)matchId invitedPhones:(NSArray *)invitedPhones tag:(int)tag;

@end
