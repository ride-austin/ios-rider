//
//  GeocoderService.m
//  Ride
//
//  Created by Roberto Abreu on 10/26/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GeocoderService.h"

#import "ErrorReporter.h"
#import "RAFavoritePlacesManager.h"

#import <GoogleMaps/GMSGeocoder.h>

@interface GeocoderService()

@property (nonatomic) CLGeocoder *appleGeocoder;
@property (nonatomic) GMSGeocoder *googleGeocoder;
@property (nonatomic) NSCache *reverseGeocodeCache;

@end

@implementation GeocoderService

#pragma mark - Initializer

+ (instancetype)sharedInstance {
    static GeocoderService *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GeocoderService alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _appleGeocoder  = [[CLGeocoder alloc] init];
        _googleGeocoder = [[GMSGeocoder alloc] init];
        _reverseGeocodeCache = [[NSCache alloc] init];
        _reverseGeocodeCache.countLimit = 5000;
    }
    return self;
}

#pragma mark - Service Methods

- (void)reverseGeocodeForCoordinate:(CLLocationCoordinate2D)coordinate completion:(LocationServiceAddressBlock)completion {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
        NSError *error = [NSError errorWithDomain:@"com.rideaustin.reversegeo.error.invalid.location" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey : @"Cannot reverse coordinates due to an invalid location."}];
        completion(nil, error);
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    RAAddress *addressCache = [self.reverseGeocodeCache objectForKey:key];
    if (addressCache) {
        addressCache.visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:coordinate] ?: addressCache.visibleAddress;
        completion(addressCache, nil);
        return;
    }
    
    __weak GeocoderService *weakSelf = self;
    [self.googleGeocoder reverseGeocodeCoordinate:coordinate completionHandler:^(GMSReverseGeocodeResponse * _Nullable response, NSError * _Nullable error) {
        GMSAddress *addressResult = response.firstResult;
        if (error || !addressResult) {
            [ErrorReporter recordError:error withDomainName:GOOGLEReverseGeocode];
            
            //Try Apple Geocoder
            CLLocation *locationToGeocode = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            [weakSelf.appleGeocoder reverseGeocodeLocation:locationToGeocode completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                if (error) {
                    [ErrorReporter recordError:error withDomainName:APPLEReverseGeoCode];
                    completion(nil, error);
                } else {
                    if (placemarks && placemarks.count > 0) {
                        CLPlacemark *placemark = [placemarks firstObject];
                        RAAddress *address = [[RAAddress alloc] initWithPlaceMark:placemark];
                        address.location = locationToGeocode;
                        address.visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:coordinate] ?: addressCache.visibleAddress;
                        [weakSelf.reverseGeocodeCache setObject:address forKey:key];
                        completion(address, nil);
                    } else {
                        NSString *errorLog = [NSString stringWithFormat:@"Reverse Geo Code Apple no address for location: %@", locationToGeocode];
                        [ErrorReporter recordErrorDomainName:APPLEReverseGeoCode withUserInfo:@{@"log":errorLog}];
                        completion(nil, nil);
                    }
                }
            }];
            
        } else {
            RAAddress *address = [[RAAddress alloc] initWithGMSAddress:addressResult];
            address.location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
            address.visibleAddress = [RAFavoritePlacesManager visibleAddressForCoordinate:coordinate] ?: addressCache.visibleAddress;
            [weakSelf.reverseGeocodeCache setObject:address forKey:key];
            completion(address, nil);
        }
    }];
}

@end
