//
//  URLHelper.h
//  ；
//
//  Created by junmin liu on 11-3-24.
//  Copyright 2011年 Openlab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface URLHelper : NSObject {
    
}

+ (NSString *)getURL:(NSString *)baseUrl 
	 queryParameters:(NSDictionary*)params;
+ (NSString *)getURL:(NSString *)baseUrl
	 queryParameters:(NSDictionary*)params prefixed:(BOOL)prefixed;
+ (NSString *)encodeString:(NSString *)string;

@end
