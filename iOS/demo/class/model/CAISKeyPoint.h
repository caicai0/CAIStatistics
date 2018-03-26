//
//  CAISKeyPoint.h
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISType.h"
#import "SRPAspects.h"

@interface CAISKeyPoint : NSObject

@property (strong, nonatomic)NSString * key;//上报用字段
@property (assign, nonatomic)CAISKeyPointType type;

// CAISKeyPointTypeKeyPathString
@property (assign, nonatomic)NSUInteger index;
@property (assign, nonatomic)BOOL hasPath;
@property (strong, nonatomic)NSArray * pathArray;

+ (instancetype)keyPointForString:(NSString *)string;

// CAISKeyPointTypeClassMethode
@property (assign, nonatomic)Class aclass;
@property (assign, nonatomic)SEL selector;
@property (strong, nonatomic)NSString *keyPath;

+ (instancetype)keyPointForDictionary:(NSDictionary *)dic;

//获取结果

- (NSString *)stringValueForInfo:(id<SRPAspectInfo>)info;

@end
