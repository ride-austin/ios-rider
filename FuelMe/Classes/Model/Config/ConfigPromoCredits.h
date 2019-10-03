//
//  ConfigPromoCredits.h
//  Ride
//
//  Created by Roberto Abreu on 9/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"

@interface ConfigPromoCredits : RABaseDataModel

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *detailTitle;
@property (nonatomic, readonly) BOOL showTotal;
@property (nonatomic, readonly) BOOL showDetail;
@property (nonatomic, readonly) NSString *termDescription;

@end
