//
//  CAISType.h
//  demo
//
//  Created by 李玉峰 on 2017/12/21.
//  Copyright © 2017年 李玉峰. All rights reserved.
//

#ifndef CAISType_h
#define CAISType_h

typedef NS_ENUM(NSUInteger, CAISPlanType) {
    CAISPlanTypeLog,
    CAISPlanTypeCount
};

typedef NS_ENUM(NSUInteger, CAISKeyPointType) {
    CAISKeyPointTypeKeyPathString,
    CAISKeyPointTypeClassMethode
};

typedef NS_ENUM(NSUInteger, UploadType) {
    UploadTypeRealTime,//实时上传 默认
    UploadTypeTime,//定时上传
    UploadTypeNumber,//计数上传
};

#endif /* CAISType_h */
