//
//  CAISDSStatistic.h
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISDSLog.h"
#import "CAISDSStatisticDelegate.h"

@interface CAISDSStatistic : NSObject

@property (nonatomic, strong)NSDictionary *baseInfos;
@property (nonatomic, strong)NSDictionary *plans;
@property (nonatomic, weak)id<CAISDSStatisticDelegate> delegate;

+ (instancetype)shareStatistic;
- (void)loadPlistPath:(NSString *)plistPath;//加载plist文件
- (void)loadDictionary:(NSDictionary *)dic;//加载解析好的字典

- (NSDictionary *)baseInfo;//获取基本信息

@end
