//
//  CAISDSNet.m
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISDSNet.h"
#import <UIKit/UIKit.h>
#import "CAISDSUtils.h"
#import "CAISDSOpenUDID.h"

@interface CAISDSNet()

@property (strong, nonatomic)NSDictionary * baseInfo;
@property (strong, nonatomic)NSString * openUDID;
@property (strong, nonatomic)NSString * UUID;

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
        self.baseUrlString = @"http://localhost:63010";
        self.openUDID = [CAISDSOpenUDID value];
        self.UUID = [NSUUID UUID].UUIDString;
        [self makeBaseInfo];
    }
    return self;
}

- (void)makeBaseInfo{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    if (self.openUDID) {
        [dic setObject:self.openUDID forKey:@"openUDID"];
    }
    if (self.UUID) {
        [dic setObject:self.UUID forKey:@"UUID"];
    }
    UIDevice * device = [UIDevice currentDevice];
    [dic setObject:device.model forKey:@"model"];
    [dic setObject:device.systemVersion forKey:@"systemVersion"];
    
    NSDictionary *info = [[NSBundle mainBundle]infoDictionary];
    [dic setObject:info[@"CFBundleIdentifier"] forKey:@"CFBundleIdentifier"];
//    [dic setObject:info[@"CFBundleName"] forKey:@"CFBundleName"];
//    [dic setObject:info[@"CFBundleShortVersionString"] forKey:@"CFBundleShortVersionString"];
//    [dic setObject:info[@"CFBundleVersion"] forKey:@"CFBundleVersion"];
    
    self.baseInfo = [NSDictionary dictionaryWithDictionary:dic];
}

- (void)fixHeaderForRequest:(NSMutableURLRequest *)request{
    request.allHTTPHeaderFields = self.baseInfo;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
}

- (void)loadPlistFileVersion:(NSString *)version Finish:(void(^)(NSError* error,NSDictionary * response))finish{
    NSString * reportUrl = [NSString stringWithFormat:@"%@/app/download",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [self fixHeaderForRequest:request];
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
    NSString * reportUrl = [NSString stringWithFormat:@"%@/app/report",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [self fixHeaderForRequest:request];
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
