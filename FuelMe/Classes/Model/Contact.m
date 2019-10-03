//
//  Contact.m
//  Ride
//
//  Created by Abdul Rehman on 02/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "Contact.h"

#import <SDWebImage/SDWebImagePrefetcher.h>

@implementation Contact

- (instancetype)init {
    if (self = [super init]) {
        self.phoneNumbers = [NSMutableArray new];
    }
    return self;
}

- (instancetype)initWithContact:(CNContact *)contact {
    if (self = [super init]) {
        
        self.firstName = contact.givenName;
        self.lastName = contact.familyName;
        
        self.phoneNumbers = [NSMutableArray new];
        NSArray *phoneNumbers = contact.phoneNumbers;
        
        for (CNLabeledValue<CNPhoneNumber*> *tempPhone in phoneNumbers) {
            CNPhoneNumber *number = tempPhone.value;
            NSString *digits = number.stringValue;
            [self.phoneNumbers addObject:digits];
        }
        
        self.image = [UIImage imageWithData:contact.imageData];
    }
    return self;
}

- (instancetype)initWithSourceSplitFare:(SplitFare *)splitFare {
    if (self = [super init]) {
        self.firstName = splitFare.sourceRiderName;
        NSString *userPhoto = splitFare.sourceRiderPhoto;
        if ([userPhoto isKindOfClass:[NSString class]]) {
            self.imageURL = [NSURL URLWithString:userPhoto];
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[self.imageURL]];
        }
    }
    return self;
}

- (instancetype)initWithTargetContact:(NSDictionary *)dict {
    if (self = [super init]) {
        self.firstName = dict[@"targetUser"];
        NSString *userPhoto = dict[@"targetUserPhoto"];
        if ([userPhoto isKindOfClass:[NSString class]]) {
            self.imageURL = [NSURL URLWithString:userPhoto];
            [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[self.imageURL]];
        }
    }
    return self;
}

@end
