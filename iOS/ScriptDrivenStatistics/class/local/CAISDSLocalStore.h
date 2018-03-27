//
//  CAISDSLocalStore.h
//  ScriptDrivenStatistics
//
//  Created by caicai on 2018/3/27.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISDSLog.h"

@interface CAISDSLocalStore : NSObject

- (instancetype)initWithDbPath:(NSString *)dbPath;

//存储类方法  log 会相应提取关键信息Json化存储  或是计数统计叠加
- (void)saveLog:(CAISDSLog *)log;

- (void)uploadLogs:(BOOL(^)(NSArray *logs))upload;

@end
