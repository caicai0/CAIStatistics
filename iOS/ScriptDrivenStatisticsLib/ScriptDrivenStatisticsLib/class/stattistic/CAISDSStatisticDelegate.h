//
//  CAISDSStatisticDelegate.h
//  ScriptDrivenStatistics
//
//  Created by caicai on 2018/3/27.
//  Copyright © 2018年 caicai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CAISDSLog.h"

@protocol CAISDSStatisticDelegate <NSObject>

- (void)onReceiveLog:(CAISDSLog *)log;

@end
