//
//  RedemptionViewModel.m
//  Ride
//
//  Created by Roberto Abreu on 9/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RedemptionViewModel.h"

#import "NSDate+Utils.h"
#import "NSString+Utils.h"

@interface RedemptionViewModel ()

@property (nonatomic) RARedemption *redemption;

@end

@implementation RedemptionViewModel

#pragma - Init

- (instancetype)initWithRedemption:(RARedemption *)redemption {
    if (self = [super init]) {
        _redemption = redemption;
    }
    return self;
}

#pragma mark - Read-only properties

- (NSString *)couponCode {
    return self.redemption.codeLiteral;
}

- (NSString *)value {
    return [[NSString stringWithFormat:@"$%.2f", self.redemption.remainingValue.doubleValue] stringByReplacingOccurrencesOfString:@".00" withString:@""];
}

- (NSString *)descriptionUses {
    int remainingUses = self.redemption.maximumUses.intValue - self.redemption.timesUsed.intValue;
    if (remainingUses > 1) {
        NSNumber *remainingRides = [NSNumber numberWithInt:remainingUses];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterNoStyle];
        return [NSString stringWithFormat:[@"For your next %@ rides" localized], [numberFormatter stringFromNumber:remainingRides]];
    } else {
        return [@"For your next ride" localized];
    }
}

- (NSString *)descriptionExpiration {
    if (self.redemption.expiresOn) {
        NSInteger numberOfDays = [NSDate numberOfDaysBetweenStartDate:[NSDate trueDate] endDate:self.redemption.expiresOn];
        if (numberOfDays > 0) {
            return [NSString stringWithFormat:[@"Expires in %ld day%@" localized], (long)numberOfDays, numberOfDays > 1 ? @"s" : @""];
        } else if (numberOfDays == 0){
            return [@"Expires today" localized];
        } else {
            return [@"Expired" localized];
        }
    }
    return nil;
}

@end
