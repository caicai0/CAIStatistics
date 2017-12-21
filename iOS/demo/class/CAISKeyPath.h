//
//  CAISKeyPath.h
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aspects.h"

@interface CAISKeyPath : NSObject

@property (assign, nonatomic)NSUInteger index;
@property (assign, nonatomic)BOOL hasPath;
@property (strong, nonatomic)NSArray * pathArray;

+ (instancetype)keyPathForString:(NSString *)string;
- (NSString *)stringValueForInfo:(id<AspectInfo>)info;

@end
