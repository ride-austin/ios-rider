//
//  RARideRequestManager.h
//  Ride
//
//  Created by Kitos on 18/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FemaleDriverModeDataSource.h"
#import "RACarCategoryDataModel.h"
#import "RARideRequest.h"

@interface RARideRequestManager : NSObject

/**
 returns YES if user has selected female driver mode
 */
@property (nonatomic, getter=isWomanOnlyModeOn) BOOL womanOnlyModeOn;
@property (nonatomic) BOOL isFingerprintedDriverOnlyModeOn;
@property (nonatomic, readonly) RARideRequest *currentRideRequest;

+ (RARideRequestManager*)sharedManager;

- (void)riderHasSelectedPickUpLocation:(RARideLocationDataModel*)pickUpLocation;
- (void)riderHasSelectedDestinationLocation:(RARideLocationDataModel*)destinationLocation;
- (void)riderHasWrittenPickUpComment:(NSString*)pickUpComment;
- (void)riderHasSelectedCategory:(RACarCategoryDataModel*)category;

- (void)deleteRideRequest;

- (BOOL)allowsCategory:(RACarCategoryDataModel*)category;

- (void)reloadCurrentRideRequestWithPickupLocation:(RARideLocationDataModel*)pickupLocation andDestinationLocation:(RARideLocationDataModel*)destinationLocation;

@end

@interface RARideRequestManager(FemaleDriverModeDataSource) <FemaleDriverModeDataSource>

@end
