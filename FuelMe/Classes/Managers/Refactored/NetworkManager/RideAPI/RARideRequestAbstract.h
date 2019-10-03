//
//  RARideRequestAbstract.h
//  Ride
//
//  Created by Roberto Abreu on 12/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"
#import "RACarCategoryDataModel.h"
#import "RARideLocationDataModel.h"

@interface RARideRequestAbstract : RABaseDataModel

@property (nonatomic, strong) RARideLocationDataModel *startLocation;
@property (nonatomic, strong) RACarCategoryDataModel *carCategory;
@property (nonatomic, strong) NSString *applePayToken;
@property (nonatomic, copy) NSString *paymentProvider;

- (NSDictionary *)jsonDictionary;
- (void)cleanupApplePayToken;

@end
