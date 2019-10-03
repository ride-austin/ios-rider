//
//  RAPaymentProvider.h
//  Ride
//
//  Created by Roberto Abreu on 8/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface RAPaymentProvider : RABaseDataModel

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *detail;
@property (assign, nonatomic) BOOL switchHidden;
@property (strong, nonatomic) NSURL *logoUrl;
@property (strong, nonatomic) NSNumber *paymentDelay;

- (instancetype)initWithName:(NSString*)name detail:(NSString*)detail switchHidden:(BOOL)switchHidden logoUrl:(NSURL*)logoUrl paymentDelay:(NSNumber*)paymentDelay;

@end
