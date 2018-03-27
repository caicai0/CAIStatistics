//
//  CAISDSLog.h
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISDSPlan.h"

@interface CAISDSLog : NSObject

@property (strong, nonatomic)CAISDSPlan * plan;
@property (strong, nonatomic)NSArray * values;//可选
@property (assign, nonatomic)long long number;
@property (strong, nonatomic)NSDate * date;//时间

- (NSString *)jsonString;

@end
