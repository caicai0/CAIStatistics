//
//  CAISReport.m
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISDSReport.h"

@implementation CAISDSReport

- (NSString *)netReport{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    if (self.planVersion) {
        [dic setObject:self.planVersion forKey:@"planVersion"];
    }
    if (self.planFileMd5) {
        [dic setObject:self.planFileMd5 forKey:@"planFileMd5"];
    }
    if (self.deviceId) {
        [dic setObject:self.deviceId forKey:@"deviceId"];
    }
    if (self.baseInfo) {
        [dic setObject:self.baseInfo forKey:@"baseInfo"];
    }
    if (self.logs) {
        [dic setObject:self.logs forKey:@"logs"];
    }
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString * json = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (json && json.length) {
        NSLog(@"%@",json);
        return json;
    }else{
        if (error) {
            return error.localizedDescription;
        }
    }
    return @"数据解析错误";
}

@end
