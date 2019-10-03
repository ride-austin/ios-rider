//
//  PFConfirmationViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 10/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACarCategoryDataModel;

@interface PFConfirmationViewModel : NSObject

@property (nonatomic) NSNumber *surgeFactor;

+ (instancetype)viewModelWithCategory:(RACarCategoryDataModel *)category;

- (NSString *)title;
- (NSString *)surgeFactorText;
- (NSString *)decimalToType;
- (NSString *)wholeNumberToType;
- (NSString *)numberToTypeDescription;
- (NSAttributedString *)minimumFare;
- (NSAttributedString *)min;
- (NSAttributedString *)mile;

- (BOOL)isValidWholeNumber:(NSString *)wholeNumber andDecimal:(NSString *)decimal;

@end
