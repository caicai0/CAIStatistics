//
//  CAISLog.h
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISPlan.h"

@interface CAISLog : NSObject

@property (strong, nonatomic)CAISPlan * plan;
@property (strong, nonatomic)NSArray * values;//可选
@property (assign, nonatomic)long long number;
@property (strong, nonatomic)NSDate * date;//时间

@end
