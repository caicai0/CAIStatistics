//
//  CAISRecorder.m
//  demo
//
//  Created by 李玉峰 on 2018/3/6.
//  Copyright © 2018年 李玉峰. All rights reserved.
//

#import "CAISRecorder.h"
#import "CAISLocalLogger.h"
#import "CAISUploader.h"

@interface CAISRecorder()

@property (nonatomic, strong) CAISUploader * uploader;
@property (nonatomic, strong) CAISLocalLogger * localLogger;

@end

@implementation CAISRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.uploader = [[CAISUploader alloc]init];
        self.localLogger = [[CAISLocalLogger alloc]init];
    }
    return self;
}

- (void)recordOneLog:(CAISLog *)log{
    
}

@end
