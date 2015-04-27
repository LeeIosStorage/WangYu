//
//  WYAuth2.h
//  WangYu
//
//  Created by KID on 15/4/24.
//  Copyright (c) 2015年 KID. All rights reserved.
//

static NSString * const kClientIdKey = @"client_id";
static NSString * const kClientSecretKey = @"client_secret";
static NSString * const kRedirectURIKey = @"redirect_uri";

static NSString * const kGrantTypeKey = @"grant_type";//授权类型
static NSString * const kAccessTokenKey = @"access_token";
static NSString * const kRefreshTokenKey = @"refresh_token";

static NSString * const kExpiresInKey = @"expires_in";
static NSString * const kGrantTypeAuthorizationCode = @"authorization_code";
static NSString * const kGrantTypeRefreshToken = @"refresh_token";
static NSString * const kGrantTypePassword = @"password";

static NSString * const kUsernameKey = @"username";
static NSString * const kPasswordKey = @"password";

static NSString * const kWangYuUserIdKey = @"wangyu_user_id";

static NSString * const kOAuth2ResponseTypeCode = @"code";
static NSString * const kOAuth2ResponseTypeToken = @"refresh_token";