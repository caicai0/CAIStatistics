//
//  SRPS.m
//  demo
//
//  Created by caicai on 2018/3/26.
//  Copyright © 2018年 李玉峰. All rights reserved.
//

#import "CAISDS.h"
#import "CAISDSNet.h"
#import "CAISDSStatistic.h"
#import "CAISDSLocalStore.h"
#import "CAISDSUtils.h"
#import "CAISDSStatisticDelegate.h"
#import "CAISDSReport.h"
#import "CAISDSOpenUDID.h"

#define CACHE_DIRECTORY srps
#define PLIST_FILE_NAME srps.plist

@interface CAISDS() <CAISDSStatisticDelegate>

@property (strong, nonatomic)CAISDSLocalStore * localStore;
@property (strong, nonatomic)NSDate * uploadStartTime;
@property (assign, nonatomic)BOOL isUploading;

@end

@implementation CAISDS

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_MSEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[CAISDS share]start];
    });
}

+ (instancetype)share{
    static CAISDS * share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[CAISDS alloc]init];
    });
    return share;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.uploadStartTime = [NSDate date];
        [self prepareStore];
    }
    return self;
}

- (void)prepareStore{
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString * dbPath = [cachePath stringByAppendingPathComponent:@"caisds.sqlite"];
    self.localStore = [[CAISDSLocalStore alloc]initWithDbPath:dbPath];
}

- (NSString *)plistPath{
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString * plistPath = [cachePath stringByAppendingPathComponent:@"srps.plist"];
    return plistPath;
}

- (void)start{
    //先加载本地的文件
    [self statisticLoad:[self plistPath]];
    
    NSError * error = nil;
    NSString * remoteUrl = @"https://raw.githubusercontent.com/tagflag/scriptServer/master/release";
#ifdef DEBUG
    remoteUrl = @"https://raw.githubusercontent.com/tagflag/scriptServer/master/debug";
#endif
    NSString * baseUrlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:remoteUrl] encoding:NSUTF8StringEncoding error:&error];
    baseUrlString = [baseUrlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (baseUrlString && baseUrlString.length) {
        [CAISDSNet net].baseUrlString = baseUrlString;
        if (error) {
            [self performSelector:@selector(start) withObject:nil afterDelay:300];
            return;
        }
        __weak typeof(self) weakSelf = self;
        [self updateLocalPlistFinish:^(NSError *error) {
            if (error) {
                NSLog(@"%@",error);
            }else{
                [weakSelf statisticLoad:[weakSelf plistPath]];
            }
        }];
    }
}

- (void)updateLocalPlistFinish:(void(^)(NSError * error))finish{
    NSString * plistPath = [self plistPath];
    BOOL isDirectory = NO;
    NSString * localVersion = nil;
    if ([[NSFileManager defaultManager]fileExistsAtPath:plistPath isDirectory:&isDirectory] && !isDirectory) {
        NSDictionary * plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (plist) {
            id version = [plist objectForKey:@"version"];
            if (version && [version isKindOfClass:[NSNumber class]]) {
                NSNumber * versionNuber = version;
                if ([versionNuber integerValue]) {
                    localVersion = [NSString stringWithFormat:@"%ld",(long)[versionNuber integerValue]];
                }
            }else if (version && [version isKindOfClass:[NSString class]]){
                NSString * versionString = version;
                if (versionString.length) {
                    localVersion = versionString;
                }
            }
        }
    }
    [[CAISDSNet net]loadPlistFileVersion:localVersion Finish:^(NSError *error, NSDictionary *response) {
        if (response && [response isKindOfClass:[NSDictionary class]]) {
            NSNumber * code = response[@"code"];
            if (code && ![code integerValue]) {
                NSString *plistString = response[@"plist"];
                if (plistString && [plistString isKindOfClass:[NSString class]] && plistString.length) {
                    NSError * fileWriteError = nil;
                    [CAISDSUtils createFilePath:plistPath];
                    [plistString writeToFile:plistPath atomically:YES encoding:NSUTF8StringEncoding error:&fileWriteError];
                    if (fileWriteError) {
                        error = fileWriteError;
                    }
                }else{
                    error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
                }
            }else{
                error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
            }
        }else{
            error = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo:nil];
        }
        if (finish) {
            finish(error);
        }
    }];
}

- (void)statisticLoad:(NSString *)plistPath{
    [[CAISDSStatistic shareStatistic]loadPlistPath:plistPath];
    [CAISDSStatistic shareStatistic].delegate = self;
}

#pragma mark - CAISDSStatisticDelegate

- (void)onReceiveLog:(CAISDSLog *)log{
    [self.localStore saveLog:log];
    [self uploadRecords];
}

- (void)uploadRecords{
    if ([self shouldUpload] && !self.isUploading) {
        __weak typeof(self)weakSelf = self;
        self.isUploading = YES;
        [self.localStore uploadLogs:^(NSArray *logs,BOOL residue, void (^finish)(BOOL success)) {
            CAISDSReport * report = [[CAISDSReport alloc]init];
            report.planVersion = [CAISDSStatistic shareStatistic].version;
            report.planFileMd5 = [CAISDSStatistic shareStatistic].planFileMd5;
            report.baseInfo = [CAISDSStatistic shareStatistic].baseInfo;
            report.logs = logs;
            if (!residue) {
                weakSelf.uploadStartTime = [NSDate date];
            }
            [[CAISDSNet net]uploadReport:report finish:^(NSError *error, NSDictionary *response) {
                if (!error && response && [response isKindOfClass:[NSDictionary class]]) {
                    NSNumber * code = response[@"code"];
                    if (code && [code isKindOfClass:[NSNumber class]]) {
                        if ([code integerValue]==0) {
                            
                        }else if ([code integerValue]==1) {
                            [weakSelf start];
                        }
                        if (finish) {
                            finish(YES);
                        }
                    }
                    weakSelf.isUploading = NO;
                }
            }];
        }];
    }
}

- (BOOL)shouldUpload{
    NSDate * now = [NSDate date];
    NSTimeInterval time = [now timeIntervalSinceDate:self.uploadStartTime];
    return time>60;
}

@end
