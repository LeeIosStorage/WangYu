//
//  QHQnetworkingTool.m
//  中融金投
//
//  Created by MIQ on 14-10-29.
//  Copyright (c) 2014年 MIQ. All rights reserved.
//

#import "QHQnetworkingTool.h"
#import "AFNetworking.h"

@implementation QHQnetworkingTool

+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
//    JFLog(@"%@",url);
    
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.发送请求
    [manager POST:url parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (success) {
              success(responseObject);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failure) {
              failure(error);
          }
      }];
}

+ (void)postWithURL:(NSString *)url params:(NSDictionary *)params formDataArray:(NSArray *)formDataArray success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
//    JFLog(@"%@",url);
    
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.发送请求
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> totalFormData) {
        for (QHQFormData *formData in formDataArray) {
            [totalFormData appendPartWithFileData:formData.data name:formData.name fileName:formData.filename mimeType:formData.mimeType];
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
//    JFLog(@"%@",url);
    
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.发送请求
    [manager GET:url parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         if (success) {
             success(responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (failure) {
             failure(error);
         }
     }];
}

+ (NSDictionary *)syncPostWithURL:(NSString *)url params:(NSString *)params
{
    NSURL *postUrl = [NSURL URLWithString:url];
    //    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:postUrl];
    request.HTTPMethod = @"POST";
    NSString *str = [NSString stringWithString:params];
    request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:received
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
//        JFLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
/**
 *  用来封装文件数据的模型
 */
@implementation QHQFormData

@end
