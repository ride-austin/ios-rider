//
//  RAPaymentProviderFactory.m
//  Ride
//
//  Created by Roberto Abreu on 8/21/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPaymentProviderFactory.h"

#import "ConfigurationManager.h"

@implementation RAPaymentProviderFactory

+ (RAPaymentProvider *)paymentProviderWithName:(NSString *)paymentProviderName {
    
    RAPaymentProvider *paymentProvider;
    
    if ([paymentProviderName isEqualToString:@"BEVO_BUCKS"]) {
        ConfigUTPayWithBevoBucks *configBevoBuck = [ConfigurationManager shared].global.ut.payWithBevoBucks;
        paymentProvider = [[RAPaymentProvider alloc] initWithName:@"BevoBucks"
                                                           detail:configBevoBuck.shortDescription
                                                     switchHidden:NO
                                                          logoUrl:configBevoBuck.iconLargeUrl
                                                     paymentDelay:configBevoBuck.ridePaymentDelay];
    }
    
    return paymentProvider;
}

+ (RAPaymentProvider *)paymentProviderWithPreferredPaymentMethod:(PaymentMethod)paymentMethod {
    
    if (paymentMethod == PaymentMethodBevoBucks) {
        return [RAPaymentProviderFactory paymentProviderWithName:@"BEVO_BUCKS"];
    }
    
    return nil;
}

@end
