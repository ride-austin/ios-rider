//
//  ConfigDirectConnect.h
//  Ride
//
//  Created by Roberto Abreu on 12/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface ConfigDirectConnect : RABaseDataModel

@property (nonatomic) NSString *actionTitle;
@property (nonatomic) NSString *connectDescription;
@property (nonatomic) NSString *placeholder;
@property (nonatomic) NSString *title;
@property (nonatomic) BOOL isEnabled;

@end
