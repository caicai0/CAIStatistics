//
//  CAISNet.m
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISNet.h"

@implementation CAISNet

+ (instancetype)net{
    static CAISNet * shareNet ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareNet = [[CAISNet alloc]init];
    });
    return shareNet;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadPlistFileVersion:(NSString *)version Finish:(void(^)(NSError* error,NSDictionary * response))finish{
    NSString * reportUrl = [NSString stringWithFormat:@"%@/statistic/download",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSDictionary * params = [NSMutableDictionary dictionary];
    if (version) {
        [params setValue:version forKey:@"version"];
    }
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        if (finish) {
            finish(error,nil);
        }
        return;
    }
    request.HTTPBody = jsonData;
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * dic = nil;
        if (data) {
            dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        }
        if (finish) {
            finish(error,dic);
        }
    }];
    [task resume];
}
- (void)uploadReport:(CAISReport *)report finish:(void(^)(NSError* error,NSDictionary * response))finish{
    NSString * reportUrl = [NSString stringWithFormat:@"%@/statistic/report",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[report netReport] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * dic = nil;
        if (data) {
             dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        }
        if (finish) {
            finish(error,dic);
        }
    }];
    [task resume];
}


@end
