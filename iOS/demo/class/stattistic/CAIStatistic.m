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

@interface CAIStatistic()

@property (nonatomic, assign)NSInteger version; //统计版本默认为0
@property (nonatomic, strong)NSMutableArray<id<AspectToken>> *allAspectToken;

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

+ (void)start{
    NSString * filePath = [[NSBundle mainBundle]pathForResource:@"Statistic" ofType:@"plist"];
    NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    [[CAIStatistic shareStatistic]updatePlansFromDictionary:dic];
    [[CAIStatistic shareStatistic]analysisAllPlans];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allAspectToken = [NSMutableArray array];
    }
    return self;
}

- (void)updatePlansFromDictionary:(NSDictionary *)dic{
    NSNumber * versionNmber = dic[@"version"];
    if (versionNmber && [versionNmber isKindOfClass:[NSNumber class]]) {
        self.version = [versionNmber integerValue];
    }
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
                CAISKeyPath * keyPath = plan.keyPaths[i];
                NSString *value = [keyPath stringValueForInfo:info];
                NSLog(@"%@",value);
            }
        }
    }else if(plan.type == CAISPlanTypeCount){
        NSLog(@"%ld,%@,%@",plan.type,plan.className,plan.selectorName);
    }
}

@end
