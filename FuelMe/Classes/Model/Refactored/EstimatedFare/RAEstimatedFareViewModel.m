//
//  RAEstimatedFareDataModel.m
//  Ride
//
//  Created by Roberto Abreu on 1/3/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAEstimatedFareViewModel.h"
#import "RAEstimate.h"
#import "NSString+Utils.h"

@interface RAEstimatedFareViewModel()

@property (nonatomic, readonly) RAEstimate *estimate;

@end

@implementation RAEstimatedFareViewModel

- (instancetype)initWithStartAddress:(NSString *)startAddress endAddress:(NSString *)endAddress estimate:(RAEstimate *)estimate {
    if (self = [super init]) {
        _title = [@"Fare Estimate" localized];
        _startAddress = startAddress;
        _endAddress = endAddress;
        if (estimate.campaignInfo) {
            _displayFareEstimate = [NSString stringWithFormat:@"$ %@", estimate.campaignInfo.estimatedFare];
        } else {
            _displayFareEstimate = [NSString stringWithFormat:@"$ %@", estimate.totalFare];
        }
    }
    return self;
}

@end
