//
//  CAISUtils.m
//  demo
//
//  Created by 李玉峰 on 2017/12/27.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISUtils.h"
#import <objc/runtime.h>

@implementation CAISUtils

+ (id)objectForClass:(Class)aclass selector:(SEL)selector keyPath:(NSString *)keyPath{
    id result = nil;
    @try {
        if (aclass && selector && [aclass respondsToSelector:selector]) {
            NSMethodSignature *signature = [aclass methodSignatureForSelector:selector];
            NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.target = aclass;
            invocation.selector = selector;
            [invocation invoke];
            id returnVal;
            if (strcmp(signature.methodReturnType, "@") == 0) {
                void * returnPoint;
                [invocation getReturnValue:&returnPoint];
                NSString * selectorName = NSStringFromSelector(selector);
                //下面的代码拷贝自JSPath
                if ([selectorName isEqualToString:@"alloc"] || [selectorName isEqualToString:@"new"] ||
                    [selectorName isEqualToString:@"copy"] || [selectorName isEqualToString:@"mutableCopy"]) {
                    returnVal = (__bridge_transfer id)returnPoint;
                } else {
                    returnVal = (__bridge id)returnPoint;
                }
            }
            if (returnVal) {
                result = [self objectForInstance:returnVal keyPath:keyPath];
            }
        }
    } @catch (NSException *exception) {
        result = exception;
    } @finally {
        return result;
    }
}

+ (id)objectForInstance:(id)instance keyPath:(NSString *)keyPath{
    id result = nil;
    @try {
        if (instance) {
            if (keyPath && [keyPath isKindOfClass:[NSString class]] && keyPath.length) {
                id object = instance;
                NSArray *keyStrings = [keyPath componentsSeparatedByString:@"."];
                for (NSInteger i =0 ;i<keyStrings.count; i++) {
                    NSString * key = keyStrings[i];
                    object = [object valueForKey:key];
                }
                result = object;
            }else{
                result = instance;
            }
        }
    } @catch (NSException *exception) {
        result = exception;
    } @finally {
        return result;
    }
}

@end
