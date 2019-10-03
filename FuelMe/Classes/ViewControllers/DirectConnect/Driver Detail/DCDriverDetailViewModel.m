//
//  DCDriverDetailViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 12/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DCDriverDetailViewModel.h"

#import "CarCategoriesManager.h"
#import "NSString+Utils.h"
#import "RADirectConnectRideRequest.h"
#import "RASessionManager.h"

@interface DCDriverDetailViewModel()

@property (nonatomic) RADriverDirectConnectDataModel *driverDirectConnect;

@end

@implementation DCDriverDetailViewModel

- (instancetype)initWithDriverDirectConnect:(RADriverDirectConnectDataModel *)driverDirectConnect {
    if (self = [super init]) {
        _driverDirectConnect = driverDirectConnect;
        _selectedCategory = [self cheapestCategory].carCategory;
    }
    return self;
}

#pragma mark - Driver Profile

- (NSString *)driverFullName {
    return [NSString stringWithFormat:@"%@ %@", self.driverDirectConnect.firstName, self.driverDirectConnect.lastName];
}

- (NSString *)driverRating {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMinimumFractionDigits:2];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    return [formatter stringFromNumber:self.driverDirectConnect.rating];
}

- (NSURL *)driverPhotoUrl {
    return self.driverDirectConnect.photoUrl;
}

#pragma mark - Car Category

- (RACarCategoryDataModel *)cheapestCategory {
    RACarCategoryDataModel *cheapestCategory;
    double currentCheapestValue;
    for (NSString *category in self.driverDirectConnect.categories) {
        RACarCategoryDataModel *tmpCategory = [CarCategoriesManager getCategoryByName:category];
        NSNumber *tmpFactor = self.driverDirectConnect.factors[category] ?: @(1);
        double tmpCategoryValue = tmpCategory.baseFare.doubleValue * tmpFactor.doubleValue;
        
        if (!cheapestCategory || (tmpCategoryValue < currentCheapestValue)) {
            cheapestCategory = tmpCategory;
            currentCheapestValue = tmpCategoryValue;
        }
    }
    return cheapestCategory;
}

- (RACarCategoryDataModel *)category {
    return [CarCategoriesManager getCategoryByName:self.selectedCategory];
}

- (NSString *)numberOfSeats {
    return [NSString stringWithFormat:[@"%d Seats" localized], self.category.maxPersons.intValue];
}

- (NSNumber *)priorityForSelectedCategory {
    return self.driverDirectConnect.factors[self.selectedCategory];
}

- (BOOL)shouldShowPriority {
    return [self priorityForSelectedCategory].floatValue > 1.0;
}

- (NSString *)priority {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setMinimumFractionDigits:2];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    return [formatter stringFromNumber:[self priorityForSelectedCategory]];
}

#pragma mark - Direct Connect Request

- (RADirectConnectRideRequest *)directConnectRideRequestWithApplePayToken:(NSString *)applePayToken address:(RAAddress *)address {
    RADirectConnectRideRequest *directConnectRideReqeuest = [[RADirectConnectRideRequest alloc] init];
    directConnectRideReqeuest.applePayToken = applePayToken;
    directConnectRideReqeuest.directConnectId = [self.driverDirectConnect.modelID stringValue];
    directConnectRideReqeuest.hasSurgeArea = self.shouldShowPriority;
    directConnectRideReqeuest.carCategory = self.category;
    directConnectRideReqeuest.startLocation = [[RARideLocationDataModel alloc] initWithAddress:address];
    
    RARiderDataModel *currentRider = [RASessionManager sharedManager].currentRider;
    if (currentRider.preferredPaymentMethod == PaymentMethodBevoBucks) {
        directConnectRideReqeuest.paymentProvider = @"BEVO_BUCKS";
    }
    
    return directConnectRideReqeuest;
}

@end
