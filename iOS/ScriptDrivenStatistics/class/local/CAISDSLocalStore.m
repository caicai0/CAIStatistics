//
//  CAISDSLocalStore.m
//  ScriptDrivenStatistics
//
//  Created by caicai on 2018/3/27.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import "CAISDSLocalStore.h"
#import "CAISDSFMDB.h"

@interface CAISDSLocalStore()

@property (nonatomic, strong)CAISDSFMDatabaseQueue * queue;

@end

@implementation CAISDSLocalStore

- (instancetype)initWithDbPath:(NSString *)dbPath
{
    self = [super init];
    if (self) {
        self.queue = [CAISDSFMDatabaseQueue databaseQueueWithPath:dbPath];
        [self createTables];
    }
    return self;
}

- (void)createTables{
    [self.queue inTransaction:^(CAISDSFMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString * sql1 = @"create table if not exists CAISDSPlans (id integer primary key autoincrement,json text)";
        NSString * sql2 = @"create table if not exists CAISDSPlanCount (id integer primary key autoincrement,version text,plantId text,timeStemp int(128))";
        [db executeUpdate:sql1];
        [db executeUpdate:sql2];
    }];
}

- (void)saveLog:(CAISDSLog *)log{
    if (!log) {
        return;
    }
    if (log.plan.type == CAISDSPlanTypeLog) {
        [self saveLogTypeLog:log];
    }else if(log.plan.type == CAISDSPlanTypeCount){
        [self saveCounterTypeLog:log];
    }else{
        NSLog(@"新类型的log");
    }
}

- (void)saveLogTypeLog:(CAISDSLog *)log {
    if (log && (log.plan.type == CAISDSPlanTypeLog)) {
        
    }else{
        NSLog(@"log 类型错误");
    }
}

- (void)saveCounterTypeLog:(CAISDSLog *)log {
    if (log && (log.plan.type == CAISDSPlanTypeCount)) {
        
    }else{
        NSLog(@"log 类型错误");
    }
}



@end
