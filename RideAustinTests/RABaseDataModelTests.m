//
//  RABaseDataModelTests.m
//  Ride
//
//  Created by Roberto Abreu on 27/11/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RABaseDataModel.h"
#import "RACarDataModel.h"
#import "RAFirstModelMock.h"
#import "RASecondModelMock.h"

#pragma mark - TEST CASE
@interface RABaseDataModelTests : XCTestCase

@property (nonatomic) RABaseDataModel *sampleBaseDataModel;
@property (nonatomic) RACarDataModel *sampleCarModel1;
@property (nonatomic) RACarDataModel *sampleCarModel2;

//Helper Mock
@property (nonatomic) RAFirstModelMock *firstModel;
@property (nonatomic) RAFirstModelMock *anotherFirstModel;
@property (nonatomic) RASecondModelMock *secondModel;
@property (nonatomic) RASecondModelMock *anotherSecondModel;

@end

@implementation RABaseDataModelTests

- (void)setUp {
    [super setUp];
    self.sampleBaseDataModel = [[RABaseDataModel alloc] init];
    
    NSDictionary *carDictModel = @{
                                    @"color"            : @"Gray",
                                    @"id"               : @17,
                                    @"inspectionStatus" : @"NOT_INSPECTED",
                                    @"license"          : @"123456",
                                    @"make"             : @"Aston Martin",
                                    @"uuid"             : @"17",
                                    @"model"            : @"v9 Model",
                                    @"year"             : @"2016",
                                    @"carCategories"    : @[@"REGULAR",@"SUV"],
                                    };
    
    NSError *error = nil;
    self.sampleCarModel1 = [MTLJSONAdapter modelOfClass:[RACarDataModel class] fromJSONDictionary:carDictModel error:&error];
    self.sampleCarModel2 = [MTLJSONAdapter modelOfClass:[RACarDataModel class] fromJSONDictionary:carDictModel error:&error];
    
    //First Model Mock
    self.firstModel = [RAFirstModelMock new];
    self.firstModel.modelID = @1;
    self.firstModel.sampleProp = @"SampleProp";
    self.firstModel.anExcludeProp = @"anExcludeProp";
    
    self.anotherFirstModel = [RAFirstModelMock new];
    self.anotherFirstModel.modelID = @1;
    self.anotherFirstModel.sampleProp = @"SampleProp";
    self.anotherFirstModel.anExcludeProp = @"anExcludeProp";
    
    //Second Model Mock
    self.secondModel = [RASecondModelMock new];
    self.secondModel.firstModel = self.firstModel;
    
    self.anotherSecondModel = [RASecondModelMock new];
    self.anotherSecondModel.firstModel = self.anotherFirstModel;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInstanceNotNil {
    XCTAssertNotNil(self.sampleBaseDataModel,@"Sample Instance not initialized correctly");
}

- (void)testUpdateBoolPropertyChange {
    BOOL valueBool1 = YES;
    BOOL valueBool2 = NO;
    BOOL changed = [self.sampleBaseDataModel updateBoolProperty:valueBool1 withOtherBoolProperty:valueBool2];
    XCTAssertTrue(changed,@"The property should be updated");
}

- (void)testUpdateBoolPropertyNotChange {
    BOOL valueBool1 = YES;
    BOOL valueBool2 = YES;
    BOOL valueChanged = [self.sampleBaseDataModel updateBoolProperty:valueBool1 withOtherBoolProperty:valueBool2];
    XCTAssertFalse(valueChanged,@"The Bool property should not be updated");
    
    valueBool1 = NO;
    valueBool2 = NO;
    valueChanged = [self.sampleBaseDataModel updateBoolProperty:valueBool1 withOtherBoolProperty:valueBool2];
    XCTAssertFalse(valueChanged,@"The Bool property should not be updated");
}

- (void)testDictionaryPropertyChange {
    //Different NSDictionary
    NSDictionary *dict1 = @{@"key1":@"value1",
                            @"key2":@"value2"};
    
    NSDictionary *dict2 = @{@"key3":@"value3",
                            @"key4":@"value4"};
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:dict1 withOtherProperty:dict2];
    XCTAssertTrue(valueChanged,@"The dictionary property should be updated");
    
    //Equal NSDictionary
    dict1 = @{@"key1":@"value1",
              @"key2":@"value2"};
    
    dict2 = @{@"key1":@"value1",
              @"key2":@"value2"};
    valueChanged = [self.sampleBaseDataModel updateProperty:dict1 withOtherProperty:dict2];
    XCTAssertFalse(valueChanged,@"The dictionary property should not be updated");
}

- (void)testStringPropertyChange {
    //Different NSStrings
    NSString *string1 = @"String1";
    NSString *string2 = @"String2";
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:string1 withOtherProperty:string2];
    XCTAssertTrue(valueChanged,@"The string property should be updated");
    
    //Equal NSStrings
    string1 = @"String1";
    string2 = @"String1";
    valueChanged = [self.sampleBaseDataModel updateProperty:string1 withOtherProperty:string2];
    XCTAssertFalse(valueChanged,@"The string property should not be updated");
}

- (void)testNumberPropertyChange {
    //Different NSNumbers
    NSNumber *number1 = [NSNumber numberWithInteger:1];
    NSNumber *number2 = [NSNumber numberWithInteger:2];
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:number1 withOtherProperty:number2];
    XCTAssertTrue(valueChanged,@"The number property should be updated");
    
    //Equal NSNumbers
    number1 = [NSNumber numberWithInteger:1];
    number2 = [NSNumber numberWithInteger:1];
    valueChanged = [self.sampleBaseDataModel updateProperty:number1 withOtherProperty:number2];
    XCTAssertFalse(valueChanged,@"The number property should not be updated");
}

- (void)testDataPropertyChange {
    NSString *stringSample = @"Sample";
    NSString *stringSample2 = @"Sample2";
    
    //Different NSData
    NSData *data1 = [stringSample dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data2 = [stringSample2 dataUsingEncoding:NSUTF8StringEncoding];
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:data1 withOtherProperty:data2];
    XCTAssertTrue(valueChanged,@"The data property should be changed");
    
    //Equal NSData
    data1 = [stringSample dataUsingEncoding:NSUTF8StringEncoding];
    data2 = [stringSample dataUsingEncoding:NSUTF8StringEncoding];
    valueChanged = [self.sampleBaseDataModel updateProperty:data1 withOtherProperty:data2];
    XCTAssertFalse(valueChanged,@"The data property should not be updated");
}

- (void)testArrayPropertyChange {
    //Different count
    NSArray *array1 = @[@1,@2,@3];
    NSArray *array2 = @[@1,@2];
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:array1 withOtherProperty:array2];
    XCTAssertTrue(valueChanged,@"The array property should be changed");
    
    //Equal count - different values
    array1 = @[@1,@2,@3];
    array2 = @[@1,@2,@4];
    valueChanged = [self.sampleBaseDataModel updateProperty:array1 withOtherProperty:array2];
    XCTAssertTrue(valueChanged,@"The array property should be changed");
    
    //Equals values
    array1 = @[@1,@2,@3];
    array2 = @[@1,@2,@3];
    valueChanged = [self.sampleBaseDataModel updateProperty:array1 withOtherProperty:array2];
    XCTAssertFalse(valueChanged,@"The array property should not be changed");
}

- (void)testDatePropertyChange {
    //Different Date
    NSDate *date1 = [NSDate distantPast];
    NSDate *date2 = [NSDate distantFuture];
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:date1 withOtherProperty:date2];
    XCTAssertTrue(valueChanged,@"The date property should be updated");
    
    //Equal Date
    date1 = [NSDate date];
    date2 = [date1 copy];
    valueChanged = [self.sampleBaseDataModel updateProperty:date1 withOtherProperty:date2];
    XCTAssertFalse(valueChanged,@"The date property should not be updated");
}

- (void)testImagePropertyChange {
    //Different Images
    UIImage *image1 = [UIImage imageNamed:@"credits-available-icon"];
    UIImage *image2 = [UIImage imageNamed:@"credits-no-balance-icon"];
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:image1 withOtherProperty:image2];
    XCTAssertTrue(valueChanged,@"The image property should be changed");
    
    image1 = [UIImage imageNamed:@"credits-available-icon"];
    image2 = [UIImage imageNamed:@"credits-available-icon"];
    valueChanged = [self.sampleBaseDataModel updateProperty:image1 withOtherProperty:image2];
    XCTAssertFalse(valueChanged,@"The image property should not be changed");
}

- (void)testURLPropertyChange {
    NSURL *url1 = [NSURL URLWithString:@"http://rideaustin.com"];
    NSURL *url2 = [NSURL URLWithString:@"http://rideaustin1.com"];
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:url1 withOtherProperty:url2];
    XCTAssertTrue(valueChanged,@"The url property should be changed");
    
    url1 = [NSURL URLWithString:@"http://rideaustin.com"];
    url2 = [NSURL URLWithString:@"http://rideaustin.com"];
    valueChanged = [self.sampleBaseDataModel updateProperty:url1 withOtherProperty:url2];
    XCTAssertFalse(valueChanged,@"The url property should not be changed");
}

- (void)testNilProperty {
    NSURL *url1 = nil;
    NSURL *url2 = nil;
    BOOL valueChanged = [self.sampleBaseDataModel updateProperty:url1 withOtherProperty:url2];
    XCTAssertFalse(valueChanged, @"The property should not be changed, because are nil");
    
    url2 = [NSURL URLWithString:@"http://rideaustin.com"];
    valueChanged = [self.sampleBaseDataModel updateProperty:url1 withOtherProperty:url2];
    XCTAssertTrue(valueChanged, @"The property should be changed, because url2 has a value");
}

#pragma mark - Test udpateChange:
// In this section, we're going to use a child model of RABaseDataModel to test
// the functionality of the method.
// A change occur when two property has different values, no take into account the reference.

- (void)testThatCarModelNotUpdateChangesWithAnotherCarModel {
    BOOL change = [self.sampleCarModel1 updateChanges:self.sampleCarModel2];
    XCTAssertFalse(change, @"Should not be any change, because the model has the same values");
}

- (void)testThatCarModelUpdateChangesWithAnotherCarModel {
    self.sampleCarModel2.model = @"Suzuki";
    self.sampleCarModel2.make = @"MakeSuzuki";
    BOOL change = [self.sampleCarModel1 updateChanges:self.sampleCarModel2];
    XCTAssertTrue(change, @"Should be True, because the properties has changed");
    XCTAssertEqualObjects(self.sampleCarModel1.model, @"Suzuki");
    XCTAssertEqualObjects(self.sampleCarModel1.make, @"MakeSuzuki");
}

- (void)testThatDifferentTypeOfModelNotCauseChange {
    BOOL change = [self.sampleCarModel1 updateChanges:self.sampleBaseDataModel];
    XCTAssertFalse(change, @"Should not be any change, because the model are different");
}

- (void)testThatReferenceModelChange {
    self.anotherSecondModel.firstModel.sampleProp = @"New Value";
    BOOL change = [self.secondModel updateChanges:self.anotherSecondModel];
    XCTAssertTrue(change, @"Should be True, because the value of the reference has changed");
}

- (void)testThatModelWithReferenceNotChangeIsPerform {
    BOOL change = [self.secondModel updateChanges:self.anotherSecondModel];
    XCTAssertFalse(change, @"Should not be any change, because not value changed");
}

- (void)testThatAnExcludePropertyIsNotUpdate {
    self.anotherFirstModel.anExcludeProp = @"Anyway will be exclude";
    [self.firstModel updateChanges:self.anotherFirstModel];
    XCTAssertEqualObjects(self.firstModel.anExcludeProp, @"anExcludeProp",@"The property should not be updated, because is an exclude property");
}

- (void)testThatDidFinishUpdatingIsCalled {
    [self.firstModel updateChanges:self.anotherFirstModel];
    XCTAssertTrue(self.firstModel.didFinishUpdating, @"The didFinishUpdatingWithModel: must be called");
}

- (void)testThatPerformCustomUpdateIsCalled {
    [self.firstModel updateChanges:self.anotherFirstModel];
    XCTAssertTrue(self.firstModel.didPerformCustomUpdate, @"The performCustomUpdateWithModel: must be called");
}

- (void)testThatWillStartUpdatingIsCalled {
    [self.firstModel updateChanges:self.anotherFirstModel];
    XCTAssertTrue(self.firstModel.didStartUpdatingWithModel, @"The willStartUpdatingWithModel: must be called");
}

- (void)testThatDidUpdatePropertyIsCalled {
    self.anotherFirstModel.sampleProp = @"Change Prop";
    [self.firstModel updateChanges:self.anotherFirstModel];
    XCTAssertTrue(self.firstModel.didPropertyUpdated, @"The didUpdatePropertyWithName:fromModel: must be called");
}

@end
