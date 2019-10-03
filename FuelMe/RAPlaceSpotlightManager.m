//
//  RASpotlightManager.m
//  Ride
//
//  Created by Roberto Abreu on 9/20/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPlaceSpotlightManager.h"

#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "NSNotificationCenterConstants.h"
#import "RAFavoritePlacesManager.h"
#import "RAPlaceSearchManager.h"
#import "RARecentPlacesManager.h"

static NSString *const kSearchableItemIdentifierFormat = @"com.rideaustin.item.%@";

@implementation RAPlaceSpotlightManager

+ (BOOL)isSpotlightAvailable {
    return [CSSearchableIndex class] && [CSSearchableIndex isIndexingAvailable];
}

+ (void)setupSearchIndex {
    
    if (![self isSpotlightAvailable]) {
        return;
    }
    
    [self cleanSearchIndexWithCompletion:^{
        NSMutableArray<CSSearchableItem*> *searchableItems = [[NSMutableArray alloc] init];
        
        for (RAFavoritePlace *place in [RAPlaceSearchManager searchablePlaces]) {
            if (place.hasKeywords) {
                CSSearchableItemAttributeSet *searchableItemAttribute = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString*)kUTTypeText];
                searchableItemAttribute.title = [NSString stringWithFormat:@"Go to %@", place.name];
                searchableItemAttribute.contentDescription = place.fullAddress;
                searchableItemAttribute.keywords = place.keywords;
                
                NSString *uniqueIdentifier = [NSString stringWithFormat:kSearchableItemIdentifierFormat, place.name];
                CSSearchableItem *searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:uniqueIdentifier domainIdentifier:@"places" attributeSet:searchableItemAttribute];
                [searchableItems addObject:searchableItem];
            }
        }
        
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error to Index places");
            }
        }];
    }];
}

+ (void)cleanSearchIndexWithCompletion:(void(^)(void))completion {
    if (![self isSpotlightAvailable]) {
        return;
    }
    
    [[CSSearchableIndex defaultSearchableIndex] deleteAllSearchableItemsWithCompletionHandler:^(NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

@end
