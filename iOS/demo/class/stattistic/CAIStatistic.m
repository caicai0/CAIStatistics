//
//  CAIStatistic.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAIStatistic.h"
#import "CAISPlan.h"
#import "Aspects.h"
#import "CAISUtils.h"
#import "CAISLocalLogger.h"

@interface CAIStatistic()

@property (nonatomic, assign)NSInteger version; //统计版本默认为0
@property (nonatomic, strong)NSMutableArray<id<AspectToken>> *allAspectToken;
@property (nonatomic, strong)CAISLocalLogger * localLogger;

@end

@implementation CAIStatistic

+ (instancetype)shareStatistic{
    static CAIStatistic * shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[CAIStatistic alloc]init];
    });
    return shareInstance;
}

+ (void)startInLocalPath:(NSString *)path{
    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"Statistic" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [[CAIStatistic shareStatistic]updateFromDictionary:dic];
    [[CAIStatistic shareStatistic]analysisAllPlans];
    [CAIStatistic shareStatistic].localLogger = [CAISLocalLogger loggerInPath:path];
    [[CAIStatistic shareStatistic]updateBaseInfo];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allAspectToken = [NSMutableArray array];
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
        for (id<AspectToken> aspectToken in self.allAspectToken) {
            [aspectToken remove];
            [self.allAspectToken removeObject:aspectToken];
        }
        //开始解析
        __weak typeof(self)weakSelf = self;
        [self.plans enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            CAISPlan * plan = obj;
            Class aclass = NSClassFromString(plan.className);
            SEL selector = NSSelectorFromString(plan.selectorName);
            id<AspectToken> aspectToken = [aclass aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info) {
                [weakSelf handleHook:info plan:plan];
            } error:NULL];
            if (aspectToken) {
                [weakSelf.allAspectToken addObject:aspectToken];
            }
        }];
    }
}

- (void)handleHook:(id<AspectInfo>)info plan:(CAISPlan *)plan{
    if (plan.type == CAISPlanTypeLog) {
        NSLog(@"%ld,%@,%@",plan.type,plan.className,plan.selectorName);
        if (plan.keyPaths && plan.keyPaths.count) {
            for (NSInteger i=0; i<plan.keyPaths.count; i++) {
                CAISKeyPoint * keyPath = plan.keyPaths[i];
                NSString *value = [keyPath stringValueForInfo:info];
                NSLog(@"%@",value);
            }
        }
    }else if(plan.type == CAISPlanTypeCount){
        NSLog(@"%ld,%@,%@",plan.type,plan.className,plan.selectorName);
    }
}

- (void)updateBaseInfo{
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
            [self.localLogger updateBaseInfo:result];
        }
    }
}

@end
