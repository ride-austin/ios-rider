//
//  UnratedRide.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "UnratedRide.h"
#import "RAPaymentProviderFactory.h"
#import "NSDate+Utils.h"

@interface UnratedRide()

@property (nonatomic, readwrite) RARideDataModel *ride;
@property (nonatomic, readwrite) RAPaymentProvider *paymentProvider;

@end

@implementation UnratedRide



- (instancetype)initWithRide:(RARideDataModel *)ride andPaymentMethod:(PaymentMethod)paymentMethod {
    if (self = [super init]) {
        self.ride = ride;
        self.paymentMethod = paymentMethod;
        self.paymentProvider = [RAPaymentProviderFactory paymentProviderWithPreferredPaymentMethod:paymentMethod];
    }
    return self;
}

- (NSString *)validatedTip {
    return self.shouldShowTip ? self.userTip : nil;
}

- (BOOL)shouldShowTip {
    if (self.ride.tippingAllowed) {
        if (self.ride.tippingAllowed.boolValue && self.ride.tipUntil) {
            return [[NSDate trueDate] compare:self.ride.tipUntil] == NSOrderedAscending;
        } else {
            return NO;
        }
    }
    return YES;
}

#pragma mark - For Sending

- (NSString *)rideID {
    return self.ride.modelID.stringValue;
}

- (BOOL)shouldShowPaymentProvider {
    if (self.paymentProvider && self.ride.tipUntil) {
        return [[NSDate trueDate] compare:self.ride.tipUntil] == NSOrderedAscending;
    }
    return NO;
}

- (NSString *)paymentMethodRequestParameter {
    switch (self.paymentMethod) {
        case PaymentMethodUnspecified:
        case PaymentMethodApplePay:
            return nil;
        case PaymentMethodBevoBucks:
            return @"BEVO_BUCKS";
        case PaymentMethodPrimaryCreditCard:
            return @"CREDIT_CARD";
    }
}

@end

@implementation UnratedRide (MTLJSONSerializing)

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"ride" : @"ride",
      @"userRating" : @"userRating",
      @"userTip" : @"userTip",
      @"userComment" : @"userComment",
      @"paymentMethod" : @"paymentMethod",
      @"paymentProvider" : @"paymentProvider"
      };
}

+ (NSValueTransformer *)rideJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARideDataModel.class];
}

+ (NSValueTransformer *)paymentMethodJSONTransformer {
    NSDictionary *methods = @{
                              @(1):@(PaymentMethodPrimaryCreditCard),
                              @(2):@(PaymentMethodBevoBucks),
                              @(3):@(PaymentMethodApplePay)
                              };
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        if ([value isKindOfClass:NSNumber.class]) {
            return methods[value] ?: @(PaymentMethodUnspecified);
        } else {
            return @(PaymentMethodUnspecified);
        }
    } reverseBlock:^id(NSNumber *value, BOOL *success, NSError *__autoreleasing *error) {
        if (value) {
            return [methods allKeysForObject:value].lastObject;
        } else {
            return nil;
        }
    }];
}

+ (NSValueTransformer *)paymentProviderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RAPaymentProvider.class];
}

@end
