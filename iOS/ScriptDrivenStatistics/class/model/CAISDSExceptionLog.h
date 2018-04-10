//
//  CAISDSExcetionLog.h
//  ScriptDrivenStatistics
//
//  Created by 李玉峰 on 2018/4/9.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import "CAISDSLog.h"

@interface CAISDSExceptionLog : CAISDSLog

@property (nonatomic, strong)NSException * exception;
@property (nonatomic, strong)NSString * path;

@end
