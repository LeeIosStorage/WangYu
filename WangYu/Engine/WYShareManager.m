//
//  WYShareManager.m
//  WangYu
//
//  Created by KID on 15/5/19.
//  Copyright (c) 2015年 KID. All rights reserved.
//

#import "WYShareManager.h"
#import "WYProgressHUD.h"
#import "WYAlertView.h"

static WYShareManager* wy_shareManager = nil;

@interface WYShareManager (){
    TencentOAuth *_tencentOAuth;
}
@property(nonatomic, strong) WYWeiboShareResultBlock shareBlock;

@end

@implementation WYShareManager

+ (WYShareManager*)shareInstance {
    @synchronized(self) {
        if (wy_shareManager == nil) {
            wy_shareManager = [[WYShareManager alloc] init];
        }
    }
    return wy_shareManager;
}

- (id)init{
    self = [super init];
    if (self) {
        [WXApi registerApp:WX_ID withDescription:@"WY"];
        
#ifdef DEBUG
        [WeiboSDK enableDebugMode:YES];
#endif
        [WeiboSDK registerApp:SINA_ID];
        
        _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQ_ID andDelegate:nil];
    }
    return self;
}

- (BOOL)shareToWXWithScene:(int)scene title:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image{
    
    if (!([WXApi isWXAppInstalled])) {
        NSLog(@"not support or not install weixin");
        [WYUIUtils showAlertWithMsg:@"微信分享失败！"];
        return NO;
    } 
    
    WXMediaMessage *msg = [WXMediaMessage message];
    msg.title = title;
    msg.description = description;
    
    if (msg.title.length > 512) {
        msg.title = [msg.title substringToIndex:512];
    }
    if (msg.description.length>1024) {
        msg.description = [msg.description substringToIndex:1024];
    }
    
    if (scene == WXSceneTimeline) {
        msg.description = msg.title;
//        if (msg.description.length > 0) {
//            msg.title = [msg.description substringToIndex:MIN(msg.description.length, 512)];
//        }
    }
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = webpageUrl;
    
    NSData *imgData = nil;
    
    if (!image) {
        image = [UIImage imageNamed:@"netbar_load_icon"];
    }
    if (image) {
        imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY);
        if (imgData.length > MAX_WX_IMAGE_SIZE) {//try again
            imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY/2);
        }
        
    }
    msg.mediaObject = ext;
    if (imgData && imgData.length < MAX_WX_IMAGE_SIZE) {
        [msg setThumbData:imgData];
    }else{
    }
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = msg;
    req.scene = scene;
    BOOL ret = [WXApi sendReq:req];
    WYLog(@"shareToWX send ret:%d", ret);
    return ret;
}

- (void)shareToWb:(WYWeiboShareResultBlock)result title:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image VC:(id)VC{
    if (!([WeiboSDK isWeiboAppInstalled])) {
//        WYAlertView *alert = [[WYAlertView alloc] initWithTitle:@"提示" message:@"微博未安装，是否前往安装" cancelButtonTitle:@"取消" cancelBlock:^{
//            
//        } okButtonTitle:@"确定" okBlock:^{
//            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:[WeiboSDK getWeiboAppInstallUrl]]];
//        }];
//        [alert show];
//        return;
        NSLog(@"not support or not install weixin");
        [WYUIUtils showAlertWithMsg:@"微博分享失败！"];
        return;
    }

    self.shareBlock = result;
    
    /*****多媒体
    WBWebpageObject *msg = [WBWebpageObject object];
    msg.title = title;
    msg.description = description;
    [msg setObjectID:@"identifier1"];
    if (msg.description.length>1024) {
        msg.description = [msg.description substringToIndex:1024];
    }
    NSData *imgData = nil;
    if (!image) {
        image = [UIImage imageNamed:@"netbar_load_icon"];
    }
    if (image) {
        imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY);
        if (imgData.length > MAX_WX_IMAGE_SIZE) {//try again
            imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY/2);
        }
    }
    if (imgData && imgData.length < MAX_WX_IMAGE_SIZE) {
        [msg setThumbnailData:imgData];
    }else{
    }
    msg.webpageUrl = webpageUrl;
    */
    
    WBImageObject *msg = [WBImageObject object];
    NSData *imgData = nil;
    if (!image) {
        image = [UIImage imageNamed:@"netbar_load_icon"];
    }
    if (image) {
        imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY);
        if (imgData.length > MAX_WX_IMAGE_SIZE) {//try again
            imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY/2);
        }
    }
    if (imgData && imgData.length < MAX_WX_IMAGE_SIZE) {
        msg.imageData = imgData;
    }else{
    }
    
    WBMessageObject *sendMsg = [WBMessageObject message];
    sendMsg.imageObject = msg;
//    sendMsg.mediaObject = msg;
    NSString* shareTitle = [NSString stringWithFormat:@"%@  %@ %@",title,@"(分享自@网娱大师)",webpageUrl];
    sendMsg.text = shareTitle;
    
    //不能SSO分享
//    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest request];
//    request.message = sendMsg;
    
    //SSO分享
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = Sina_RedirectURL;
    authRequest.scope = @"all";
    NSString *vcStr = NSStringFromClass([VC class]);
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:sendMsg authInfo:authRequest access_token:nil];
    request.userInfo = @{@"ShareMessageFrom":vcStr};
    
    BOOL ret = [WeiboSDK sendRequest:request];
    WYLog(@"shareToWb send ret:%d", ret);
}

- (void)shareToQQTitle:(NSString *)title description:(NSString *)description webpageUrl:(NSString *)webpageUrl image:(UIImage*)image{
    
    if (title.length > 128) {
        title = [title substringToIndex:128];
    }
    if (description.length>512) {
        description = [description substringToIndex:512];
    }
    
    NSData *imgData = nil;
    if (!image) {
        image = [UIImage imageNamed:@"netbar_load_icon"];
    }
    if (image) {
        imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY);
        if (imgData.length > MAX_WX_IMAGE_SIZE/32) {//try again
            imgData = UIImageJPEGRepresentation(image, WY_IMAGE_COMPRESSION_QUALITY/2);
        }
    }
    
//    QQApiTextObject* txtObj = [QQApiTextObject objectWithText:title];//分享纯文字
//    QQApiImageObject* contenObj = [QQApiImageObject objectWithData:imgData previewImageData:imgData title:title description:description];//图片分享
    QQApiNewsObject* contenObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:webpageUrl] title:title description:description previewImageData:imgData];//链接分享
//    QQApiAudioObject* contenObj = [QQApiAudioObject objectWithURL:[NSURL URLWithString:webpageUrl] title:title description:description previewImageData:imgData];
//    contenObj.targetContentType = QQApiURLTargetTypeAudio;
    
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:contenObj];
    
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    WYLog(@"shareToQQ send ret:%d", sent);
}

#pragma mark - WeiboSDKDelegate
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response {
    
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
    }else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        if (self.shareBlock) {
            self.shareResponse = (WBSendMessageToWeiboResponse *)response;
            self.shareBlock((WBSendMessageToWeiboResponse *)response);
            self.shareResponse = nil;
        }
        if (response.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [WYProgressHUD AlertSuccess:@"分享微博成功"];
        }else{
            [WYProgressHUD AlertError:@"分享微博失败"];
        }
    }
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
    switch (req.type)
    {
        case EGETMESSAGEFROMQQREQTYPE:
        {
            break;
        }
        default:
        {
            break;
        }
    }
}

- (void)onResp:(QQBaseResp *)resp
{
    switch (resp.type)
    {
        case ESENDMESSAGETOQQRESPTYPE:
        {
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if ([sendResp.result intValue] == EQQAPISENDSUCESS) {
                [WYProgressHUD AlertSuccess:@"分享QQ成功"];
            }else{
                [WYProgressHUD AlertError:@"分享QQ失败"];
//                [self performSelector:@selector(shareAlertWithTitle:) withObject:@"分享QQ失败" afterDelay:1.0];
            }
            break;
        }
        default:
        {
            break;
        }
    }
}
- (void)isOnlineResponse:(NSDictionary *)response{
    
}

#pragma mark - custom
-(void)shareAlertWithTitle:(NSString *)title{
    [WYProgressHUD AlertError:title];
}

@end
