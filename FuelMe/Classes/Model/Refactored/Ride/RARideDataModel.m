//
//  RARideDataModel.m
//  RideAustin
//
//  Created by Kitos on 1/9/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAPickupManager.h"
#import "RARideDataModel.h"

@interface RARideDataModel ()

@property (nonatomic) BOOL needsToUpdateStartLocation;
@property (nonatomic) BOOL needsToUpdateEndLocation;
@property (nonatomic, strong) CLLocation *observedEndLocation;

@end

@implementation RARideDataModel

#pragma mark - Init

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    if (self = [super initWithDictionary:dictionaryValue error:error]) {
        
        if ([self.startLocation isKindOfClass:[RARideLocationDataModel class]]) {
            self.startLocation.address = self.startAddress;
            CLLocation *startAddressRefined = [RAPickupManager refinePickupLocation:[[CLLocation alloc] initWithLatitude:self.startLocationLatitude.doubleValue longitude:self.startLocationLongitude.doubleValue]];
            [self.startLocation setLocationByCoordinate:startAddressRefined.coordinate];
        }
        
        if ([self.endLocation isKindOfClass:[RARideLocationDataModel class]]) {
            self.endLocation.address = self.endAddress;
            [self.endLocation setLocationByCoordinate:CLLocationCoordinate2DMake(self.endLocationLatitude.doubleValue, self.endLocationLongitude.doubleValue)];
        }
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder: coder]) {
        CLLocationCoordinate2D startCoordinateRefined = [RAPickupManager refinePickupLocation:[[CLLocation alloc] initWithLatitude:self.startLocationLatitude.doubleValue longitude:self.startLocationLongitude.doubleValue]].coordinate;
        [self.startLocation setLocationByCoordinate:startCoordinateRefined];
        
        self.endLocation.latitude = self.endLocationLatitude;
        self.endLocation.longitude = self.endLocationLongitude;
        self.observedEndLocation = [[CLLocation alloc] initWithLatitude:self.endLocationLatitude.doubleValue longitude:self.endLocationLongitude.doubleValue];
    }
    return self;
}

#pragma mark - Read-only properties

- (BOOL)isDriverComing{
    return (self.status == RARideStatusDriverAssigned);
}

- (BOOL)isDriverArrived{
    return (self.status == RARideStatusDriverReached);
}

- (BOOL)isOnTrip{
    return (self.status == RARideStatusActive);
}

- (BOOL)isRiding{
    return ([self isOnTrip] || [self isDriverArrived] || [self isDriverComing]);
}

- (BOOL)isRiding:(RARideStatus)status{
    return (status == RARideStatusActive) || (status == RARideStatusDriverReached) || (status == RARideStatusDriverAssigned);
}

- (CLLocationCoordinate2D)startCoordinate{
    return CLLocationCoordinate2DMake(self.startLocationLatitude.doubleValue, self.startLocationLongitude.doubleValue);
}

- (CLLocationCoordinate2D)endCoordinate{
    return CLLocationCoordinate2DMake(self.endLocationLatitude.doubleValue, self.endLocationLongitude.doubleValue);
}

- (void)updateObservedDestinationWithEndLocation:(RARideLocationDataModel *)endLocation{
    self.endLocation = endLocation;
    self.endLocationLatitude = [NSNumber numberWithDouble: endLocation.coordinate.latitude];
    self.endLocationLongitude = [NSNumber numberWithDouble: endLocation.coordinate.longitude];
    self.observedEndLocation = [[CLLocation alloc] initWithLatitude:self.endLocationLatitude.doubleValue longitude:self.endLocationLongitude.doubleValue];
}

- (BOOL)isFinished {
    return (self.status == RARideStatusCompleted || self.status == RARideStatusRiderCancelled || self.status == RARideStatusDriverCancelled || self.status == RARideStatusAdminCancelled || self.status == RARideStatusNoAvailableDriver);
}

#pragma mark - JSONKeyPaths Mapping

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [super.JSONKeyPathsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:[RARideDataModel JSONKeyPaths]];
}

+ (NSDictionary *)JSONKeyPaths {
    return @{
             @"status": @"status",
             @"rider": @"rider",
             @"activeDriver" : @"activeDriver",
             
             //dates
             @"startedDate": @"startedOn",
             @"freeCancellationExpiryDate": @"freeCancellationExpiresOn",
             @"cancelledDate": @"cancelledOn",
             @"driverAcceptedDate": @"driverAcceptedOn",
             @"driverReachedDate": @"driverReachedOn",
             @"completedDate": @"completedOn",
             @"estimatedCompletionDate" : @"estimatedTimeCompletion",
             
             //locations
             @"startLocation": @"start",
             @"endLocation": @"end",

             @"startAddress" : @"startAddress",
             @"startLocationLatitude" : @"startLocationLat",
             @"startLocationLongitude" : @"startLocationLong",
             @"endAddress" : @"endAddress",
             @"endLocationLatitude" : @"endLocationLat",
             @"endLocationLongitude" : @"endLocationLong",
             
             //request
             @"requestedCarType": @"requestedCarType",
             
             //rating
             @"rating": @"rating",
             
//             @"distanceTravelled" : @"distanceTravelled",
             @"estimatedTimeToArrive" : @"estimatedTimeArrive",
             //fares
             @"totalFare": @"totalFare",
             
             //surge
             @"surgeFactor": @"surgeFactor",
             
             //fees
             @"cancellationFee": @"cancellationFee",
            
             @"freeCreditCharged": @"freeCreditCharged",
            
             @"tip": @"tip",
             @"tippingAllowed" : @"tippingAllowed",
             @"tipUntil" : @"tipUntil",
             
             @"upgradeRequest": @"upgradeRequest",
             
             @"comment": @"comment",
             
             @"paymentProvider" : @"paymentProvider",
             @"bevoBucksUrl" : @"bevoBucksUrl",
             
             //Stacked Ride
             @"precedingRide" : @"precedingRide"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)statusJSONTransformer{
    NSDictionary *statuses = @{
                             @"REQUESTED": @(RARideStatusRequested),
                             @"NO_AVAILABLE_DRIVER": @(RARideStatusNoAvailableDriver),
                             @"RIDER_CANCELLED": @(RARideStatusRiderCancelled),
                             @"DRIVER_CANCELLED": @(RARideStatusDriverCancelled),
                             @"ADMIN_CANCELLED": @(RARideStatusAdminCancelled),
                             @"DRIVER_ASSIGNED": @(RARideStatusDriverAssigned),
                             @"DRIVER_REACHED": @(RARideStatusDriverReached),
                             @"ACTIVE": @(RARideStatusActive),
                             @"COMPLETED": @(RARideStatusCompleted)
                             };
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        *success = YES;
        if ([value isKindOfClass:[NSString class]]) {
            return statuses[(NSString*)value] ?: @(RARideStatusUnknown);
        } else {
            return @(RARideStatusUnknown);
        }
    }];    
}

+ (NSValueTransformer *)startedDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)freeCancellationExpiryDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)cancelledDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)driverAcceptedDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)driverReachedDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)completedDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)estimatedCompletionDateJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)baseFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)minimumFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)normalFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)estimatedFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)distanceFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)surgeFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)timeFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)totalFareJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)bookingFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)cancellationFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)cityFeeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)subTotalJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)roundUpAmountJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)driverPaymentJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)freeCreditChargedJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)stripeCreditChargeJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)tipJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMileJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)ratePerMinuteJSONTransformer {
    return [self stringToNumberTransformer];
}

+ (NSValueTransformer *)activeDriverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RAActiveDriverDataModel.class];
}

+ (NSValueTransformer *)riderJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARiderDataModel.class];
}

+ (NSValueTransformer *)requestedCarTypeJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RACarCategoryDataModel.class];
}

+ (NSValueTransformer *)startLocationJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARideLocationDataModel.class];
}

+ (NSValueTransformer *)endLocationJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARideLocationDataModel.class];
}

+ (NSValueTransformer *)tipUntilJSONTransformer {
    return [self numberToDateTransformer];
}

+ (NSValueTransformer *)upgradeRequestJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RARideUpgradeRequestDataModel.class];
}

+ (NSValueTransformer *)precedingRideJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:RAPrecedingRideDataModel.class];
}

#pragma mark - Model Protocol

- (NSArray<NSString *> *)excludeProperties {
    //This properties are exclude because are special cases managed in
    //willStartUpdatingWithModel: and didFinishUpdatingWithModel:
    return @[@"status",@"nextStatus", @"observedEndLocation"];
}

- (void)willStartUpdatingWithModel:(RABaseDataModel *)model {
    self.nextStatus = ((RARideDataModel*)model).status;
}

- (void)didUpdatePropertyWithName:(NSString *)name fromModel:(RABaseDataModel*)model{
    RARideDataModel *rideModel = (RARideDataModel*)model;
    
    if ([name isEqualToString:@"startLocation"]) {
        self.startLocation.latitude = self.startLocationLatitude;
        self.startLocation.longitude = self.startLocationLongitude;
        self.needsToUpdateStartLocation = YES;
    }
    
    if ([name isEqualToString:@"endLocation"]) {
        self.endLocation.latitude = self.endLocationLatitude;
        self.endLocation.longitude = self.endLocationLongitude;
        self.needsToUpdateEndLocation = YES;
    }
    
    if ([name isEqualToString:@"startAddress"]) {
        if(!self.startLocation){
            self.startLocation = [RARideLocationDataModel new];
        }
        self.startLocation.address = rideModel.startAddress;
    }
    
    if ([name isEqualToString:@"startLocationLatitude"]) {
        if(!self.startLocation){
            self.startLocation = [RARideLocationDataModel new];
        }
        self.startLocation.latitude = rideModel.startLocationLatitude;
        self.needsToUpdateStartLocation = YES;
    }
    
    if ([name isEqualToString:@"startLocationLongitude"]) {
        if(!self.startLocation){
            self.startLocation = [RARideLocationDataModel new];
        }
        self.startLocation.longitude = rideModel.startLocationLongitude;
        self.needsToUpdateStartLocation = YES;
    }
    
    if ([name isEqualToString:@"endAddress"]) {
        if(!self.endLocation){
            self.endLocation = [RARideLocationDataModel new];
        }
        self.endLocation.address = rideModel.endAddress;
    }
        
    if ([name isEqualToString:@"endLocationLatitude"]) {
        if(!self.endLocation){
            self.endLocation = [RARideLocationDataModel new];
        }
        self.endLocation.latitude = rideModel.endLocationLatitude;
        self.needsToUpdateEndLocation = YES;
    }
    
    if ([name isEqualToString:@"endLocationLongitude"]) {
        if(!self.endLocation){
            self.endLocation = [RARideLocationDataModel new];
        }
        self.endLocation.longitude = rideModel.endLocationLongitude;
        self.needsToUpdateEndLocation = YES;
    }
    
}

- (void)didFinishUpdatingWithModel:(RABaseDataModel *)model {
    RARideDataModel *rideModel = (RARideDataModel*)model;
    
    if (self.needsToUpdateStartLocation) {
        CLLocationCoordinate2D startCoordinateRefined = [RAPickupManager refinePickupLocation:[[CLLocation alloc] initWithLatitude:self.startLocationLatitude.doubleValue longitude:self.startLocationLongitude.doubleValue]].coordinate;
        [self.startLocation setLocationByCoordinate:startCoordinateRefined];
    }
    
    if (self.needsToUpdateEndLocation) {
        self.observedEndLocation = [[CLLocation alloc] initWithLatitude:self.endLocationLatitude.doubleValue longitude:self.endLocationLongitude.doubleValue];
    }
    
    self.needsToUpdateEndLocation = NO;
    
    //IMPORTANT: let this change be the last so that the notification is sent after all ride object is updated.
    if (self.status != rideModel.status) {
        self.status = rideModel.status;
    }
}

@end
