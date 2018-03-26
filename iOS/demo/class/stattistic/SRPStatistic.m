//
//  SRPStatistic.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "SRPStatistic.h"
#import "CAISPlan.h"
#import "SRPAspects.h"
#import "CAISUtils.h"
#import "CAISLocalLogger.h"

@interface SRPStatistic()

@property (nonatomic, assign)NSInteger version; //统计版本默认为0
@property (nonatomic, strong)NSMutableArray<id<SRPAspectToken>> *allSRPAspectToken;
@property (nonatomic, strong)CAISLocalLogger * localLogger;

@end

@implementation SRPStatistic

+ (instancetype)shareStatistic{
    static SRPStatistic * shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[SRPStatistic alloc]init];
    });
    return shareInstance;
}

- (void)loadPlistPath:(NSString *)plistPath{
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [[SRPStatistic shareStatistic]loadDictionary:dic];
}

- (void)loadDictionary:(NSDictionary *)dic{
    [[SRPStatistic shareStatistic]updateFromDictionary:dic];
    [[SRPStatistic shareStatistic]analysisAllPlans];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allSRPAspectToken = [NSMutableArray array];
    }
    return self;
}

- (void)updateFromDictionary:(NSDictionary *)dic{
    NSNumber * versionNmber = dic[@"version"];
    if (versionNmber && [versionNmber isKindOfClass:[NSNumber class]]) {
        self.version = [versionNmber integerValue];
    }
    //基本统计信息
    NSDictionary * baseInfoDir = dic[@"baseInfo"];
    if (baseInfoDir && [baseInfoDir isKindOfClass:[NSDictionary class]] && baseInfoDir.count) {
        NSMutableDictionary * allPath = [NSMutableDictionary dictionary];
        [baseInfoDir enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (key && [key isKindOfClass:[NSString class]] && key.length && obj && [obj isKindOfClass:[NSString class]] && [obj length]) {
                NSString * keypath = obj;
                CAISKeyPoint * skeyPath = [CAISKeyPoint keyPointForString:keypath];
                if (skeyPath) {
                    skeyPath.key = key;
                    [allPath setObject:skeyPath forKey:key];
                }
            }else if(key && [key isKindOfClass:[NSString class]] && key.length && obj && [obj isKindOfClass:[NSDictionary class]] && [obj count]){
                NSDictionary * keyDic= obj;
                CAISKeyPoint * skeyPath = [CAISKeyPoint keyPointForDictionary:keyDic];
                if (skeyPath) {
                    skeyPath.key = key;
                    [allPath setObject:skeyPath forKey:key];
                }
            }else{
                NSLog(@"ERROR %@,%@",key,obj);
            }
        }];
        self.baseInfos = [NSDictionary dictionaryWithDictionary:allPath];
    }
    //统计计划
    NSArray * plans = dic[@"plans"];
    NSMutableDictionary *allPlans = [NSMutableDictionary dictionary];
    if (plans && [plans isKindOfClass:[NSArray class]] && plans.count) {
        for (NSInteger i=0; i<plans.count; i++) {
            NSDictionary * plan = plans[i];
            CAISPlan * caiPlan = [CAISPlan planForDictionary:plan];
            if (caiPlan && caiPlan.planId) {
                [allPlans setObject:caiPlan forKey:caiPlan.planId];
            }
        }
    }
    self.plans = [NSDictionary dictionaryWithDictionary:allPlans];
}

- (void)analysisAllPlans{
    if (self.plans && self.plans.count) {
        //删除原有的钩子
        for (id<SRPAspectToken> SRPAspectToken in self.allSRPAspectToken) {
            [SRPAspectToken remove];
            [self.allSRPAspectToken removeObject:SRPAspectToken];
        }
        //开始解析
        __weak typeof(self)weakSelf = self;
        [self.plans enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            CAISPlan * plan = obj;
            Class aclass = NSClassFromString(plan.className);
            SEL selector = NSSelectorFromString(plan.selectorName);
            id<SRPAspectToken> SRPAspectToken = [aclass SRPAspect_hookSelector:selector withOptions:SRPAspectPositionAfter usingBlock:^(id<SRPAspectInfo> info) {
                [weakSelf handleHook:info plan:plan];
            } error:NULL];
            if (SRPAspectToken) {
                [weakSelf.allSRPAspectToken addObject:SRPAspectToken];
            }
        }];
    }
}

- (void)handleHook:(id<SRPAspectInfo>)info plan:(CAISPlan *)plan{
    CAISLog * log = [[CAISLog alloc]init];
    log.date = [NSDate date];
    log.plan = plan;
    if (plan.type == CAISPlanTypeLog) {
        NSMutableArray * values = [NSMutableArray array];
        if (plan.keyPaths && plan.keyPaths.count) {
            for (NSInteger i=0; i<plan.keyPaths.count; i++) {
                CAISKeyPoint * keyPath = plan.keyPaths[i];
                NSString *value = [keyPath stringValueForInfo:info];
                if (value) {
                    [values addObject:value];
                }else{
                    [values addObject:@"NULL"];
                }
            }
        }
        log.values = [NSArray arrayWithArray:values];
        
    }else if(plan.type == CAISPlanTypeCount){
        NSLog(@"%ld,%@,%@",plan.type,plan.className,plan.selectorName);
    }else{
        log = nil;
    }
    if (self.hookPlant) {
        self.hookPlant(log);
    }
}

- (NSDictionary *)baseInfo{
    if (self.baseInfos && self.baseInfos.count) {
        NSMutableDictionary * result = [NSMutableDictionary dictionary];
        @try {
            [self.baseInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CAISKeyPoint* _Nonnull obj, BOOL * _Nonnull stop) {
                id object = [obj stringValueForInfo:nil];
                NSString * value = [object description];
                [result setObject:value forKey:key];
            }];
        } @catch (NSException *exception) {
            [result setObject:exception.description forKey:@"exception"];
        } @finally {
            return result;
        }
    }
}

@end
