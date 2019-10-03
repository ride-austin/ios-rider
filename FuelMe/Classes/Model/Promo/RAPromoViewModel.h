//
//  RAPromoViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConfigReferRider.h"
#import "RAPromoCode.h"

@interface RAPromoViewModel : NSObject

@property (nonatomic, readonly) NSString *downloadURL;
@property (nonatomic, readonly) NSString *detailText;
@property (nonatomic, readonly) NSString *emailBody;
@property (nonatomic, readonly) NSString *emailTitle;
@property (nonatomic, readonly) NSString *smsBody;

+ (instancetype)viewModelWithPromoCode:(RAPromoCode *)promo andTemplate:(ConfigReferRider *)temp;

@end
