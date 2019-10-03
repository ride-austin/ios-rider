//
//  SMWhatsappItem.m
//  Ride
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SMWhatsappItem.h"

@implementation SMWhatsappItem

- (instancetype)init
{
    self = [super initWithTitle:@"Whatsapp" andImagenamed:@"promoWhatsappIcon"];
    if (self) {
        
    }
    return self;
}

-(void)shareText:(NSString *)text link:(NSString *)link title:(NSString*)title fromViewController:(UIViewController *)vc withCompletion:(ShareCompletionBlock)handler{
    
    NSString *textToShare = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *whatsappURLString = [NSString stringWithFormat: @"whatsapp://send?text=%@",textToShare];
    NSURL *whatsappURL = [NSURL URLWithString:whatsappURLString];

    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
        
        if (handler) {
            handler(nil);
        }
    }
    else{
        if (handler) {
            handler([NSError errorWithDomain:@"com.rideaustin.rider.share" code:-1 userInfo:@{NSLocalizedRecoverySuggestionErrorKey: @"Whatsapp not found!"}]);
        }
    }
}

@end
