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

#define CACHE_DIRECTORY srps
#define PLIST_FILE_NAME srps.plist

@interface CAISDS() <CAISDSStatisticDelegate>

@property (strong, nonatomic)CAISDSLocalStore * localStore;

@end

@implementation CAISDS

+ (void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        [self prepareStore];
    }
    return self;
}

- (void)prepareStore{
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString * dbPath = [cachePath stringByAppendingPathComponent:@"caisds.sqlite"];
    NSLog(@"%@",dbPath);
    self.localStore = [[CAISDSLocalStore alloc]initWithDbPath:dbPath];
}

- (void)start{
    NSError * error = nil;
    NSString * baseUrlString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/tagflag/scriptServer/master/serverList"] encoding:NSUTF8StringEncoding error:&error];
    baseUrlString = [baseUrlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
            NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString * plistPath = [cachePath stringByAppendingPathComponent:@"srps.plist"];
            [weakSelf statisticLoad:plistPath];
        }
    }];
    
}

- (void)updateLocalPlistFinish:(void(^)(NSError * error))finish{
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString * plistPath = [cachePath stringByAppendingPathComponent:@"srps.plist"];
    BOOL isDirectory = NO;
    NSString * localVersion = nil;
    if ([[NSFileManager defaultManager]fileExistsAtPath:plistPath isDirectory:&isDirectory] && !isDirectory) {
        NSDictionary * plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        if (plist) {
            id version = [plist objectForKey:@"version"];
            if (version && [version isKindOfClass:[NSNumber class]]) {
                NSNumber * versionNuber = version;
                if ([versionNuber integerValue]) {
                    localVersion = [NSString stringWithFormat:@"%ld",[versionNuber integerValue]];
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
}

@end