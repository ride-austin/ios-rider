//
//  RADriverAPI.h
//  Ride
//
//  Created by Roberto Abreu on 12/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigRegistration.h"
#import "RABaseAPI.h"
#import "RADriverTypeDataModel.h"

@class DSDriver;
@class RADriverDirectConnectDataModel;
@class RADirectConnectHistory;
@class RADriverDataModel;

typedef void(^DriverTypeBlock)(NSArray<RADriverTypeDataModel *>* _Nullable types, NSError * _Nullable error);
typedef void(^DriverTermsBlock)(NSString * _Nullable terms,NSError * _Nullable error);
typedef void(^DriverDirectConnectBlock)(RADriverDirectConnectDataModel * _Nullable driverDirectConnect, NSError * _Nullable error);
typedef void(^DriverDirectConnectHistoryBlock)(NSArray<RADirectConnectHistory *>* _Nullable history, NSError * _Nullable error);
typedef void (^DriverCheckrBlock)(RADriverDataModel * _Nullable driver, NSError * _Nullable error);

@interface RADriverAPI : RABaseAPI

#pragma mark - Documents
+ (void)postInspectionStickerDocumentWithDriverId:(NSString* _Nonnull)driverId
                                            carId:(NSString* _Nonnull)carId
                                     validityDate:(NSString* _Nonnull)validityDate
                                           cityId:(NSNumber* _Nonnull)cityId
                                         fileData:(NSData* _Nonnull)fileData
                                       completion:(void(^ _Nullable)(NSError * _Nullable error))completion;

+ (void)postChauffeurLicenseWithDriverId:(NSString * _Nonnull)driverId
                         cityId:(NSNumber * _Nonnull)cityId
                   validityDate:(NSString * _Nullable)validityDate
                       fileData:(NSData * _Nonnull)fileData
                     completion:(void (^ _Nullable)(NSError * _Nullable error))completion;

#pragma mark - SignUp
+ (void)getDriverTermsAtURL:(NSURL*_Nonnull)url withCompletion:(DriverTermsBlock _Nonnull)handler;
+ (void)postPhotoForDriverWithId:(NSString*_Nonnull)driverId fileData:(NSData*_Nonnull)fileData andCompletion:(APIResponseBlock _Nonnull )handler;
+ (void)signUpDriverWithConfig:(ConfigRegistration *_Nonnull)regConfig driverParams:(NSDictionary*_Nonnull)driverParams carParams:(NSDictionary*_Nonnull)carParams completeBlock:(APIResponseBlock _Nonnull)handler;
+ (void)createDriver:(DSDriver *_Nonnull)driver license:(NSData *_Nonnull)license insurance:(NSData *_Nonnull)insurance withCompletion:(void(^_Nonnull)(id _Nullable response, NSError *_Nullable error))completion;

#pragma mark - Cars
+ (void)createCarWithParams:(NSDictionary*_Nonnull)bodyParams forDriverWithId:(NSString*_Nonnull)driverId andCompletion:(APIResponseBlock _Nonnull)handler;
+ (void)postPhotoForCarWithId:(NSString*_Nonnull)carId photoType:(NSString*_Nonnull)photoType fileData:(NSData*_Nonnull)fileData andCompletion:(APIResponseBlock _Nullable)handler;

#pragma mark - Car Categories
+ (void)getCurrentCarCategoriesWithCompletion:(APIResponseBlock _Nonnull)handler;

#pragma mark - Direct Connect
+ (void)getDriverConnectHistoryWithRiderId:(NSString *_Nonnull)riderId completion:(DriverDirectConnectHistoryBlock _Nonnull)completion;
+ (void)getDriverConnectWithId:(NSString *_Nonnull)driverConnectId completion:(DriverDirectConnectBlock _Nonnull)completion;

#pragma mark - Checkr
+(void)postCheckrPaymentWithDriverId:(NSString* _Nonnull)driverId completion:(DriverCheckrBlock _Nonnull)completion;

@end
