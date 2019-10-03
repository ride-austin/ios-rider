//
//  CFViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 3/24/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "CFViewModel.h"
#import "CFReasonDataModel.h"
#import "NSDictionary+JSON.h"
#import "RARideAPI.h"
#import "NSString+Utils.h"

@interface CFViewModel()
@property (nonatomic, nonnull) RARideDataModel *ride;
@property (nonatomic, readwrite, nonnull) NSArray<CFReasonDataModel *>*items;
@end

@implementation CFViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _title = @"Your ride was cancelled";
        _subtitle = @"Tell us why and help us improve.";
    }
    return self;
}

- (void)setRide:(RARideDataModel *)ride {
    _ride = ride;
    _title = @"Your ride was cancelled";
}
- (void)getReasonsWithCompletion:(void (^)(NSError * _Nullable))completion {
    __weak __typeof__(self) weakself = self;
    [RARideAPI getReasonsWithCompletion:^(NSArray<CFReasonDataModel *> *reasons, NSError *error) {
        if (error) {
            NSError *parsingError = nil;
            id json = [NSDictionary jsonFromResourceName:@"RIDES_CANCELLATION_REASONS"];
            weakself.items = [MTLJSONAdapter modelsOfClass:CFReasonDataModel.class fromJSONArray:json error:&parsingError];
        } else {
            weakself.items = reasons;
        }
        completion(error);
    }];
}

- (void)submitCancellationReason:(NSString *)reasonCode comment:(NSString *)comment {
    NSParameterAssert([reasonCode isKindOfClass:NSString.class]);
    [RARideAPI postReason:reasonCode forRide:self.ride.modelID withComment:comment andCompletion:^(NSError *error) {
        if (error) {
            
        }
    }];
}
@end
