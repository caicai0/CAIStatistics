//
//  CAISNet.h
//  demo
//
//  Created by 李玉峰 on 2017/12/25.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISReport.h"

@interface CAISNet : NSObject

@property (nonatomic, strong)NSString * baseUrlString;

+ (instancetype)net;

- (void)loadPlistFileVersion:(NSString *)version Finish:(void(^)(NSError* error,NSDictionary * response))finish;
- (void)uploadReport:(CAISReport *)report finish:(void(^)(NSError* error,NSDictionary * response))finish;

@end
