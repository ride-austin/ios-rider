//
//  RAContactHelper.m
//  Ride
//
//  Created by Roberto Abreu on 11/11/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAContactHelper.h"
#import "ConfigurationManager.h"
#import <MessageUI/MessageUI.h>
#import "RAAlertManager.h"
@implementation RAContactHelper

+ (BOOL)hasDirectConnectEnabled {
    return [ConfigurationManager shared].global.isPhoneMaskingEnabled && [ConfigurationManager shared].global.directConnectPhone;
}

+ (NSString *)maskContactNumberWithDirectConnectIfNeeded:(NSString *)contactNumber {
    if ([RAContactHelper hasDirectConnectEnabled] && [ConfigurationManager shared].global.directConnectPhone) {
        return [ConfigurationManager shared].global.directConnectPhone;
    }
    return contactNumber;
}

+ (void)performCall:(NSString *)contactNumber {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        NSURL *callURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",contactNumber]];
        [[UIApplication sharedApplication] openURL:callURL];
    } else {
        [RAAlertManager showAlertWithTitle:@"CALL" message:contactNumber options:[RAAlertOption optionWithState:StateActive]];
    }
}

+ (void)performSMS:(NSString *)contactNumber {
    if ([MFMessageComposeViewController canSendText]) {
        NSURL *smsURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms:%@", contactNumber]];
        [[UIApplication sharedApplication] openURL:smsURL];
    } else {
        [RAAlertManager showAlertWithTitle:@"SMS" message:contactNumber options:[RAAlertOption optionWithState:StateActive]];
    }
}

@end
