//
//  DCDriverDetailViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 12/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RACarCategoryDataModel.h"
#import "RADirectConnectRideRequest.h"
#import "RADriverDirectConnectDataModel.h"

@interface DCDriverDetailViewModel : NSObject

- (instancetype)initWithDriverDirectConnect:(RADriverDirectConnectDataModel *)driverDirectConnect;

//Driver Profile
@property (nonatomic, readonly) NSString *driverFullName;
@property (nonatomic, readonly) NSString *driverFirstName;
@property (nonatomic, readonly) NSString *driverRating;
@property (nonatomic, readonly) NSURL *driverPhotoUrl;

//Car Category
@property (nonatomic, readwrite) NSString *selectedCategory;
@property (nonatomic, readonly) RACarCategoryDataModel *category;
@property (nonatomic, readonly) NSString *numberOfSeats;
@property (nonatomic, readonly) BOOL shouldShowPriority;
@property (nonatomic, readonly) NSString *priority;

- (RADirectConnectRideRequest *)directConnectRideRequestWithApplePayToken:(NSString *)applePayToken address:(RAAddress *)address;

@end
