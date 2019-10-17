//
//  PaymentSectionItem.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentSectionItem : NSObject

@property (nonatomic) NSString *header;
@property (nonatomic) NSArray *rowItems;
@property (nonatomic) NSString *footer;

+ (instancetype _Nonnull)itemWithHeader:(NSString *)header footer:(NSString *)footer andRowItems:(NSArray *)rowItems;

@end
