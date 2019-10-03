//
//  PlaceViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PlaceViewModel.h"
#import "RAFavoritePlace.h"

@interface PlaceViewModel ()

@property (nonatomic, readwrite) NSString *title;
@property (nonatomic, readwrite) NSString *iconName;
@property (nonatomic, readwrite) NSString *reference;
@property (nonatomic, readwrite) PlaceIconType iconType;
@property (nonatomic) NSString *shortAddress;
@property (assign, nonatomic, readwrite) PlaceViewModelType type;
    
@end

@implementation PlaceViewModel

#pragma mark - Lifecycle

- (instancetype)initWithFavoritePlace:(RAFavoritePlace *)place {
    if (!place) {
        return nil;
    }
    
    //can be refactored
    PlaceIconType iconType = PlaceIconTypeDefault;
    if ([place.grayIconName isEqualToString:@"address-home-icon"]) {
        iconType = PlaceIconTypeHome;
    } else if ([place.grayIconName isEqualToString:@"address-work-icon"]) {
        iconType = PlaceIconTypeWork;
    } else if ([place.grayIconName isEqualToString:@"address-history-icon"]) {
        iconType = PlaceIconTypeHistory;
    }
    
    
    PlaceViewModel *placeViewModel = [self initWithTitle:place.name subtitle:place.shortAddress iconType:iconType reference:nil type:PlaceViewModelPlaceType];
    placeViewModel.coordinate = place.coordinate;
    placeViewModel.shortAddress = place.shortAddress;
    return placeViewModel;
}

- (instancetype)initWithPlaceObject:(PlaceObject *)placeObject {
    return [[PlaceViewModel alloc] initWithTitle:placeObject.attributedPrimaryText.string
                                        subtitle:placeObject.attributedSecondaryText.string
                                        iconType:placeObject.iconType
                                       reference:placeObject.placeID
                                            type:PlaceViewModelPlaceType];
}

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle iconType:(PlaceIconType)iconType reference:(NSString *)reference type:(PlaceViewModelType)type {
    self = [super init];
    if (self) {
        self.title = title;
        self.subtitle = subtitle;
        self.iconType = iconType;
        self.type = type;
        self.reference = reference;
    }
    return self;
}

#pragma mark - Convenience methods

- (RAPlace *)place {
    RAPlace *place = [[RAPlace alloc] init];
    place.shortAddress = self.shortAddress ?: self.title;
    place.fullAddress = self.subtitle;
    place.visibleAddress = self.title;
    place.coordinate = self.coordinate;
    return place;
}

#pragma mark - Icons

- (NSString *)imageName {
    switch (self.iconType) {
        case PlaceIconTypeDefault:return @"address-place-icon";
        case PlaceIconTypeTransit:return @"transit_icon";
        case PlaceIconTypeSelectOnMap: return @"address-location-on-map-icon";
        case PlaceIconTypeHistory: return @"address-history-icon";
        case PlaceIconTypeHome: return @"address-home-icon";
        case PlaceIconTypeWork: return @"address-work-icon";
        case PlaceIconTypeRemoveDestination: return @"address-remove-destination-icon";
    }
}

- (UIImage *)icon {
    return [UIImage imageNamed:self.imageName];
}

@end
