//
//  RAMultipartRequest.h
//  Ride
//
//  Created by Kitos on 5/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RARequest.h"

@protocol AFMultipartFormData;

typedef void (^UploadProgressBlock)(NSProgress *uploadProgress);
typedef void (^MultipartBodyBlock)(id <AFMultipartFormData> formData);

@interface RAMultipartRequest : RARequest

@property (nonatomic, copy) UploadProgressBlock upload; // Default: nil, not used now.
@property (nonatomic, copy) MultipartBodyBlock body;    // Default: nil

+ (RAMultipartRequest*)multipartRequestWithPath:(NSString*)path parameters:(NSDictionary<NSString*,id>*)parameters errorDomain:(ERDomain)errorDomain body:(MultipartBodyBlock)body success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure;

@end
