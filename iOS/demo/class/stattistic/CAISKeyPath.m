//
//  CAISKeyPath.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISKeyPath.h"
#import "Aspects.h"

@implementation CAISKeyPath

+ (instancetype)keyPathForString:(NSString *)string{
    if (string && [string isKindOfClass:[NSString class]] && string.length) {
        NSArray *keyStrings = [string componentsSeparatedByString:@"."];
        BOOL hasError = NO;
        NSUInteger index = 0;
        NSMutableArray * paths = [NSMutableArray array];
        for (NSInteger i=0; i<keyStrings.count; i++) {
            if (i==0) {
                NSString *indexString = keyStrings[i];
                index = [indexString integerValue];
            }else{
                NSString *keyName = keyStrings[i];
                if (keyName && keyName.length) {
                    [paths addObject:keyName];
                }else{
                    hasError = YES;
                    break;
                }
            }
        }
        if (!hasError) {
            CAISKeyPath * keypath = [[CAISKeyPath alloc]init];
            keypath.index = index;
            keypath.hasPath = (paths.count>0);
            keypath.pathArray = [NSArray arrayWithArray:paths];
            return keypath;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

- (NSString *)stringValueForInfo:(id<AspectInfo>)info{
    NSString * result = @"NULL";
    @try {
        if (info && [info conformsToProtocol:@protocol(AspectInfo)]) {
            id instance = [info instance];
            NSArray * arguments = [info arguments];
            if (self.index<arguments.count+1) {
                id object = nil;
                if (self.index == 0) {
                    object = instance;
                }else{
                    object = arguments[self.index-1];
                }
                if (object) {
                    if (self.hasPath && self.pathArray && self.pathArray.count) {
                        for (NSInteger i=0; i<self.pathArray.count; i++) {
                            NSString * key = self.pathArray[i];
                            object = [object valueForKey:key];
                        }
                    }
                    NSString * description = [object description];
                    if (description) {
                        result = description;
                    }else{
                        result = @"ERROR description";
                    }
                }else{
                    result = @"ERROR object";
                }
            }else{
                result = @"ERROR index";
            }
        }else{
            result = @"ERROR instances";
        }
    } @catch (NSException *exception) {
        if (exception.description) {
            result = exception.description;
        }else{
            result = @"ERROR exception.description";
        }
    } @finally {
        
    }
    return result;
}

@end
