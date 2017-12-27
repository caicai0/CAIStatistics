//
//  CAISKeyPath.m
//  demo
//
//  Created by 李玉峰 on 2017/12/20.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISKeyPoint.h"
#import "Aspects.h"
#import "CAISUtils.h"

@implementation CAISKeyPoint

+ (instancetype)keyPointForString:(NSString *)string{
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
            CAISKeyPoint * keypath = [[CAISKeyPoint alloc]init];
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

+ (instancetype)keyPointForDictionary:(NSDictionary *)dic{
    NSString * className = [dic objectForKey:@"class"];
    NSString * selectorName = [dic objectForKey:@"selector"];
    if (className && [className isKindOfClass:[NSString class]] && className.length
        && selectorName && [selectorName isKindOfClass:[NSString class]] && selectorName.length) {
        CAISKeyPoint * keypath = [[CAISKeyPoint alloc]init];
        keypath.aclass = NSClassFromString(className);
        keypath.selector = NSSelectorFromString(selectorName);
        NSString * keys = [dic objectForKey:@"keyPath"];
        if (keys && [keys isKindOfClass:[NSString class]] && keys.length) {
            keypath.keyPath = keys;
        }
        return keypath;
    }else{
        return nil;
    }
}

- (NSString *)stringValueForInfo:(id<AspectInfo>)info{
    NSString * result = @"NULL";
    @try {
        if (self.type == CAISKeyPointTypeKeyPathString) {
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
        }else if(self.type == CAISKeyPointTypeClassMethode){
            id object = [CAISUtils objectForClass:self.aclass selector:self.selector keyPath:self.keyPath];
            NSString * description = [object description];
            if (description) {
                result = description;
            }else{
                result = @"ERROR description";
            }
        }else{
            result = @"ERROR CAISKeyPointType";
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
