//
//  CAIStatistic.h
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAIStatistic : NSObject

@property (nonatomic, strong)NSDictionary *baseInfos;
@property (nonatomic, strong)NSDictionary *plans;

+ (instancetype)shareStatistic;
+ (void)startInLocalPath:(NSString *)filePath;

@end
