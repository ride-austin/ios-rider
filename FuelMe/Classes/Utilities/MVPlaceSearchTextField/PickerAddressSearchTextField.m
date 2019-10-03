//
//  PickerAddressSearchTextField.m
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PickerAddressSearchTextField.h"
#import <KVOController/NSObject+FBKVOController.h>
#import "NSArray+Utils.h"

@implementation PickerAddressSearchTextField

- (instancetype)init {
    if (self = [super init]) {
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addObservers];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addObservers];
    }
    return self;
}

#pragma mark - Observers

- (void)addObservers {
    __weak PickerAddressSearchTextField *weakSelf = self;
    [self.KVOController observe:self keyPath:@"autoCompleteSuggestions" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        NSMutableArray *placeViewModels = (NSMutableArray*)[weakSelf.autoCompleteSuggestions mapWithBlock:^PlaceViewModel *_Nullable(PlaceObject * _Nonnull place, BOOL * _Nonnull stop) {
            return [[PlaceViewModel alloc] initWithTitle:place.attributedPrimaryText.string subtitle:place.attributedSecondaryText.string iconType:place.iconType reference:place.placeID type:PlaceViewModelPlaceType];
        }];
        
        //Setup Location on Map
        PlaceViewModel *setLocationOnMap = [[PlaceViewModel alloc] initWithTitle:@"Set Location On Map"
                                                                        subtitle:nil
                                                                        iconType:PlaceIconTypeSelectOnMap
                                                                       reference:nil
                                                                            type:PlaceViewModelSetLocationOnMapType];
        [placeViewModels addObject:setLocationOnMap];
        
        weakSelf.placeViewModelsSuggestions = placeViewModels;
    }];
}

@end
