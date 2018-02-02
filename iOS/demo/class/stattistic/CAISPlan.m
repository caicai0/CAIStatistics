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
            NSDictionary *values = dic[@"values"];
            
            if (values && [values isKindOfClass:[NSDictionary class]] && values.count) {
                NSMutableArray * allPath = [NSMutableArray array];
                [values enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if (key && [key isKindOfClass:[NSString class]] && key.length && obj && [obj isKindOfClass:[NSString class]] && [obj length]) {
                        NSString * keypath = obj;
                        CAISKeyPoint * skeyPath = [CAISKeyPoint keyPointForString:keypath];
                        if (skeyPath) {
                            skeyPath.key = key;
                            [allPath addObject:skeyPath];
                        }
                    }else if(key && [key isKindOfClass:[NSString class]] && key.length && obj && [obj isKindOfClass:[NSDictionary class]] && [obj count]){
                        NSDictionary * keyDic= obj;
                        CAISKeyPoint * skeyPath = [CAISKeyPoint keyPointForDictionary:keyDic];
                        if (skeyPath) {
                            skeyPath.key = key;
                            [allPath addObject:skeyPath];
                        }
                    }else{
                        NSLog(@"ERROR %@,%@",key,obj);
                    }
                }];
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
