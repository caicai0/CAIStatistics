//
//  CAISUtils.h
//  demo
//
//  Created by 李玉峰 on 2017/12/27.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAISDSUtils : NSObject

+ (id)objectForClass:(Class)aclass selector:(SEL)selector keyPath:(NSString *)keyPath;
+ (id)objectForInstance:(id)instance keyPath:(NSString *)keyPath;

@end
