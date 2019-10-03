//
//  SMFacebookItem.m
//  Ride
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SMFacebookItem.h"

#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation SMFacebookItem

- (instancetype)init
{
    self = [super initWithTitle:@"Facebook" andImagenamed:@"promoFBIcon"];
    if (self) {
        
    }
    return self;
}

-(void)shareText:(NSString *)text link:(NSString *)link title:(NSString*)title fromViewController:(UIViewController *)vc withCompletion:(ShareCompletionBlock)handler{
    
    link = ![link hasPrefix:@"http"] ? [NSString stringWithFormat:@"https://%@",link] : link;
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:link];
//    content.contentTitle = title;
//    content.contentDescription = text;
    content.quote = text;
    [FBSDKShareDialog showFromViewController:vc
                                 withContent:content
                                    delegate:nil];

    if (handler) {
        handler(nil);
    }
}

@end
