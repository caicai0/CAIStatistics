//
//  CAISPlan.h
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISType.h"
#import "CAISKeyPoint.h"

@interface CAISPlan : NSObject

@property (strong, nonatomic)NSString * planId;
@property (assign, nonatomic)CAISPlanType type;
@property (strong, nonatomic)NSString * className;
@property (strong, nonatomic)NSString * selectorName;
@property (strong, nonatomic)NSDictionary * keyPoints;
@property (strong, nonatomic)NSArray<CAISKeyPoint*> * keyPaths;

+ (instancetype)planForDictionary:(NSDictionary *)dic;

@end
