//
//  CAISType.h
//  demo
//
//  Created by 李玉峰 on 2017/12/21.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#ifndef CAISType_h
#define CAISType_h

#define SDSVersion @"1.0"

#define CURRENT_PATH [NSString stringWithFormat:@"%s,%s,%d",__FILE__,__FUNCTION__,__LINE__]
#define NSLog(...){}

typedef NS_ENUM(NSUInteger, CAISDSPlanType) {
    CAISDSPlanTypeLog,
    CAISDSPlanTypeCount
};

typedef NS_ENUM(NSUInteger, CAISDSKeyPointType) {
    CAISKeyPointTypeKeyPathString,
    CAISKeyPointTypeClassMethode
};

typedef NS_ENUM(NSUInteger, UploadType) {
    UploadTypeRealTime,//实时上传 默认
    UploadTypeTime,//定时上传
    UploadTypeNumber,//计数上传
};

#endif /* CAISType_h */
