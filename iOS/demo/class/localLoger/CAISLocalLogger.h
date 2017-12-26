//
//  CAISLocalLogger.h
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISLog.h"

@interface CAISLocalLogger : NSObject

@property (nonatomic, strong)NSString * path;
@property (nonatomic, strong)NSDate * refreshDate;//刷新时间

+ (instancetype)loggerInPath:(NSString *)path;

- (void)addLog:(CAISLog *)log;//针对不同类型修改sql
- (void)getAllFinish:(void(^)(NSDictionary *dic))finish;

@end
