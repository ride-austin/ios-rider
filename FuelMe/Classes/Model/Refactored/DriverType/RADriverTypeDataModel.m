//
//  RADriverTypeDataModel.m
//  Ride
//
//  Created by Carlos Alcala on 12/28/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RADriverTypeDataModel.h"

static NSString *const kDataModelDriverWomenOnly  = @"WOMEN_ONLY";

@implementation RADriverTypeDataModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return
    @{
      @"cityID" : @"cityID",
      @"name" : @"name",
      @"eligibleCategories" : @"eligibleCategories",
      @"displayTitle" : @"displayTitle",
      @"displaySubtitle" : @"displaySubtitle",
      @"unknownGenderAlert" : @"unknownGenderAlert",
      @"ineligibleGenderAlert" : @"ineligibleGenderAlert",
      @"eligibleGenders" : @"eligibleGenders",
      @"title" : @"title",
      @"menuTitle" : @"menuTitle",
      @"iconUrl" : @"iconUrl",
      @"menuIconUrl" : @"menuIconUrl",
      @"availableInCategories" : @"availableInCategories",
      @"driverTypeDescription" : @"description"
      };
}

+ (NSValueTransformer *)unknownGenderAlertJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ConfigAlert.class];
}

+ (NSValueTransformer *)ineligibleGenderAlertJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:ConfigAlert.class];
}

@end
