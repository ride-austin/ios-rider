//
//  RACardManagerMock.m
//  Ride
//
//  Created by Roberto Abreu on 5/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACardManagerMock.h"
#import "NSDictionary+JSON.h"

static NSString *kExcludeCardsKeyInCurrentRider = @"kExcludeCardsKeyInCurrentRider";

@implementation RACardManagerMock

+ (instancetype)sharedInstance {
    static RACardManagerMock *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RACardManagerMock alloc] init];
        
        //Configure Instance
        NSArray<NSString*> *arguments = [[NSProcessInfo processInfo] arguments];
        if (![arguments containsObject:kExcludeCardsKeyInCurrentRider]) {
            id cards = [NSDictionary jsonFromResourceName:@"CARDS_200"];
            sharedInstance.cards = [[MTLJSONAdapter modelsOfClass:[RACardDataModel class] fromJSONArray:cards error:nil] mutableCopy];
        }
        
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cards = [NSMutableArray array];
    }
    return  self;
}

- (void)addCardFromStripeToken:(StripeTokenResponseMock*)stripeTokenResponse {
    RACardDataModel *cardDataModel = [[RACardDataModel alloc] init];
    cardDataModel.modelID = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    cardDataModel.cardNumber = stripeTokenResponse.lastFour;
    cardDataModel.cardBrand = stripeTokenResponse.cardBrandByCVC;
    cardDataModel.cardExpired = @(NO);
    
    if (self.cards.count == 0) {
        cardDataModel.primary = @(YES);
    }
    
    [self.cards addObject:cardDataModel];
}

- (void)setPrimaryCardWithId:(NSNumber *)cardId {
    for (RACardDataModel *card in self.cards) {
        card.primary = @([card.modelID isEqualToNumber:cardId]);
    }
}

- (void)deleteCardWithId:(NSNumber *)cardId {
    for (RACardDataModel *card in [self.cards copy]) {
        if ([card.modelID isEqualToNumber:cardId]) {
            [self.cards removeObject:card];
        }
    }
}

@end
