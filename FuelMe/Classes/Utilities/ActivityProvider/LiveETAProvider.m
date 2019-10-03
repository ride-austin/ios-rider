//
//  LiveETAProvider.m
//  Ride
//
//  Created by Robert on 15/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "LiveETAProvider.h"

@implementation LiveETAProvider

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(UIActivityType)activityType {
    return self.message;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController{
    return self.message;
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(UIActivityType)activityType {
    return self.subject;
}

@end
