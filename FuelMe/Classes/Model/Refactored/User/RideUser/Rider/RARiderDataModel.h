//
//  RARiderDataModel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RARideUserDataModel.h"
#import "RACharityDataModel.h"
#import "RACardDataModel.h"
#import "RAUnpaidBalance.h"
#import "RideConstants.h"

@interface RARiderDataModel : RARideUserDataModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) RAUserDataModel *user;
@property (nonatomic, strong) RACharityDataModel *charity;
@property (nonatomic, strong) NSArray<RACardDataModel*> *cards;

/**
 not part of Rider object from response
 */
@property (nonatomic, strong, nullable) RAUnpaidBalance *unpaidBalance;
@property (nonatomic, strong) NSNumber *remainingCredit;

@end

typedef void(^RARiderGetCardBlock)(RACardDataModel *card, NSError *error);
typedef void(^RARiderUpdateCards)(NSError* error);

@interface RARiderDataModel (Cards)

- (void)setPrimaryCard:(RACardDataModel*)card withCompletion:(RARiderUpdateCards)handler;
- (void)addCard:(NSString*)cardToken withCompletion:(RARiderGetCardBlock)handler;
- (void)deleteCard:(RACardDataModel*)card withCompletion:(RARiderUpdateCards)handler;

- (BOOL)hasValidCard;
- (BOOL)hasPrimaryCard;
- (RACardDataModel*)primaryCard;

@end

@interface RARiderDataModel (OtherPaymentMethods)

@property (nonatomic) PaymentMethod preferredPaymentMethod;

- (void)configureUserPreference;

@end
