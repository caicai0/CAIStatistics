//
//  CAISPlan.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISPlan.h"

@implementation CAISPlan

+ (instancetype)planForDictionary:(NSDictionary *)dic;{
    if (dic && [dic isKindOfClass:[NSDictionary class]]) {
        NSInteger type = 0;
        NSNumber * typeNumber = dic[@"type"];
        if (typeNumber && [typeNumber isKindOfClass:[NSNumber class]]) {
            type = typeNumber.integerValue;
        }
        NSString * planId = dic[@"planId"];
        NSString * classPath = dic[@"classPath"];
        NSString * selector = dic[@"selector"];
        if (classPath && [classPath isKindOfClass:[NSString class]] && classPath.length
            &&planId && [planId isKindOfClass:[NSString class]] && planId.length
            &&selector && [selector isKindOfClass:[NSString class]] && selector.length) {
            CAISPlan * plan = [[CAISPlan alloc]init];
            plan.type = type;
            plan.planId = planId;
            plan.className = classPath;
            plan.selectorName = selector;
            NSArray *values = dic[@"values"];
            if (values && [values isKindOfClass:[NSArray class]] && values.count) {
                NSMutableArray * allPath = [NSMutableArray array];
                for (NSInteger i=0; i<values.count; i++) {
                    NSString * keypath = values[i];
                    if (keypath && [keypath isKindOfClass:[NSString class]] && keypath.length) {
                        CAISKeyPath * skeyPath = [CAISKeyPath keyPathForString:keypath];
                        if (skeyPath) {
                            [allPath addObject:skeyPath];
                        }
                    }
                }
                if (allPath.count) {
                    plan.keyPaths = [NSArray arrayWithArray:allPath];
                }
            }
            return plan;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

@end
