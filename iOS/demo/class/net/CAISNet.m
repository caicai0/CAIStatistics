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

- (void)uploadReport:(CAISReport *)report finish:(void(^)(BOOL success))finish{
    NSString * reportUrl = [NSString stringWithFormat:@"%@/statistic/report",self.baseUrlString];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString:reportUrl];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[report netReport] dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionTask * task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"%@",[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil]);
    }];
    [task resume];
}

@end
