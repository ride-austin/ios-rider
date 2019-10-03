//
//  RAPlacesQueryAPI.h
//  Ride
//
//  Created by Theodore Gonzalez on 6/1/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompleteTextFieldDataSource.h"
@class GMSMapView;
@interface RAPlacesQueryAPI : NSObject

- (instancetype)initWithMapView:(GMSMapView *)mapView;

@end

@interface RAPlacesQueryAPI(MLPAutoCompleteTextFieldDataSource) <MLPAutoCompleteTextFieldDataSource>

@end
