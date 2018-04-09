//
//  CAISDSPlanLog.m
//  ScriptDrivenStatistics
//
//  Created by 李玉峰 on 2018/4/9.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import "CAISDSPlanLog.h"

@implementation CAISDSPlanLog

- (NSString *)jsonString{
    if (self.plan) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        if (self.plan.version) {
            [dic setObject:self.plan.version forKey:@"version"];
        }
        if (self.plan.planId) {
            [dic setObject:self.plan.planId forKey:@"planId"];
        }
        if (self.values) {
            [dic setObject:self.values forKey:@"values"];
        }
        if (self.date) {
            NSTimeInterval timeStamp = [self.date timeIntervalSince1970];
            [dic setObject:@(timeStamp) forKey:@"date"];
        }
        NSError * error = nil;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if (error) {
            return error.localizedDescription;
        }else{
            NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
            return jsonString;
        }
    }else{
        return @"plan 错误";
    }
}

@end
