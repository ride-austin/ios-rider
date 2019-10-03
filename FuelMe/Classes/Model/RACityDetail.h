//
//  RACityDetail.h
//  Ride
//
//  Created by Roberto Abreu on 20/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RABaseDataModel.h"
#import "RAInspectionStickerDetail.h"
#import "TNCScreenDetail.h"

@interface RACityDetail : RABaseDataModel

@property (nonatomic) NSString *cityDescription;
@property (nonatomic) NSURL *driverRegistrationTermsURL;
@property (nonatomic) BOOL isEnabled;
@property (nonatomic) NSURL *logoURLwhite;
@property (nonatomic) NSNumber *minCarYear;
@property (nonatomic) NSString *addCarSuccessMessage;
@property (nonatomic) NSArray<NSString *> *requirements;
@property (nonatomic) RAInspectionStickerDetail *inspectionSticker;
@property (nonatomic) TNCScreenDetail *tnc;

@end
