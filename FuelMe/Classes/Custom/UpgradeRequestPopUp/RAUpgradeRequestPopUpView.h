//
//  RAUpgradeRequestPopUpView.h
//  Ride
//
//  Created by Marcos Alba on 13/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RAPopUpView.h"

@interface RAUpgradeRequestPopUpView : RAPopUpView

@property (nonatomic, readonly) NSString *rideID;

+ (RAUpgradeRequestPopUpView*)showUpgradeRequestPopUpViewWithDelegate:(id<RAPopUpViewDelegate>)delegate source:(NSString*)source target:(NSString*)target surgeFactor:(double)surgeFactor rideID:(NSString*)rideID;

@end
