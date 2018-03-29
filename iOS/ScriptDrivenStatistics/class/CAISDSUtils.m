//
//  CAISUtils.m
//  demo
//
//  Created by 李玉峰 on 2017/12/27.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#import "CAISDSUtils.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation CAISDSUtils

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

+ (NSString *)urlEncodeString:(NSString *)str{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (__bridge CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
}

+ (void)createFilePath:(NSString *)path{
    if (path && [path isKindOfClass:[NSString class]] && path.length) {
        BOOL isDir = NO;
        if ([[NSFileManager defaultManager]fileExistsAtPath:path isDirectory:&isDir] && !isDir) {
        }else{
            [[NSFileManager defaultManager]createFileAtPath:path contents:nil attributes:nil];
        }
    }
}

+(NSString*)md5ForPath:(NSString*)path
{
    //return (__bridge_transfer NSString*)FileM
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist
    
    CC_MD5_CTX md5;
    
    CC_MD5_Init(&md5);
    
    BOOL done = NO;
    while(!done)
    {
        NSData* fileData = [handle readDataOfLength: 1024 ];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if( [fileData length] == 0 ) done = YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0], digest[1],
                   digest[2], digest[3],
                   digest[4], digest[5],
                   digest[6], digest[7],
                   digest[8], digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    return s;
}

@end
