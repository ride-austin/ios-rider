//
//  RADriverTypeDataModel.h
//  Ride
//
//  Created by Carlos Alcala on 12/28/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"
#import "ConfigAlert.h"

@interface RADriverTypeDataModel : RABaseDataModel

/** sample response
 {
     availableInCategories =         (
         PREMIUM,
         LUXURY
     );
     cityId = 1;
     enabled = 1;
     configuration = "{\"penalizeDeclinedRides\":false}";
     createdDate = 1476779565000;
     description = "WOMEN ONLY";
     name = "WOMEN_ONLY";
     updatedDate = 1476779565000;
     displaySubtitle
 }
**/

//@property (nonatomic) RADriverType type;//--> generated based on name
@property (nonatomic, readonly) NSNumber *cityID;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *menuTitle;
@property (nonatomic, readonly) NSURL    *iconUrl;
@property (nonatomic, readonly) NSURL    *menuIconUrl;
@property (nonatomic, readonly) NSString *driverTypeDescription;
@property (nonatomic, readonly) NSArray<NSString *> *eligibleCategories;
@property (nonatomic, readonly) NSArray<NSString *> *availableInCategories;
@property (nonatomic, readonly, nullable) NSString *displayTitle;
@property (nonatomic, readonly) NSString *displaySubtitle;
@property (nonatomic, readonly) ConfigAlert *unknownGenderAlert;
@property (nonatomic, readonly) ConfigAlert *ineligibleGenderAlert;
@property (nonatomic, readonly, nullable) NSArray<NSString *> *eligibleGenders;

@end
