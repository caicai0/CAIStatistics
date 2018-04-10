//
//  SRPS.h
//  demo
//
//  Created by caicai on 2018/3/26.
//  Copyright © 2018年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAISDS : NSObject

//错误异常记录
+ (void)storageError:(NSError *)error inPath:(NSString *)path;
+ (void)storageException:(NSException *)exception inPath:(NSString *)path;

@end
