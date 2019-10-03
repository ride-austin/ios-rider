//
//  RARiderAPI.m
//  RideAustin
//
//  Created by Kitos on 8/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RARiderAPI.h"

#import "RASessionManager.h"

@implementation RARiderAPI

+ (void)getCurrentRiderWithCompletion:(RARiderCompletionBlock)handler {
    NSString *path = kPathRidersCurrent;
    
    RARequest *request = [RARequest requestWithPath:path mapping:^id(id response) {
        NSArray *cardsJSON      = response[@"cards"];
        NSDictionary *riderJSON = response[@"rider"];
        //NSDictionary *rideJSON  = response[@"ride"];
        RARiderDataModel *rider =
        [RAJSONAdapter modelOfClass:RARiderDataModel.class
                 fromJSONDictionary:riderJSON
                         isNullable:NO];
        
        NSArray<RACardDataModel*> *cards =
        [RAJSONAdapter modelsOfClass:RACardDataModel.class
                       fromJSONArray:cardsJSON
                          isNullable:NO];
        rider.cards = cards;
        
        NSArray <RAUnpaidBalance *> *balances =
        [RAJSONAdapter modelsOfClass:RAUnpaidBalance.class
                       fromJSONArray:response[@"unpaid"]
                          isNullable:NO];
        rider.unpaidBalance = balances.firstObject;
        [rider configureUserPreference];
        return rider;
    } success:^(NSURLSessionTask *networkTask, id response) {
        RARiderDataModel *rider = (RARiderDataModel*)response;
        if (handler) {
            handler(rider, nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(nil, error);
        }
    }];
    
    [request execute];
}

+ (void)updateRider:(RARiderDataModel*)rider completion:(NetworkCompletionBlock)handler {
    NSError *error;
    NSDictionary *params;
    if (rider) {
        params = [MTLJSONAdapter JSONDictionaryFromModel:rider error:&error];
    }
    
    if (!error) {
        NSString *riderID = rider.modelID.stringValue;
        NSString *path = [NSString stringWithFormat:kPathRidersSpecific, riderID];
        
        [[RARequest requestWithPath:path
                             method:PUT
                         parameters:params
                        errorDomain:PUTRidersRiderID
                  parameterEncoding:JSON
                           success:^(NSURLSessionTask *networkTask, id response) {
                               if (handler) {
                                   handler(nil);
                               }
                           }
                           failure:^(NSURLSessionTask *networkTask, NSError *error) {
                               if (handler) {
                                   handler(error);
                               }
                           }]
         execute];
    } else {
        if (handler) {
            handler(error);
        }
    }
}

@end

#pragma mark - Charity

@implementation RARiderAPI (Charity)

+ (void)updateCurrentRiderCharity:(RACharityDataModel *)charity withCompletion:(NetworkCompletionBlock)handler {
    RARiderDataModel *rider = [[RASessionManager sharedManager] currentRider];
    rider.charity = charity;
    [self updateRider:rider completion:handler];
}

@end

#pragma mark - Cards

@implementation RARiderAPI (Cards)

+ (void)addCardForRider:(NSString *)riderId token:(NSString *)cardToken withCompletion:(CardCreatedBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathRidersCards, riderId];
    NSDictionary *params = @{@"token" : cardToken};
    
    [[RARequest requestWithPath:path method:POST parameters:params mapping:^id(id response) {
        return [RAJSONAdapter modelOfClass:[RACardDataModel class] fromJSONDictionary:response isNullable:NO];
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

+ (void)setPrimaryCard:(RACardDataModel *)card toRider:(NSString *)riderId withCompletion:(PrimaryCardBlock)handler {
    NSAssert(card.modelID != nil, @"modelID cannot be nil");
    NSAssert(riderId      != nil, @"riderId cannot be nil");
    NSString *path = [NSString stringWithFormat:kPathRidersCardsSpecific, riderId, card.modelID];
    path = [path stringByAppendingString:@"?primary=true"]; //because PUT do not accept the params directly
    
    [[RARequest requestWithPath:path
                         method:PUT
                        success:^(NSURLSessionTask *networkTask, id response) {
                            if (handler) {
                                handler(nil);
                            }
                        }
                        failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (handler) {
                                handler(error);
                            }
                        }]
     execute];
}

+ (void)deleteCard:(RACardDataModel *)card fromRider:(NSString *)riderId withCompletion:(DeleteCardBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathRidersCardsSpecific, riderId, card.modelID];

    [[RARequest requestWithPath:path
                         method:DELETE
                        success:^(NSURLSessionTask *networkTask, id response) {
                            if (handler) {
                                handler(nil);
                            }
                        }
                        failure:^(NSURLSessionTask *networkTask, NSError *error) {
                            if (handler) {
                                handler(error);
                            }
                        }]
     execute];
}

+ (void)updateCard:(RACardDataModel *)card forRideWithId:(NSString *)riderId expMonth:(NSString *)month expYear:(NSString *)year withCompletion:(APIErrorResponseBlock)handler {
    NSString *path = [NSString stringWithFormat:kPathRidersCardsSpecific, riderId, card.modelID];
    NSString *isPrimary = card.primary.boolValue ? @"true" : @"false";
    path = [[path stringByAppendingString:[NSString stringWithFormat:@"?primary=%@&expMonth=%@&expYear=%@",isPrimary, month, year]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [[RARequest requestWithPath:path method:PUT success:^(NSURLSessionTask *networkTask, id response) {
        if (handler) {
            handler(nil);
        }
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        if (handler) {
            handler(error);
        }
    }] execute];
}

@end

@implementation RARiderAPI (UnpaidBalance)

+ (void)payUnpaidBalanceForRiderWithId:(NSString*)riderId rideId:(NSString*)rideId applePayToken:(NSString* _Nullable)applePayToken completion:(APIErrorResponseBlock _Nonnull)handler {
    NSParameterAssert(riderId);
    NSParameterAssert(rideId);
    NSString *path = [NSString stringWithFormat:kPathRidersPayUnpaidBalance, riderId];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"rideId"]        = rideId;
    params[@"applePayToken"] = applePayToken;
    
    [[RARequest requestWithPath:path method:POST parameters:params success:^(NSURLSessionTask *networkTask, id response) {
        handler(nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        handler(error);
    }] execute];
}

@end

@implementation RARiderAPI (CreditBalance)

+ (void)redemptionsRemainderForRiderWithId:(NSString *)riderId completion:(APIResponseBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathRidersRedemptionsReminder, riderId];
    
    [[RARequest requestWithPath:path mapping:^id(NSDictionary *response) {
        return (NSNumber*)response[@"remainder"];
    } success:^(NSURLSessionTask *networkTask, id response) {
        completion(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

+ (void)redemptionsForRiderWithId:(NSString *)riderId completion:(RedemptionsBlock)completion {
    NSString *path = [NSString stringWithFormat:kPathRidersRedemptions, riderId];
    
    [[RARequest requestWithPath:path mapping:^id(id response) {
        return [RAJSONAdapter modelsOfClass:[RARedemption class] fromJSONArray:response isNullable:YES];
    } success:^(NSURLSessionTask *networkTask, id response) {
        completion(response, nil);
    } failure:^(NSURLSessionTask *networkTask, NSError *error) {
        completion(nil, error);
    }] execute];
}

@end

