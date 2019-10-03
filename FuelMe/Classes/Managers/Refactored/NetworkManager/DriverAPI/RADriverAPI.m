//
//  RADriverAPI.m
//  Ride
//
//  Created by Roberto Abreu on 12/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RADriverAPI.h"

#import "ConfigRegistration.h"
#import "DSDriver.h"
#import "LocationService.h"
#import "NSString+CityID.h"
#import "RADirectConnectHistory.h"
#import "RADriverDirectConnectDataModel.h"
#import "RAEnvironmentManager.h"
#import "RAMacros.h"
#import "RASessionManager.h"

@implementation RADriverAPI

#pragma mark - Documents

+ (void)postInspectionStickerDocumentWithDriverId:(NSString *)driverId
                                            carId:(NSString *)carId
                                     validityDate:(NSString *)validityDate
                                           cityId:(NSNumber *)cityId
                                         fileData:(NSData *)fileData
                                       completion:(void (^)(NSError *))completion {
    NSParameterAssert(driverId);
    NSParameterAssert(carId);
    NSParameterAssert(cityId);
    NSParameterAssert(validityDate);
    NSParameterAssert(fileData);
    [RADriverAPI postDocumentWithType:@"CAR_STICKER"
                             driverId:driverId
                                carId:carId
                               cityId:cityId
                         validityDate:validityDate
                             fileData:fileData
                           completion:completion];
}

+ (void)postChauffeurLicenseWithDriverId:(NSString *)driverId
                                  cityId:(NSNumber *)cityId
                            validityDate:(NSString *)validityDate
                                fileData:(NSData *)fileData
                              completion:(void (^)(NSError *))completion {
    [RADriverAPI postDocumentWithType:@"CHAUFFEUR_LICENSE"
                             driverId:driverId
                                carId:nil
                               cityId:cityId
                         validityDate:validityDate
                             fileData:fileData
                           completion:completion];
}

+ (void)postDocumentWithType:(NSString*)photoType
                    driverId:(NSString*)driverId
                       carId:(NSString*)carId
                      cityId:(NSNumber*)cityId
                validityDate:(NSString*)validityDate
                    fileData:(NSData*)fileData
                  completion:(void(^)(NSError *error))completion {

    NSString *endpoint = [NSString stringWithFormat:kPathDriversDocuments,driverId];

    NSMutableDictionary *params     = [NSMutableDictionary new];
    params[@"driverPhotoType"]      = photoType;
    params[@"cityId"]               = cityId;
    params[@"carId"]                = carId;
    
    //send validityDate if enabled
    if (!IS_EMPTY(validityDate)) {
        params[@"validityDate"]     = validityDate;
    }

    [[RAMultipartRequest multipartRequestWithPath:endpoint
                                      parameters:params
                                     errorDomain:POSTDriversDocuments
                                            body:^(id<AFMultipartFormData> formData) {
                                                NSMutableString *fileName = [NSMutableString stringWithFormat:@"%@-%@", photoType.lowercaseString, driverId].mutableCopy;
                                                if (carId) {
                                                    [fileName appendFormat:@"-%@", carId];
                                                }
                                                [formData appendPartWithFileData: fileData
                                                                            name: @"fileData"
                                                                        fileName: fileName
                                                                        mimeType: @"image/png"];
                                            }
                                         success:^(NSURLSessionTask *networkTask, id response) {
                                             if (completion) {
                                                 completion(nil);
                                             }
                                         }
                                         failure:^(NSURLSessionTask *networkTask, NSError *error) {
                                             if (completion) {
                                                 completion(error);
                                             }
                                         }]
     execute];
 }

#pragma mark - SignUp

+ (void)getDriverTermsAtURL:(NSURL *)url withCompletion:(DriverTermsBlock)handler {
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [ErrorReporter recordError:error withDomainName:GETDriverTerms];
            handler(nil,error);
        } else {
            NSString *terms = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            handler(terms, nil);
        }
    }] resume];
}

+ (void)postPhotoForDriverWithId:(NSString *)driverId fileData:(NSData *)fileData andCompletion:(APIResponseBlock)handler {
    NSParameterAssert(driverId);
    NSParameterAssert(fileData);
    NSString *path = [NSString stringWithFormat:kDriverPhotoPath,driverId];
    
    [[RAMultipartRequest multipartRequestWithPath:path parameters:nil errorDomain:POSTDriversCarPhoto body:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: fileData
                                    name: @"photoData"
                                fileName: @"photo.png"
                                mimeType: @"image/png"];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
    
}

+ (void)signUpDriverWithConfig:(ConfigRegistration *)regConfig driverParams:(NSDictionary *)driverParams carParams:(NSDictionary *)carParams completeBlock:(APIResponseBlock)handler {
    
    //Date Formatters
    //NOTE: [SERVER EXPECT] ~ Date format yyyy-MM-dd
    NSDateFormatter *dateFormatterServer = [[NSDateFormatter alloc] init];
    dateFormatterServer.dateFormat = @"yyyy-MM-dd";
    
    NSDateFormatter *dateFormatterClient = [[NSDateFormatter alloc] init];
    dateFormatterClient.dateFormat = @"MM/dd/yyyy";
    
    NSArray *carsParams = [NSArray arrayWithObject:carParams];
    
    NSString *dateOfBirthClientFormat = driverParams[@"dateOfBirth"];
    NSDate *date = [dateFormatterClient dateFromString:dateOfBirthClientFormat];
    
    NSString *dateOfBirthFormat = [dateFormatterServer stringFromDate:date];
    
    //Insurance image & Expiration Date
    NSData *insuranceData = driverParams[@"insuranceData"];
    NSDate *insuranceDate = driverParams[@"insuranceExpiryDate"];
    NSString *insuranceDateFormat = [dateFormatterServer stringFromDate:insuranceDate];
    
    //License image & Expiration Date
    NSData *licenseData = driverParams[@"licenseData"];
    NSDate *licenseDate = driverParams[@"licenseExpiryDate"];
    NSString *licenseDateFormat = [dateFormatterServer stringFromDate:licenseDate];
    
    NSDictionary *addrParams = @{   @"address"      : driverParams[@"address"],
                                    @"zipCode"      : driverParams[@"currentZip"]  };
    
    RAUserDataModel *user = [[RASessionManager sharedManager] currentUser];
    NSDictionary *userParams = @{   @"dateOfBirth"  : dateOfBirthFormat,
                                    @"address"      : addrParams,
                                    @"firstname"    : driverParams[@"firstname"],
                                    @"lastname"     : driverParams[@"lastname"],
                                    @"middleName"   : driverParams[@"middleName"],
                                    @"phoneNumber"  : user.phoneNumber,
                                    @"email"        : user.email,
                                    @"enabled"      : @"true"
                                    };
    NSMutableDictionary *driverObject = [NSMutableDictionary new];
    driverObject[@"type"]           = @"DRIVER";
    driverObject[@"cars"]           = carsParams;
    driverObject[@"licenseNumber"]  = driverParams[@"licenseNumber"];
    driverObject[@"licenseState"]   = driverParams[@"licenseState"];
    driverObject[@"ssn"]            = driverParams[@"ssn"];
    driverObject[@"email"]          = user.email;
    driverObject[@"cityId"]         = regConfig.city.cityID;
    driverObject[@"user"]           = userParams;
    driverObject[@"insuranceExpiryDate"] = insuranceDateFormat;
    driverObject[@"licenseExpiryDate"] = licenseDateFormat;
    
    NSData *paramData = [NSJSONSerialization dataWithJSONObject: driverObject options:0 error:NULL];
    NSString * licenseFileName   = [NSString stringWithFormat:@"%@-licensephoto.png",driverParams[@"licenseNumber"]];
    NSString * insuranceFileName = [NSString stringWithFormat:@"%@-insurance.png",driverParams[@"licenseNumber"]];
    
    [[RAMultipartRequest multipartRequestWithPath:kPathDrivers parameters:nil errorDomain:POSTSignupDriver body:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: paramData
                                    name:@"driver"
                                fileName:@"driver.json"
                                mimeType: @"application/json"];
        
        [formData appendPartWithFileData: licenseData
                                    name: @"licenseData"
                                fileName: licenseFileName
                                mimeType: @"image/png"];
        
        [formData appendPartWithFileData: insuranceData
                                    name: @"insuranceData"
                                fileName: insuranceFileName
                                mimeType: @"image/png"];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
}

+ (void)createDriver:(DSDriver *)driver license:(NSData *)license insurance:(NSData *)insurance withCompletion:(void(^)(id response, NSError *))completion {
    NSParameterAssert(driver.isValid);
    NSParameterAssert([license isKindOfClass:NSData.class]);
    NSParameterAssert([insurance isKindOfClass:NSData.class]);
    NSError *error;
    id json = [MTLJSONAdapter JSONDictionaryFromModel:driver error:&error];
    if (error) {
        NSAssert(error == nil, @"RADriverAPI createDriver is failing with error %@", error);
        completion(nil, error);
        return;
    }
    
    NSString * licenseFileName   = [NSString stringWithFormat:@"%@-licensephoto.png", driver.licenseNumber];
    NSString * insuranceFileName = [NSString stringWithFormat:@"%@-insurance.png", driver.licenseNumber];
    
    NSData *paramData = [NSJSONSerialization dataWithJSONObject:json options:0 error:NULL];
    [[RAMultipartRequest multipartRequestWithPath:kPathDrivers parameters:nil errorDomain:POSTSignupDriver body:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: paramData
                                    name:@"driver"
                                fileName:@"driver.json"
                                mimeType: @"application/json"];
        
        [formData appendPartWithFileData: license
                                    name: @"licenseData"
                                fileName: licenseFileName
                                mimeType: @"image/png"];
        
        [formData appendPartWithFileData: insurance
                                    name: @"insuranceData"
                                fileName: insuranceFileName
                                mimeType: @"image/png"];
    } success:^(NSURLSessionTask *networkTask, id response) {
        completion(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

#pragma mark - Cars

+ (void)createCarWithParams:(NSDictionary *)bodyParams forDriverWithId:(NSString*)driverId andCompletion:(APIResponseBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathDriverCars,driverId];
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyParams options:NSJSONWritingPrettyPrinted error:nil];
    [[RAMultipartRequest multipartRequestWithPath:path parameters:nil errorDomain:POSTDriversCarPhoto body:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: bodyData
                                    name:@"car"
                                fileName:@"car.json"
                                mimeType:@"application/json"];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
}

+ (void)postPhotoForCarWithId:(NSString *)carId photoType:(NSString*)photoType fileData:(NSData *)fileData andCompletion:(APIResponseBlock)handler {
    
    NSString *path = [NSString stringWithFormat:kPathDriverCarPhoto,carId];
    NSDictionary *params = @{@"carPhotoType" : photoType};
    
    [[RAMultipartRequest multipartRequestWithPath:path parameters:params errorDomain:POSTDriversCarPhoto body:^(id<AFMultipartFormData> formData) {
        NSString* filename = [NSString stringWithFormat:@"carPhoto%@.png", photoType];
        [formData appendPartWithFileData: fileData
                                    name: @"photo"
                                fileName: filename
                                mimeType: @"image/png"];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
}

#pragma mark - CarCategories

+ (void)getCurrentCarCategoriesWithCompletion:(APIResponseBlock)handler {
    NSString *path = [kPathDriversCarTypes pathWithCityAppendType:AppendAsFirstParameter];
    [[RARequest requestWithPath:path success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }] execute];
}

#pragma mark - Direct Connect

+ (void)getDriverConnectWithId:(NSString *)driverConnectId completion:(DriverDirectConnectBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathDriverDirectConnect, driverConnectId];
    
    CLLocation *currentLocation = [LocationService sharedService].myLocation;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (currentLocation) {
        params[@"lat"] = @(currentLocation.coordinate.latitude);
        params[@"lng"] = @(currentLocation.coordinate.longitude);
    }
    
    [[RARequest requestWithPath:path parameters:params mapping:^id(id response) {
        RADriverDirectConnectDataModel *directConnectDataModel = [RAJSONAdapter modelOfClass:[RADriverDirectConnectDataModel class] fromJSONDictionary:response isNullable:NO];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        directConnectDataModel.modelID = [numberFormatter numberFromString:driverConnectId];
        return directConnectDataModel;
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }] execute];
}

+ (void)getDriverConnectHistoryWithRiderId:(NSString *_Nonnull)riderId completion:(DriverDirectConnectHistoryBlock _Nonnull)completion {
    
    NSDictionary *params  = @{@"riderId":riderId};
    [[RARequest requestWithPath:kPathDriverDirectConnectHistory parameters:params mapping:^id(id response) {
        NSArray <RADirectConnectHistory*> * history = [RAJSONAdapter modelsOfClass: RADirectConnectHistory.class fromJSONArray:response isNullable:YES];
        return history;
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }] execute];
}

#pragma mark - Checkr

+(void)postCheckrPaymentWithDriverId:(NSString* _Nonnull)driverId completion:(DriverCheckrBlock _Nonnull)completion  {
    NSString *path = [NSString stringWithFormat:kPathDriverCheckrPayment, driverId];
    [[RARequest requestWithPath:path method:POST success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
        
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil,error);
        }
    }] execute];
}


@end
