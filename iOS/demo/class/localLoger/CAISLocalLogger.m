//
//  CAISLocalLogger.m
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISLocalLogger.h"
#import "FMDB.h"
#import "FMDatabaseQueue.h"
#import "CAIStatistic.h"

@interface CAISLocalLogger()

@property (strong, nonatomic)FMDatabaseQueue * queue;

@end

@implementation CAISLocalLogger

+ (instancetype)loggerInPath:(NSString *)path{
    BOOL isDir = NO;
    if (path && [[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDir] && isDir) {
        static CAISLocalLogger * shareLogger;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shareLogger = [[CAISLocalLogger alloc]init];
        });
        return shareLogger;
    }else{
        //
        NSLog(@"错误地址");
        return nil;
    }
}

- (instancetype)initWithPath:(NSString *)path;
{
    self = [super init];
    if (self) {
        NSString * dbpath = [path stringByAppendingPathComponent:@"log.db"];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:dbpath];
        [self createAllTables];
    }
    return self;
}

- (void)createAllTables{
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * sql = @"CREATE TABLE IF NOT EXISTS logger(planId text,time date,values blob)";
        [db executeQuery:sql];
        sql = @"CREATE TABLE IF NOT EXISTS counter(planId text,number int(64))";
        [db executeQuery:sql];
    }];
}

- (void)addLog:(CAISLog *)log{
    if(log && [log isKindOfClass:[CAISLog class]]){
        if (log.plan && [log.plan isKindOfClass:[CAISPlan class]]) {
            if (log.plan.type == CAISPlanTypeLog) {
                [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
                    NSString * sql = @"INSERT INTO logger(planId,time,values) VALUES(?,?,?)";
                    NSData * valuesData = [NSData data];
                    if (log.values) {
                        valuesData = [NSKeyedArchiver archivedDataWithRootObject:log.values];
                    }
                    [db executeQuery:sql,log.plan.planId,log.date,valuesData];
                }];
            }else if(log.plan.type == CAISPlanTypeCount){
                [self.queue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                    NSString * sql = @"select * from counter where planId = ?";
                    FMResultSet * resultSet = [db executeQuery:sql,log.plan.planId];
                    NSUInteger number = 0;
                    if (resultSet.next) {
                        number = [resultSet intForColumn:@"number"];
                        sql = @"update counter set number = ? where planId = ?";
                        [db executeQuery:sql,@(number+1),log.plan.planId];
                    }else{
                        sql = @"INSERT INTO counter(planId,number) VALUES(?,?)";
                        [db executeQuery:sql,log.plan.planId,@(number+1)];
                    }
                }];
            }else{
                NSLog(@"日志缺少对应的类型");
            }
        }else{
            NSLog(@"log.plan == nil");
        }
    }else{
        NSLog(@"log == nil");
    }
}

- (void)getAllFinish:(void(^)(NSDictionary *dic))finish{
    [self.queue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString * sql = @"select * from logger";
        NSDate * now = [NSDate date];
        FMResultSet * result = [db executeQuery:sql];
        NSMutableArray * allLogs = [NSMutableArray array];
        while ([result next]) {
            NSString * planId = [result stringForColumn:@"planId"];
            NSDate * date = [result dateForColumn:@"time"];
            NSData * values = [result dataForColumn:@"values"];
            if (planId && date ) {
                CAISLog * log = [[CAISLog alloc]init];
                log.plan = [CAIStatistic shareStatistic].plans[planId];
                log.date = date;
                if (values) {
                    log.values = [NSKeyedUnarchiver unarchiveObjectWithData:values];
                }
                [allLogs addObject:log];
            }
        }
        
        sql = @"select * from counter";
        result = [db executeQuery:sql];
        NSMutableArray * allCounters = [NSMutableArray array];
        while ([result next]) {
            NSString * planId = [result stringForColumn:@"planId"];
            long long number = [result longLongIntForColumn:@"number"];
            if (planId) {
                CAISLog * log = [[CAISLog alloc]init];
                log.plan = [CAIStatistic shareStatistic].plans[planId];
                log.number = number;
                [allCounters addObject:log];
            }
        }
        
        if(finish){
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:allLogs forKey:@"log"];
            [dic setObject:allCounters forKey:@"count"];
            [dic setObject:now forKey:@"now"];
            dispatch_async(dispatch_get_main_queue(), ^{
                finish(dic);
            });
        }
    }];
}

@end
