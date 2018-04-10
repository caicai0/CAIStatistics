//
//  CAISDSErrorLog.m
//  ScriptDrivenStatistics
//
//  Created by 李玉峰 on 2018/4/9.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import "CAISDSErrorLog.h"
#import "CAISDS.h"
#import "CAISDSType.h"

@implementation CAISDSErrorLog

- (NSString *)jsonString{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    if (self.error) {
        [dic setObject:self.error.localizedDescription forKey:@"error"];
    }
    if (self.path) {
        [dic setObject:self.path forKey:@"path"];
    }
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        [CAISDS storageError:error inPath:CURRENT_PATH];
        return error.localizedDescription;
    }else{
        NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        return jsonString;
    }
}

@end
