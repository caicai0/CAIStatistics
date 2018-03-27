//
//  CAISDSNet.m
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISDSNet.h"
#import <UIKit/UIKit.h>

@interface CAISDSNet()

@property (strong, nonatomic)NSDictionary * baseInfo;

@end

@implementation CAISDSNet

+ (instancetype)net{
    static CAISDSNet * shareNet ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareNet = [[CAISDSNet alloc]init];
    });
    return shareNet;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self makeBaseInfo];
    }
    return self;
}

- (void)makeBaseInfo{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    UIDevice * device = [UIDevice currentDevice];
    [dic setObject:device.model forKey:@"model"];
    [dic setObject:device.systemVersion forKey:@"systemVersion"];
    
    NSDictionary *info = [[NSBundle mainBundle]infoDictionary];
    [dic setObject:info[@"CFBundleIdentifier"] forKey:@"CFBundleIdentifier"];
    [dic setObject:info[@"CFBundleName"] forKey:@"CFBundleName"];
    [dic setObject:info[@"CFBundleShortVersionString"] forKey:@"CFBundleShortVersionString"];
    [dic setObject:info[@"CFBundleVersion"] forKey:@"CFBundleVersion"];
    
    self.baseInfo = [NSDictionary dictionaryWithDictionary:dic];
}

- (void)loadPlistFileVersion:(NSString *)version Finish:(void(^)(NSError* error,NSDictionary * response))finish{
    NSString * reportUrl = [NSString stringWithFormat:@"%@/statistic/download",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.allHTTPHeaderFields = self.baseInfo;
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
- (void)uploadReport:(CAISDSReport *)report finish:(void(^)(NSError* error,NSDictionary * response))finish{
    NSString * reportUrl = [NSString stringWithFormat:@"%@/statistic/report",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[report netReport] dataUsingEncoding:NSUTF8StringEncoding];
    request.allHTTPHeaderFields = self.baseInfo;
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
