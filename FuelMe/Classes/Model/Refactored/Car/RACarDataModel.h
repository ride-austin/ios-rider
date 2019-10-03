//
//  RACarDatamodel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"
#import <UIKit/UIKit.h>

@interface RACarDataModel : RABaseDataModel

@property (nonatomic, strong) NSString *licensePlate;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSURL *photoURL;

//used for registering, and should come from server (URLs)
@property (nonatomic, strong) UIImage *carFrontPhoto;
@property (nonatomic, strong) UIImage *carBackPhoto;
@property (nonatomic, strong) UIImage *carInsidePhoto;
@property (nonatomic, strong) UIImage *carTrunkPhoto;
@property (nonatomic, strong) NSArray<NSString*> *carCategories;

@end

/*
 {
 carCategories =                     (
 REGULAR,
 SUV,
 PREMIUM,
 LUXURY
 );
 color = Gray;
 id = 17;
 inspectionStatus = "NOT_INSPECTED";
 license = "Kitos3-1234";
 make = "Aston Martin";
 model = "V8 Vantage";
 uuid = 17;
 year = 2016;
 }
 */
