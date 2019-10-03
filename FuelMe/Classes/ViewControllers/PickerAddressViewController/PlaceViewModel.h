//
//  PlaceViewModel.h
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaceIconTypes.h"
#import "PlaceObject.h"
#import "RAFavoritePlace.h"

typedef NS_ENUM(NSInteger, PlaceViewModelType) {
    PlaceViewModelAddHomeType,
    PlaceViewModelAddWorkType,
    PlaceViewModelSetLocationOnMapType,
    PlaceViewModelPlaceType,
    PlaceViewModelRemoveDestination
};

@interface PlaceViewModel : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readwrite) NSString *subtitle;
@property (nonatomic, readonly) PlaceIconType iconType;
@property (nonatomic, readonly) NSString *reference; //Only for GMSPlace
@property (nonatomic) NSString *zipCode;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic, readonly) PlaceViewModelType type;

- (instancetype)initWithFavoritePlace:(RAFavoritePlace *)place;
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconType:(PlaceIconType)iconType reference:(NSString *)reference type:(PlaceViewModelType)type;

- (RAPlace *)place;
- (UIImage *)icon;

@end
