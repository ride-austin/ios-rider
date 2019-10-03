//
//  SMessageViewController.h
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "BaseViewController.h"
#import "RecipientTypes.h"

@interface SMessageViewController : BaseViewController

@property (nonatomic) NSString * _Nullable rideID;
@property (nonatomic) NSString * _Nullable recipientName;
@property (nonatomic) RecipientType recipientType;

- (instancetype _Nonnull)initWithRideID:(NSString* _Nullable)rideID
                                 cityID:(NSNumber* _Nullable)cityID
                      withRecipientName:(NSString* _Nullable)recipient
                       andRecipientType:(RecipientType)recipientType;

@end
