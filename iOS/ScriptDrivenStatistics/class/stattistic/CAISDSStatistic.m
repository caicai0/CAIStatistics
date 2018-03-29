//
//  CAISDSStatistic.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISDSStatistic.h"
#import "CAISDSPlan.h"
#import "CAISDSAspects.h"
#import "CAISDSUtils.h"

@interface CAISDSStatistic()

@property (nonatomic, strong)NSMutableArray<id<CAISDSAspectToken>> *allCAISDSAspectToken;

@end

@implementation CAISDSStatistic

+ (instancetype)shareStatistic{
    static CAISDSStatistic * shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[CAISDSStatistic alloc]init];
    });
    return shareInstance;
}

- (void)loadPlistPath:(NSString *)plistPath{
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    [[CAISDSStatistic shareStatistic]loadDictionary:dic];
}

- (void)loadDictionary:(NSDictionary *)dic{
    [[CAISDSStatistic shareStatistic]updateFromDictionary:dic];
    [[CAISDSStatistic shareStatistic]analysisAllPlans];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allCAISDSAspectToken = [NSMutableArray array];
    }
    return self;
}

- (void)updateFromDictionary:(NSDictionary *)dic{
    id version = dic[@"version"];
    if (version && [version isKindOfClass:[NSNumber class]]) {
        NSNumber * versionNumber = version;
        self.version = versionNumber.stringValue;
    }else if(version && [version isKindOfClass:[NSString class]] && ((NSString*)version).length){
        NSString * versionString = version;
        self.version = versionString;
    }else{
        self.version = @"";
    }
    //基本统计信息
    NSDictionary * baseInfoDir = dic[@"baseInfo"];
    if (baseInfoDir && [baseInfoDir isKindOfClass:[NSDictionary class]] && baseInfoDir.count) {
        NSMutableDictionary * allPath = [NSMutableDictionary dictionary];
        [baseInfoDir enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (key && [key isKindOfClass:[NSString class]] && key.length && obj && [obj isKindOfClass:[NSString class]] && [obj length]) {
                NSString * keypath = obj;
                CAISDSKeyPoint * skeyPath = [CAISDSKeyPoint keyPointForString:keypath];
                if (skeyPath) {
                    skeyPath.key = key;
                    [allPath setObject:skeyPath forKey:key];
                }
            }else if(key && [key isKindOfClass:[NSString class]] && key.length && obj && [obj isKindOfClass:[NSDictionary class]] && [obj count]){
                NSDictionary * keyDic= obj;
                CAISDSKeyPoint * skeyPath = [CAISDSKeyPoint keyPointForDictionary:keyDic];
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
            CAISDSPlan * caiPlan = [CAISDSPlan planForDictionary:plan];
            caiPlan.version = self.version;
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
        for (id<CAISDSAspectToken> CAISDSAspectToken in self.allCAISDSAspectToken) {
            [CAISDSAspectToken remove];
            [self.allCAISDSAspectToken removeObject:CAISDSAspectToken];
        }
        //开始解析
        __weak typeof(self)weakSelf = self;
        [self.plans enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            CAISDSPlan * plan = obj;
            Class aclass = NSClassFromString(plan.className);
            SEL selector = NSSelectorFromString(plan.selectorName);
            id<CAISDSAspectToken> CAISDSAspectToken = [aclass CAISDSAspect_hookSelector:selector withOptions:CAISDSAspectPositionAfter usingBlock:^(id<CAISDSAspectInfo> info) {
                [weakSelf handleHook:info plan:plan];
            } error:NULL];
            if (CAISDSAspectToken) {
                [weakSelf.allCAISDSAspectToken addObject:CAISDSAspectToken];
            }
        }];
    }
}

- (void)handleHook:(id<CAISDSAspectInfo>)info plan:(CAISDSPlan *)plan{
    CAISDSLog * log = [[CAISDSLog alloc]init];
    log.date = [NSDate date];
    log.plan = plan;
    if (plan.type == CAISDSPlanTypeLog) {
        NSMutableArray * values = [NSMutableArray array];
        if (plan.keyPaths && plan.keyPaths.count) {
            for (NSInteger i=0; i<plan.keyPaths.count; i++) {
                CAISDSKeyPoint * keyPath = plan.keyPaths[i];
                NSString *value = [keyPath stringValueForInfo:info];
                if (value) {
                    [values addObject:value];
                }else{
                    [values addObject:@"NULL"];
                }
            }
        }
        log.values = [NSArray arrayWithArray:values];
        
    }else if(plan.type == CAISDSPlanTypeCount){
        log.number = 1;
    }else{
        log = nil;
    }
    if (self.delegate && [self.delegate conformsToProtocol:@protocol(CAISDSStatisticDelegate)] && [self.delegate respondsToSelector:@selector(onReceiveLog:)]) {
        [self.delegate onReceiveLog:log];
    }
}

- (NSDictionary *)baseInfo{
    if (self.baseInfos && self.baseInfos.count) {
        NSMutableDictionary * result = [NSMutableDictionary dictionary];
        @try {
            [self.baseInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CAISDSKeyPoint* _Nonnull obj, BOOL * _Nonnull stop) {
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
