//
//  SMTwitterItem.m
//  Ride
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SMTwitterItem.h"

#import <Social/Social.h>

@implementation SMTwitterItem

- (instancetype)init
{
    self = [super initWithTitle:@"Twitter" andImagenamed:@"promoTwitterIcon"];
    if (self) {
        
    }
    return self;
}

-(void)shareText:(NSString *)text link:(NSString *)link title:(NSString*)title fromViewController:(UIViewController *)vc withCompletion:(ShareCompletionBlock)handler{
    
    SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    //     if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    //     {
    SLComposeViewControllerCompletionHandler __block    completionHandler=^(SLComposeViewControllerResult result){
        
        [tweetSheet dismissViewControllerAnimated:YES completion:nil];
        
        switch(result){
            case SLComposeViewControllerResultCancelled:
            default:
            {
                //NSLog(@"Cancel");
            }
                break;
            case SLComposeViewControllerResultDone:
            {
                //NSLog(@"Post");
            }
                break;
        }
    };
    
    [tweetSheet setInitialText:text];
    [tweetSheet setCompletionHandler:completionHandler];
    [vc presentViewController:tweetSheet animated:YES completion:nil];
    //}
}

@end
