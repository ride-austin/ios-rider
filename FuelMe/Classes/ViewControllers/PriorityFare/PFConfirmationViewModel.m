//
//  PFConfirmationViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 10/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DNA.h"
#import "PFConfirmationViewModel.h"
#import "NSString+Utils.h"
#import "RACarCategoryDataModel.h"

#define kDarkGrayTitle [UIColor colorWithRed:44.0/255.0 green:50.0/255.0 blue:60.0/255.0 alpha:1]
#define kLightGrayTitle [UIColor colorWithRed:132.0/255.0 green:135.0/255.0 blue:139.0/255.0 alpha:1]

@interface PFConfirmationViewModel()

@property (strong, nonatomic, readonly) RACarCategoryDataModel *category;

@end

@implementation PFConfirmationViewModel

- (instancetype)initWithCategory:(RACarCategoryDataModel *)category {
    if (self = [super init]) {
        _category = category;
        _surgeFactor = @(self.category.factorForHighestSurgeArea);
    }
    return self;
}

+ (instancetype)viewModelWithCategory:(RACarCategoryDataModel *)category {
    return [[self alloc] initWithCategory:category];
}

//1.90
- (NSString *)twoDecimalPlace {
    NSNumberFormatter *twoDecimalPlaceFormatter = [NSNumberFormatter new];
    twoDecimalPlaceFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    twoDecimalPlaceFormatter.roundingIncrement = @(0.01);
    return [twoDecimalPlaceFormatter stringFromNumber:self.surgeFactor];
}

//90
- (NSString *)decimalToType {
    NSNumberFormatter *decimalOnlyFormatter = [NSNumberFormatter new];
    decimalOnlyFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    decimalOnlyFormatter.roundingIncrement = @(0.01);
    decimalOnlyFormatter.maximumIntegerDigits = 0;
    decimalOnlyFormatter.decimalSeparator = @"";
    return [decimalOnlyFormatter stringFromNumber:self.surgeFactor];
}

//1
- (NSString *)wholeNumberToType {
    NSNumberFormatter *intOnlyFormatter = [NSNumberFormatter new];
    intOnlyFormatter.roundingMode = NSNumberFormatterRoundFloor;
    intOnlyFormatter.roundingIncrement = @(1);
    intOnlyFormatter.maximumFractionDigits = 0;
    //1
    return [intOnlyFormatter stringFromNumber:self.surgeFactor];
}

//labels
- (NSString *)title {
    return [@"Priority Fare" localized];
}

- (NSString *)surgeFactorText {
    return [NSString stringWithFormat:@"%@x", self.twoDecimalPlace];
}

- (NSString *)numberToTypeDescription {
    return [NSString stringWithFormat:[@"Type (%@.%@)\nTo confirm your priority multiplier" localized], self.wholeNumberToType,  self.decimalToType];
}

- (NSAttributedString *)minimumFare {
    double minimumFare = [[self.category minimumFareApplyingSurge] doubleValue];
    NSMutableAttributedString *minimumFareAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:[@"MINIMUM_FARE_PF_VALUE" localized],minimumFare]];
    NSRange rangeMinimumFare = [minimumFareAttr.string rangeOfString:[@"MINIMUM_FARE_PF_TITLE" localized]];
    [minimumFareAttr addAttribute:NSForegroundColorAttributeName value:kLightGrayTitle range:rangeMinimumFare];
    [minimumFareAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:FontTypeLight size:12.0] range:rangeMinimumFare];
    return minimumFareAttr;
}

- (NSAttributedString *)min {
    double ratePerMin = [[self.category ratePerMinuteApplyingSurge] doubleValue];
    NSMutableAttributedString *minAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:[@"MIN_PF_VALUE" localized],ratePerMin]];
    NSRange rangeMin = [minAttr.string rangeOfString:[@"MIN_PF_TITLE" localized]];
    [minAttr addAttribute:NSForegroundColorAttributeName value:kLightGrayTitle range:rangeMin];
    [minAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:FontTypeLight size:12.0] range:rangeMin];
    return minAttr;
}

- (NSAttributedString *)mile {
    double ratePerMile = [[self.category ratePerMileApplyingSurge] doubleValue];
    NSMutableAttributedString *mileAttr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:[@"MILE_PF_VALUE" localized],ratePerMile]];
    NSRange rangeMile = [mileAttr.string rangeOfString:[@"MILE_PF_TITLE" localized]];
    [mileAttr addAttribute:NSForegroundColorAttributeName value:kLightGrayTitle range:rangeMile];
    [mileAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:FontTypeLight size:12.0] range:rangeMile];
    return mileAttr;
}

- (BOOL)isValidWholeNumber:(NSString *)wholeNumber andDecimal:(NSString *)decimal {
    NSString *currentEntry = [NSString stringWithFormat:@"%@.%@", wholeNumber,decimal];
    NSString *required = [NSString stringWithFormat:@"%@.%@",self.wholeNumberToType, self.decimalToType];
    return [required compare:currentEntry options:NSNumericSearch] == NSOrderedSame;
}

@end
