//
//  RAAddress.m
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAAddress.h"

#import <AddressBookUI/AddressBookUI.h>

@interface GMSAddress (Address)

- (NSString *)address;

@end

@implementation RAAddress

- (instancetype)initWithGMSAddress:(GMSAddress *)gmsAddress {
    if (self = [super init]) {
        NSString *address = [gmsAddress address];
        NSString *fullAddress = nil;
        NSString *city = gmsAddress.locality;
        
        NSArray *lines = gmsAddress.lines;
        if (lines) {
            fullAddress = [lines componentsJoinedByString:@"\n"];
        }
        
        if (!fullAddress) {
            fullAddress = [address stringByAppendingFormat:@", %@",city];
        }
        
        _address = address;
        _fullAddress = fullAddress;
        _zipCode = gmsAddress.postalCode;
    }
    return self;
}

- (instancetype)initWithPlaceMark:(CLPlacemark *)placemark {
    if (self = [super init]) {
        NSString *address = placemark.thoroughfare;
        NSString *fullAddress = [placemark.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
        if (fullAddress.length == 0) {
            fullAddress =  ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);
        }
        
        if (!fullAddress) {
            fullAddress = placemark.name;
        }
        
        if (!fullAddress) {
            fullAddress = placemark.locality;
        }
        
        _address = address;
        _fullAddress = fullAddress;
        _zipCode = placemark.postalCode;
    }
    return self;
}

@end

@implementation GMSAddress (Address)

- (NSString *)address {
    if (self.thoroughfare) {
        return self.thoroughfare;
    } else if (self.subLocality) {
        return self.subLocality;
    } else if (self.locality) {
        return self.locality;
    } else if (self.administrativeArea) {
        return self.administrativeArea;
    } else if (self.country) {
        return self.country;
    } else {
        return @"Unknown thoroughfare";
    }
}

@end
