//
//  CAISDSPlanLog.h
//  ScriptDrivenStatistics
//
//  Created by 李玉峰 on 2018/4/9.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import "CAISDSLog.h"

@interface CAISDSPlanLog : CAISDSLog

@property (strong, nonatomic)CAISDSPlan * plan;
@property (strong, nonatomic)NSArray * values;//可选
@property (assign, nonatomic)long long number;
@property (strong, nonatomic)NSDate * date;//时间

@end
