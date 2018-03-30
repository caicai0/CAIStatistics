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
        [db executeUpdate:sql1];
    }];
}

- (void)saveLog:(CAISDSLog *)log{
    if (log && [log isKindOfClass:[CAISDSLog class]]) {
        [self.queue inTransaction:^(CAISDSFMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            NSString * sql = @"insert into CAISDSPlans (json) values (?)";
            BOOL success = [db executeUpdate:sql,[log jsonString]];
            if (!success) {
                NSLog(@"数据存储失败");
                NSInteger errorCode = [db lastErrorCode];
                if (errorCode == 284) {//index 爆满
                    NSString * sql1 = @"drop table if exists CAISDSPlans";
                    NSString * sql2 = @"create table if not exists CAISDSPlans (id integer primary key autoincrement,json text)";
                    [db executeUpdate:sql1];
                    [db executeUpdate:sql2];
                }
            }
        }];
    }else{
        NSLog(@"log 类型错误");
    }
}

- (void)uploadLogs:(void(^)(NSArray *logs,BOOL residue,void(^finish)(BOOL success)))upload{
    __weak typeof(self)weakSelf = self;
    [self.queue inTransaction:^(CAISDSFMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString * sql = @"select * from CAISDSPlans limit 1000";
        CAISDSFMResultSet * set = [db executeQuery:sql];
        NSMutableArray * keys = [NSMutableArray array];
        NSMutableArray * logs = [NSMutableArray array];
        while ([set next]) {
            NSString * key = [set stringForColumn:@"id"];
            if (key) {
                [keys addObject:key];
            }
            NSString * json = [set stringForColumn:@"json"];
            NSData * data = [json dataUsingEncoding:NSUTF8StringEncoding];
            NSError * error = nil;
            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (object) {
                [logs addObject:object];
            }else{
                if (json) {
                    [logs addObject:json];
                }else if(error){
                    [logs addObject:error.localizedDescription];
                }else{
                    [logs addObject:@"数据读取错误"];
                }
            }
        }
        if (upload) {
            BOOL residue = (logs.count>=1000);
            upload(logs,residue,^(BOOL success){
                if (success) {
                    [weakSelf.queue inTransaction:^(CAISDSFMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                        NSString * deleteSql = @"delete from CAISDSPlans where id = ?";
                        for (NSString * oneKey in keys) {
                            [db executeUpdate:deleteSql,oneKey];
                        }
                    }];
                }
            });
        }
    }];
}

@end
