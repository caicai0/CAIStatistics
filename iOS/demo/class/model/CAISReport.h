//
//  CAISReport.h
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAISReport : NSObject

@property (strong, nonatomic)NSString * planVersion;
@property (strong, nonatomic)NSString * planFileMd5;
@property (strong, nonatomic)NSString * deviceId;
@property (strong, nonatomic)NSDictionary * baseInfo;
@property (strong, nonatomic)NSArray * logs;
@property (strong, nonatomic)NSDate * createDate;
@property (strong, nonatomic)NSDictionary * userInfo;//用户自定义数据

- (NSString *)netReport;

@end
