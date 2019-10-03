//
//  RACarCategoryDataModel.h
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RABaseDataModel.h"
#import "RACarCategoryConfigurationModel.h"
#import "RASurgeAreaDataModel.h"

@interface RACarCategoryDataModel : RABaseDataModel

@property (nonatomic, strong) NSNumber *baseFare;
@property (nonatomic, strong) NSNumber *minimumFare;
@property (nonatomic, strong) NSNumber *bookingFee;
@property (nonatomic, strong) NSNumber *cancellationFee;
@property (nonatomic, strong) NSNumber *ratePerMile;
@property (nonatomic, strong) NSNumber *ratePerMinute;
@property (nonatomic, strong) NSNumber *maxPersons;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *carCategory;
@property (nonatomic, strong) NSString *catDescription;
@property (nonatomic, strong) NSURL    *mapIconUrl;
@property (nonatomic, strong) NSURL    *plainIconUrl;
@property (nonatomic, strong) NSURL    *sliderIconUrl;
@property (nonatomic, strong) NSNumber *order;
@property (nonatomic, strong) NSNumber *raFeeFactor;
@property (nonatomic, readonly) NSNumber *tncFeeRate;
@property (nonatomic, readonly) NSString *processingFee;
@property (nonatomic, readonly) NSString *processingFeeText;
@property (nonatomic, readonly) RACarCategoryConfigurationModel *configuration;
@property (nonatomic, strong) NSMutableArray<RASurgeAreaDataModel*> *surgeAreas;

- (BOOL)hasBoundaryRestriction;
- (BOOL)allowedBoundaryContainsCoordinate:(CLLocationCoordinate2D)coordinate;
- (BOOL)disableTipping;
- (BOOL)hasCancellationFee;
- (BOOL)hasAvailabilityRestriction;
- (NSString *)zeroFareLabel;
- (NSNumber *)baseFareApplyingSurge;
- (NSNumber *)minimumFareApplyingSurge;
- (NSNumber *)ratePerMinuteApplyingSurge;
- (NSNumber *)ratePerMileApplyingSurge;

@end

@interface RACarCategoryDataModel (SurgeArea)

- (BOOL)hasPriority;
- (RASurgeAreaDataModel *)highestSurgeArea;
- (void)processSurgeAreas:(NSArray<RASurgeAreaDataModel *> *)surgeAreas;
- (void)clearSurgeAreas;
- (double)factorForHighestSurgeArea;

@end

/*  May 30, Server 2.7
{
    active = 1;
    baseFare = "3.00";
    bookingFee = "2.00";
    cancellationFee = "6.00";
    carCategory = PREMIUM;
    cityId = 1;
    configuration = "{\"disableTipping\":true}";
    description = "Premium Car";
    iconUrl = "https://media.rideaustin.com/icon/premium.png";
    maxPersons = 4;
    minimumFare = "10.00";
    order = 3;
    processingFee = "1.00";
    processingFeeRate = 1;
    processingFeeText = "$1.00 Processing fee";
    raFeeFactor = "0.2";
    ratePerMile = "2.75";
    ratePerMinute = "0.40";
    title = PREMIUM;
    tncFeeRate = 1;
}
*/
