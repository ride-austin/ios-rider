//
//  GeocoderService.h
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RAAddress.h"

typedef void (^LocationServiceAddressBlock)(RAAddress *  _Nullable address, NSError *_Nullable error);

@interface GeocoderService : NSObject

+ (instancetype _Nonnull)sharedInstance;
- (void)reverseGeocodeForCoordinate:(CLLocationCoordinate2D)coordinate completion:(LocationServiceAddressBlock _Nonnull)completion;

@end
