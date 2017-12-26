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
@property (strong, nonatomic)NSArray * logs;
@property (strong, nonatomic)NSDate * createDate;

- (NSString *)netReport;

@end
