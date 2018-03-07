//
//  CAISUploader.h
//  demo
//
//  Created by 李玉峰 on 2018/3/5.
//  Copyright © 2018年 李玉峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISType.h"

@interface CAISUploader : NSObject

@property(nonatomic, assign)UploadType * type;
@property(nonatomic, assign)NSTimeInterval *timeInterval;
@property(nonatomic, assign)NSInteger number;

@end
