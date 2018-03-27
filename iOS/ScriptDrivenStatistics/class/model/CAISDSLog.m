//
//  CAISDSLog.m
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISDSLog.h"

@implementation CAISDSLog

- (NSString *)jsonString{
    if (self.plan && self.plan.type == CAISDSPlanTypeLog) {
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
            [dic setObject:self.date forKey:@"date"];
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
