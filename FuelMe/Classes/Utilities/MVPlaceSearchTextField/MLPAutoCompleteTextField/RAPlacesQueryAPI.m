//
//  RAPlacesQueryAPI.m
//  Ride
//
//  Created by Theodore Gonzalez on 6/1/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "RAPlacesQueryAPI.h"
#import "RAMacros.h"
#import <GooglePlaces/GooglePlaces.h>
#import "CLLocation+isValid.h"
#import "ConfigurationManager.h"
#import "LocationService.h"
#import "PlaceObject.h"
#import "NSArray+Utils.h"
@interface RAPlacesQueryAPI()
@property (nonatomic, weak) GMSMapView *mapview;
@property (nonatomic, strong) GMSPlacesClient *client;
@end

@implementation RAPlacesQueryAPI

- (instancetype)initWithMapView:(GMSMapView *)mapView {
    self = [super init];
    if (self) {
        self.mapview = mapView;
        self.client = [GMSPlacesClient sharedClient];
    }
    return self;
}

@end

@implementation RAPlacesQueryAPI(MLPAutoCompleteTextFieldDataSource)

- (void)autoCompleteQuery:(NSString *)query possibleCompletionsForString:(NSString *)string completionHandler:(void (^)(NSArray<PlaceObject *> *))handler {
    [NSObject cancelPreviousPerformRequestsWithTarget:self.client selector:@selector(autocompleteQuery:bounds:filter:callback:) object:self];
    if (query.length > 0) {
        GMSAutocompleteFilter *filter = [GMSAutocompleteFilter new];
        filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
        [self.client autocompleteQuery:query bounds:self.safeBounds filter:filter callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
            if (error) {
                DBLog(@"Autocomplete error %@", [error localizedDescription]);
                handler(nil);
                return;
            }
            
            if (results.count > 0) {
                NSArray<PlaceObject *> *arrfinal = [results mapWithBlock:^id _Nullable(GMSAutocompletePrediction * _Nonnull p, BOOL * _Nonnull stop) {
                    return [[PlaceObject alloc] initWithFullText:p.attributedFullText
                                                     primaryText:p.attributedPrimaryText
                                                   secondaryText:p.attributedSecondaryText
                                                         placeID:p.placeID
                                                           types:p.types];
                }];
                handler(arrfinal);
            } else {
                handler(nil);
            }
        }];
    }
}

/**
 *  bias by priority [ user's map, user's location, current city center, default city ]
 */
- (GMSCoordinateBounds *)safeBounds {
    //FIX RA-6957 replaced self.mapview.myLocation with LocationService to avoid issues on my current location
    CLLocationCoordinate2D userCoordinate = [LocationService sharedService].myLocation.coordinate;
    CLLocationCoordinate2D userView = self.mapview.camera.target;
    CLLocationCoordinate2D currentCityCenter = [ConfigurationManager shared].global.currentCity.cityCenter.location.coordinate;
    CLLocationCoordinate2D defaultCity = CLLocationCoordinate2DMake(30.271318, -97.749334);
    
    BOOL hasUser = [CLLocation isCoordinateNonZero:userCoordinate];
    BOOL hasMap  = [CLLocation isCoordinateNonZero:userView];
    BOOL hasCity = [CLLocation isCoordinateNonZero:currentCityCenter];
    
    if (hasMap) {
        return [[GMSCoordinateBounds alloc] initWithCoordinate:userView
                                                    coordinate:userView];
    }
    
    if (hasUser) {
        return [[GMSCoordinateBounds alloc] initWithCoordinate:userCoordinate
                                                    coordinate:userCoordinate];
    }
    
    if (hasCity) {
        return [[GMSCoordinateBounds alloc] initWithCoordinate:currentCityCenter
                                                    coordinate:currentCityCenter];
    }
    
    return [[GMSCoordinateBounds alloc] initWithCoordinate:defaultCity
                                                coordinate:defaultCity];
}
         
@end
