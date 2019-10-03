//
//  RAPhotosAPI.h
//  Ride
//
//  Created by Kitos on 16/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseAPI.h"

typedef void (^RAPhotoUploadProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void (^RAphotoUploadCompleteBlock)(NSString* photoUrl, NSError *error);

@interface RAPhotosAPI : RABaseAPI

+ (void)uploadPhoto:(UIImage*)photo progress:(RAPhotoUploadProgressBlock)progress completion:(RAphotoUploadCompleteBlock)completion;
+ (void)uploadPhoto:(UIImage*)photo errorDomain:(ERDomain)errorDomain progress:(RAPhotoUploadProgressBlock)progress completion:(RAphotoUploadCompleteBlock)completion;

@end
