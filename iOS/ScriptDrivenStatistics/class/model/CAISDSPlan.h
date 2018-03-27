//
//  CAISDSPlan.h
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISDSType.h"
#import "CAISDSKeyPoint.h"

@interface CAISDSPlan : NSObject

@property (strong, nonatomic)NSString * version;//版本号 所在脚本的版本号
@property (strong, nonatomic)NSString * planId;
@property (assign, nonatomic)CAISDSPlanType type;
@property (strong, nonatomic)NSString * className;
@property (strong, nonatomic)NSString * selectorName;
@property (strong, nonatomic)NSDictionary * keyPoints;
@property (strong, nonatomic)NSArray<CAISDSKeyPoint*> * keyPaths;

+ (instancetype)planForDictionary:(NSDictionary *)dic;

@end
