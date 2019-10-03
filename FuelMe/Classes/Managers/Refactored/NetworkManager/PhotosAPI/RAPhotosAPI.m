//
//  RAPhotosAPI.m
//  Ride
//
//  Created by Kitos on 16/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPhotosAPI.h"



@implementation RAPhotosAPI

+ (void)uploadPhoto:(UIImage *)photo progress:(RAPhotoUploadProgressBlock)progress completion:(RAphotoUploadCompleteBlock)completion {
    [self uploadPhoto:photo errorDomain:UnspecifiedDomain progress:progress completion:completion];
}

+ (void)uploadPhoto:(UIImage *)photo errorDomain:(ERDomain)errorDomain progress:(RAPhotoUploadProgressBlock)progress completion:(RAphotoUploadCompleteBlock)completion {
    if (photo) {
        NSData *imageData = UIImageJPEGRepresentation(photo,1.0);
        
        [[RAMultipartRequest multipartRequestWithPath:kPathPhotos
                                          parameters:nil
                                         errorDomain:errorDomain
                                                body:^(id<AFMultipartFormData> formData) {
                                                    [formData appendPartWithFileData:imageData name:@"file" fileName:@"temp.png" mimeType:@"image/png"];
                                                }
                                             success:^(NSURLSessionTask *networkTask, id response) {
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)networkTask.response;
                                                NSString *location = [[httpResponse allHeaderFields] objectForKey:@"location"];
                                                 
                                                 if (completion) {
                                                     completion(location, nil);
                                                 }
                                             }
                                             failure:^(NSURLSessionTask *networkTask, NSError *error) {
                                                 if (completion) {
                                                     completion(nil, error);
                                                 }
                                             }]
         execute];
    } else {
        if (completion) {
            completion(nil, nil);
        }
    }
}

@end
