//
//  RARiderDataModel.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RARiderDataModel.h"

#import "ConfigurationManager.h"
#import "PersistenceManager.h"
#import "RARiderAPI.h"

@interface RARiderDataModel()

@property (nonatomic) NSString *preferredPaymentMethodString;

@end

@implementation RARiderDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RARiderDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"type" : @"type",
             @"user" : @"user",
             @"charity": @"charity",
             @"unpaidBalance" : @"unpaid"
            };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)charityJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RACharityDataModel.class];
}

@end

#pragma mark - Cards

@implementation RARiderDataModel (Cards)

- (void)setPrimaryCard:(RACardDataModel *)card withCompletion:(RARiderUpdateCards)handler{
    __weak __typeof__(self) weakself = self;
    [RARiderAPI setPrimaryCard:card toRider:self.modelID.stringValue withCompletion:^(NSError *error) {
        if (!error) {
            RACardDataModel *primaryCard = [self primaryCard];
            primaryCard.primary = @(NO);
            card.primary = [NSNumber numberWithBool:YES]; //Supposing that this card has been get previously from self.cards array
            weakself.preferredPaymentMethod = PaymentMethodPrimaryCreditCard;
        }
        if (handler) {
            handler(error);
        }
    }];
}

- (void)addCard:(NSString *)cardToken withCompletion:(RARiderGetCardBlock)handler{
    __weak RARiderDataModel *weakSelf = self;
    [RARiderAPI addCardForRider:self.modelID.stringValue token:cardToken withCompletion:^(RACardDataModel *card, NSError *error) {
        if (!error) {
            NSMutableArray *ma = [NSMutableArray arrayWithArray:weakSelf.cards];
            [ma addObject:card];
            weakSelf.cards = [NSArray arrayWithArray:ma];
        }
        if (handler) {
            handler(card,error);
        }
    }];
}

- (void)deleteCard:(RACardDataModel *)card withCompletion:(RARiderUpdateCards)handler{
    __weak RARiderDataModel *weakSelf = self;
    [RARiderAPI deleteCard:card fromRider:self.modelID.stringValue withCompletion:^(NSError *error) {
        if (!error) {
            //Not really needed because caller is reloading cards ...
            NSMutableArray *ma = [NSMutableArray arrayWithArray:weakSelf.cards];
            [ma removeObject:card];
            weakSelf.cards = [NSArray arrayWithArray:ma];
        }
        if (handler) {
            handler(error);
        }
    }];
}

- (BOOL)hasValidCard {
    for (RACardDataModel* card in self.cards) {
        if (![card.cardExpired boolValue]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasPrimaryCard {
    return self.primaryCard != nil;
}

- (RACardDataModel *)primaryCard{
    for (RACardDataModel *card in self.cards) {
        if ([card.primary boolValue]) {
            return card;
        }
    }
    return nil;
}

@end

@implementation RARiderDataModel (OtherPaymentMethods)

- (void)configureUserPreference {
    _preferredPaymentMethodString = [PersistenceManager cachedPreferredPaymentMethod];
}

- (PaymentMethod)preferredPaymentMethod {
    if ([self.preferredPaymentMethodString isEqualToString:@"BEVO_BUCKS"] && [ConfigurationManager shared].global.ut.payWithBevoBucks.enabled) {
        return PaymentMethodBevoBucks;
    } else if ([self.preferredPaymentMethodString isEqualToString:@"CREDIT_CARD"]) {
        return PaymentMethodPrimaryCreditCard;
    } else if ([self.preferredPaymentMethodString isEqualToString:@"APPLE_PAY"]) {
        return PaymentMethodApplePay;
    } else {
        return PaymentMethodUnspecified;
    }
}

- (void)setPreferredPaymentMethod:(PaymentMethod)paymentMethod {
    switch (paymentMethod) {
        case PaymentMethodPrimaryCreditCard:
        case PaymentMethodUnspecified:
            _preferredPaymentMethodString = @"CREDIT_CARD";
            break;
            
        case PaymentMethodApplePay:
            _preferredPaymentMethodString = @"APPLE_PAY";
            break;
            
        case PaymentMethodBevoBucks:
            _preferredPaymentMethodString = @"BEVO_BUCKS";
            break;
    }
    [PersistenceManager savePreferredPaymentMethod:_preferredPaymentMethodString];
}

@end
