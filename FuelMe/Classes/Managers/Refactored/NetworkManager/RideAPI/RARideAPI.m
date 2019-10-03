//
//  RARideAPI.m
//  Ride
//
//  Created by Kitos on 10/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RARideAPI.h"

#import "ConfigurationManager.h"
#import "NSString+Utils.h"
#import "NSString+XMLEncoding.h"
#import "RAMacros.h"
#import "RAPickupManager.h"

@implementation RARideAPI

+ (void)requestRide:(RARideRequestAbstract *)rideRequest withCompletion:(RARideStatusCodeCompletionBlock)handler {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[rideRequest jsonDictionary]];
    
    RACity *city = [ConfigurationManager shared].global.currentCity;
    if ([city containsCoordinate:rideRequest.startLocation.coordinate]) {
        [params addEntriesFromDictionary:city.requestParameter];
    }
    NSString *path = kPathRides;
    
    RARequest *request = [RARequest requestWithPath:path method:POST parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:RARideDataModel.class fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)networkTask.response;
            handler(httpResponse.statusCode, response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)networkTask.response;
            handler(httpResponse.statusCode, nil, error);
        }
    }];
    
    request.mappingQueueType = QueueTypeUserInitiated;
    [request execute];
}

+ (void)postRidesQueue:(NSString *)token withCompletion:(RARideCompletionBlock)completion {
    
    NSString *path = [NSString stringWithFormat:kPathRidesQueue, token];
    
    RARequest *request = [RARequest requestWithPath:path method:POST parameters:nil mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:RARideDataModel.class fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
    
    request.mappingQueueType = QueueTypeUserInitiated;
    [request execute];
}

+ (void)cancelRideById:(NSString*)rideID withCompletion:(APIErrorResponseBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathRidesSpecific,rideID];
    [[RARequest requestWithPath:path method:DELETE success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(error);
        }
    }] execute];
}

+ (void)getRide:(NSString *)rideID andCompletion:(RARideCompletionBlock)handler {
    [RARideAPI getRide:rideID withRiderLocation:nil andCompletion:handler];
}

+ (void)getRide:(NSString *)rideID withRiderLocation:(CLLocation *)riderLocation andCompletion:(RARideCompletionBlock)handler {
    NSString * path = [NSString stringWithFormat:kPathRidesSpecific, rideID];
    
    NSDictionary *parameters = nil;
    ConfigLiveLocation *configLiveLocation = [ConfigurationManager shared].global.liveLocation;
    if (riderLocation && [riderLocation isValidLiveLocationBasedOnConfig:configLiveLocation]) {
        parameters = @{ @"lat":@(riderLocation.coordinate.latitude),
                        @"lng":@(riderLocation.coordinate.longitude)};
    }
    
    [[RARequest requestWithPath:path parameters:parameters parameterEncoding:FORM errorDomain:GETRideByID mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:RARideDataModel.class fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil,error);
        }
    }] execute];
}

+ (void)getCurrentRideWithCompletion:(RARideCompletionBlock)handler {
    NSString * path = kPathRidesCurrent;
    
    RARequest *request = [RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:RARideDataModel.class fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil,error);
        }
    }];
    
    request.mappingQueueType = QueueTypeUtility;
    [request execute];
}

+ (void)updateDestination:(RARideLocationDataModel *)destination forRide:(NSString *)rideID completion:(APIErrorResponseBlock)handler {
    
    NSString *zip = destination.zipCode;
    if (IS_EMPTY(zip)) {
        zip = @"0000";
    }
    
    NSString *address = destination.address;// address ? address.urlencode : @"";
    if (IS_EMPTY(address)) {
        address = @"";
    }
    address = address.urlencode;
    
    //FIX: RA-5122 setup params and mostly coordinates as NSNumber Objects to avoid truncate values
    NSDictionary *params = @{@"endLocationLat"  :destination.latitude,
                             @"endLocationLong" :destination.longitude,
                             @"endAddress"      :address,
                             @"endZipCode"      :zip
                             };
    
    NSString * path = [NSString stringWithFormat:@"%@/%@?%@",
                       kPathRides,
                       rideID,
                       [NSString urlEncodedString:params] //because PUT do not accept the params directly
                       ];
    RARequest *request =
    [RARequest requestWithPath:path
                        method:PUT
                   errorDomain:PUTUpdateDestination
                       success:^(NSURLSessionTask *networkTask, id response) {
                           if (handler) {
                               handler(nil);
                           }
                       }
                       failure:^(NSURLSessionTask *networkTask, NSError *error) {
                           if (handler) {
                               handler(error);
                           }
                       }
    ];
    [request execute];
}

+ (void)updateComment:(NSString *)comment forRide:(NSString *)rideID completion:(APIErrorResponseBlock)handler {
    if (IS_EMPTY(comment)) {
        comment = @"";
    }
    
    NSDictionary *params = @{@"comment":comment.urlencode};
    
    NSString * path = [NSString stringWithFormat:@"%@/%@?%@",
                       kPathRides,
                       rideID,
                       [NSString urlEncodedString:params] //because PUT do not accept the params directly
                       ];
    RARequest *request =
    [RARequest requestWithPath:path
                         method:PUT
                    errorDomain:PUTUpdateComments
                        success:^(NSURLSessionTask *networkTask, id response) {
                            if (handler) {
                                handler(nil);
                            }
                        }
                        failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (handler) {
                                handler(error);
                            }
                        }
    ];
    [request execute];
}
@end

@implementation RARideAPI (UpgradeRideRequest)

+ (void)declineUpgradingCurrentRideWithCompletion:(APIErrorResponseBlock)handler {
    NSString *path = [kPathRidesUpgrade stringByAppendingPathComponent:@"decline?avatarType=RIDER"];
    [[RARequest requestWithPath:path
                         method:POST
                        success:^(NSURLSessionTask *networkTask, id response) {
                            if (handler) {
                                handler(nil);
                            }
                        }
                        failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (handler) {
                                handler(error);
                            }
                        }
      ]
     execute];
}

+ (void)confirmUpgradingCurrentRideWithCompletion:(APIErrorResponseBlock)handler {
    NSString *path = [kPathRidesUpgrade stringByAppendingPathComponent:@"accept"];
    [[RARequest requestWithPath:path
                         method:POST
                        success:^(NSURLSessionTask *networkTask, id response) {
                            if (handler) {
                                handler(nil);
                            }
                        }
                        failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (handler) {
                                handler(error);
                            }
                        }
      ]
     execute];
}

@end

@implementation RARideAPI (CancellationFeedback)

+ (void)getReasonsWithCompletion:(void (^)(NSArray<CFReasonDataModel *> *, NSError *))completion {
    RARequest *request = [RARequest requestWithPath:kPathRidesCancellation parameters:@{@"avatarType": @"RIDER"} mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:CFReasonDataModel.class fromJSONArray:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
    request.mappingQueueType = QueueTypeUserInitiated;
    [request execute];
}

+ (void)postReason:(NSString *)reasonCode forRide:(NSNumber *)rideID withComment:(NSString *)comment andCompletion:(void (^)(NSError *))completion {
    NSParameterAssert([reasonCode isKindOfClass:NSString.class]);
    NSParameterAssert([rideID     isKindOfClass:NSNumber.class]);
    NSParameterAssert([comment    isKindOfClass:NSString.class] || !comment);
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"reason"]  = reasonCode;
    params[@"comment"] = comment;
    NSString *path = [NSString stringWithFormat:kPathRidesCancellationRide, rideID.stringValue];
    RARequest *request = [RARequest requestWithPath:path method:POST parameters:params success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(error);
        }
    }];
    
    request.mappingQueueType = QueueTypeUserInitiated;
    [request execute];
}

@end


@implementation RARideAPI (Costs)

+ (void)getSpecialFeesAtCoordinate:(CLLocationCoordinate2D)coordinate
                           cityID:(NSNumber *)cityID
                   forCarCategory:(NSString *)carCategory
                   withCompletion:(void (^)(NSArray<RAFee *> *fees, NSError *error))completion {
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"startLat"]     = @(coordinate.latitude);
    params[@"startLong"]    = @(coordinate.longitude);
    params[@"carCategory"]  = carCategory;
    params[@"cityId"]       = cityID;
    
    RARequest *request = [RARequest requestWithPath:kPathRidesSpecialFees parameters:params parameterEncoding:JSON errorDomain:GETRideSpecialFees mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[RAFee class] fromJSONArray:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, id response) {
        if (completion) {
            completion(response, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
    
    request.mappingQueueType = QueueTypeUserInitiated;
    [request execute];
}

+ (void)getRideEstimateFromStartLocation:(CLLocationCoordinate2D)startLocation
                          toEndLocation:(CLLocationCoordinate2D)endLocation
                             inCategory:(RACarCategoryDataModel*)category
                         withCompletion:(void (^)(RAEstimate *, NSError *))completion {
    NSString * path = kPathRidesEstimate;
    
    NSMutableDictionary * params = [NSMutableDictionary new];
    params[@"startLat"]         = @(startLocation.latitude);
    params[@"startLong"]        = @(startLocation.longitude);
    params[@"endLat"]           = @(endLocation.latitude);
    params[@"endLong"]          = @(endLocation.longitude);
    params[@"inSurgeArea"]      = category.hasPriority ? @"true" : @"false";
    params[@"carCategory"]      = category.carCategory;
    
    RACity *city = [ConfigurationManager shared].global.currentCity;
    if ([city containsCoordinate:startLocation]) {
        [params addEntriesFromDictionary:city.requestParameter];
    }
    [[RARequest requestWithPath:path parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:RAEstimate.class fromJSONDictionary:response isNullable:NO];
    } success:^(NSURLSessionTask *networkTask, RAEstimate *response) {
        completion(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

@end

@implementation RARideAPI (CompletedRides)

+ (void)getMapForRide:(NSString *)rideID withCompletion:(void (^)(NSURL *mapURL, NSError *error))completion {
    NSString *path = [NSString stringWithFormat:kPathRidesMap, rideID];
    [[RARequest requestWithPath:path method:GET parameterEncoding:FORM success:^(NSURLSessionTask *networkTask, id response) {
        if (response[@"url"]) {
            NSURL *mapURL = [NSURL URLWithString:response[@"url"]];
            completion(mapURL, nil);
        } else {
            completion(nil, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

+ (void)rateRide:(NSString *)rideID withRating:(NSString *)rating tip:(NSString *)tip andComment:(NSString *)comment paymentProvider:(NSString *)paymentProvider withCompletion:(RARideCompletionBlock)completion {
    NSParameterAssert(rating);
    
    NSString *path = [NSString stringWithFormat:kPathRidesRating, rideID];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"rating"]   = rating;
    params[@"tip"]      = tip;
    params[@"comment"]  = [comment stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    params[@"paymentProvider"] = paymentProvider;
    path = [NSString stringWithFormat:@"%@?%@",path,[NSString urlEncodedString:params]];
    
    [[RARequest requestWithPath:path method:PUT parameters:nil errorDomain:PUTRateRide parameterEncoding:FORM mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RARideDataModel class] fromJSONDictionary:response isNullable:NO];
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

@end

@implementation RARideAPI (RealTimeTracking)

+ (void)getRealTimeTrackingTokenByID:(NSString *)rideID completion:(void(^)(NSString *token, NSError *error))completion {
    NSString *path = [NSString stringWithFormat:kPathRidesGetShareToken, rideID];
    [[RARequest requestWithPath:path method:POST parameters:@{} errorDomain:GETShareTokenLiveETA parameterEncoding:JSON success:^(NSURLSessionTask *networkTask, id response) {
        completion(response[@"token"], nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

@end
