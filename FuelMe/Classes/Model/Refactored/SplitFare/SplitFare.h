//
//  SplitFare.h
//  Ride
//
//  Created by Abdul Rehman on 12/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

typedef NS_ENUM(NSUInteger, SFStatus) {
    SFStatusAccepted,
    SFStatusDeclined,
    SFStatusRequested,
    SFStatusInvalid
};

@interface SplitFare : RABaseDataModel

@property (nonatomic,strong) NSNumber *rideID;
@property (nonatomic,strong) NSString *riderName;
@property (nonatomic,strong) NSString *riderPhoto;
@property (nonatomic,strong) NSString *sourceRiderName;
@property (nonatomic,strong) NSString *sourceRiderPhoto;
@property (nonatomic,assign) SFStatus status;

@end
