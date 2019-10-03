//
//  DriverSignupUnitTests.m
//  RideAustinTests
//
//  Created by Theodore Gonzalez on 11/14/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//
/*  TODO: Fix the tests 
#import <XCTest/XCTest.h>
//#import "DSFlowController.h"
#import "NSDictionary+JSON.h"
#import "ConfigGlobal.h"
#import "ColorViewController.h"
#import "DriverDisclosureViewController.h"
#import "DriverFCRAAckViewController.h"
#import "DriverFCRADisclosureViewController.h"
#import "DriverFCRARightsViewController.h"
#import "DSCarLicensePlateViewController.h"
#import "DriverCarDetailsViewController.h"
#import "DriverCarInformationViewController.h"
#import "DriverCarPhotoViewController.h"
#import "DriverInspectionStickerViewController.h"
#import "DriverPhotoViewController.h"
#import "DriverSignUpViewController.h"
#import "DriverTNCBackViewController.h"
#import "DriverTNCFrontViewController.h"
#import "InsuranceDocumentViewController.h"
#import "LicenseDocumentViewController.h"
#import "MakeViewController.h"
#import "ModelViewController.h"
#import "YearViewController.h"

const int timeout = 3;

@interface DriverSignupUnitTests : XCTestCase
@property (nonatomic) DSFlowController *interactor;
@end

@implementation DriverSignupUnitTests

- (void)setUp {
    [super setUp];
    NSError *error;
    id jsonGlobal = [NSDictionary jsonFromResourceName:@"AustinConfigGlobal"];
    id jsonCityDetail = [NSDictionary jsonFromResourceName:@"CONFIG_DRIVER_REGISTRATION_AUSTIN_200"];
    ConfigGlobal *global = [MTLJSONAdapter modelOfClass:ConfigGlobal.class fromJSONDictionary:jsonGlobal error:&error];
    RACityDetail *cityDetail = [MTLJSONAdapter modelOfClass:RACityDetail.class fromJSONDictionary:jsonCityDetail[@"driverRegistration"] error:&error];
    XCTAssertNil(error);
    
    self.interactor = self.coordinator;
    [self.interactor updateConfigCity:global.currentCity andDetail:cityDetail];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testThatNextScreenIsInitializedCorrectly {
    UIViewController *vc;
    vc = [self.interactor viewControllerNextTo:DSScreenUnknown];
    XCTAssertTrue([vc isKindOfClass:DriverSignUpViewController.class]);
    vc = [self.interactor viewControllerNextTo:DSScreenCitySelection];
    XCTAssertTrue([vc isKindOfClass:DriverPhotoViewController.class]);
    
    self.interactor.regConfig.cityDetail.tnc.isEnabled = NO;
    vc = [self.interactor viewControllerNextTo:DSScreenDriverLicense];
    XCTAssertTrue([vc isKindOfClass:DriverCarPhotoViewController.class]);
    
    self.interactor.regConfig.cityDetail.tnc.isEnabled = YES;
    vc = [self.interactor viewControllerNextTo:DSScreenDriverLicense];
    XCTAssertTrue([vc isKindOfClass:DriverTNCFrontViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenDriverPhoto];
    XCTAssertTrue([vc isKindOfClass:LicenseDocumentViewController.class]);
    
    self.interactor.regConfig.cityDetail.tnc.needsBackPhoto = NO;
    vc = [self.interactor viewControllerNextTo:DSScreenChauffeurPermitFront];
    XCTAssertTrue([vc isKindOfClass:DriverCarPhotoViewController.class]);
    
    self.interactor.regConfig.cityDetail.tnc.needsBackPhoto = YES;
    vc = [self.interactor viewControllerNextTo:DSScreenChauffeurPermitFront];
    XCTAssertTrue([vc isKindOfClass:DriverTNCBackViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenChauffeurPermitBack];
    XCTAssertTrue([vc isKindOfClass:DriverCarPhotoViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarPhotoFront];
    XCTAssertTrue([vc isKindOfClass:DriverCarPhotoViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarPhotoBack];
    XCTAssertTrue([vc isKindOfClass:DriverCarPhotoViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarPhotoInside];
    XCTAssertTrue([vc isKindOfClass:DriverCarPhotoViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarPhotoTrunk];
    XCTAssertTrue([vc isKindOfClass:DriverCarInformationViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarInfo];
    XCTAssertTrue([vc isKindOfClass:YearViewController.class]);
    
    self.interactor.regConfig.cityDetail.inspectionSticker.isEnabled = NO;
    vc = [self.interactor viewControllerNextTo:DSScreenCarYear];
    XCTAssertTrue([vc isKindOfClass:MakeViewController.class]);
    
    self.interactor.regConfig.cityDetail.inspectionSticker.isEnabled = YES;
    vc = [self.interactor viewControllerNextTo:DSScreenCarYear];
    XCTAssertTrue([vc isKindOfClass:DriverInspectionStickerViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarSticker];
    XCTAssertTrue([vc isKindOfClass:MakeViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarMake];
    XCTAssertTrue([vc isKindOfClass:ModelViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarModel];
    XCTAssertTrue([vc isKindOfClass:ColorViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarColor];
    XCTAssertTrue([vc isKindOfClass:DSCarLicensePlateViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarLicensePlate];
    XCTAssertTrue([vc isKindOfClass:DriverCarDetailsViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarIsAdded];
    XCTAssertTrue([vc isKindOfClass:InsuranceDocumentViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenCarInsurance];
    XCTAssertTrue([vc isKindOfClass:DriverFCRARightsViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenFCRARights];
    XCTAssertTrue([vc isKindOfClass:DriverFCRADisclosureViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenFCRADisclosure];
    XCTAssertTrue([vc isKindOfClass:DriverFCRAAckViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenFCRAAcknowledge];
    XCTAssertTrue([vc isKindOfClass:DriverDisclosureViewController.class]);
    
    vc = [self.interactor viewControllerNextTo:DSScreenTermsAndConditions];
    XCTAssertNil(vc);
}

- (void)testDriverPhotoViewModel {
    DSDriverPhotoViewModel *vm = self.interactor.driverPhotoViewModel;
    XCTAssertEqualObjects(vm.headerText, @"Your Driver Photo");
    XCTAssertEqualObjects(vm.confirmationDescription, @"Are you sure your Driver Profile Photo clearly shows your face and eyes without sunglasses?");
    XCTAssertFalse(vm.didConfirm);
    [vm saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vm];
    
    [vm saveImage:nil];
    [self assertCacheIsRemovedViewModel:vm];
}

- (void)testChauffeurViewModel {
    DSChauffeurViewModel *vm = self.interactor.chauffeurViewModel;
    XCTAssertEqualObjects(vm.headerText, @"Chauffeur's Permit");
    XCTAssertEqualObjects(vm.title1, @"Chauffeur's Permit");
    XCTAssertEqualObjects(vm.subtitle1, @"You’ll need a permit from the City Of Austin Ground Transportation Department. If you have this, upload a picture here:");
    XCTAssertEqualObjects(vm.title2, @"Don't have one?");
    //XCTAssertEqual(vm.subtitle2.string
    XCTAssertEqualObjects(vm.validationMessage, @"Please upload Chauffeur's Permit photo to continue");
    XCTAssertEqualObjects(vm.confirmationMessage, @"Are you sure Chauffeur's Permit is clearly shown in the photo?");
    [vm saveFrontImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vm];
    
    [vm saveFrontImage:nil];
    [self assertCacheIsRemovedViewModel:vm];
    
    XCTAssertEqual(vm.needsBackPhoto, YES);
    XCTAssertEqualObjects(vm.headerTextBack, @"Chauffeur's Permit Backside");
    XCTAssertEqualObjects(vm.title1Back, @"Chauffeur's Permit Backside");
    XCTAssertEqualObjects(vm.subtitle1Back, @"Please take a photo of the back of your permit");
    XCTAssertEqualObjects(vm.validationMessageBack, @"Please upload Chauffeur's Permit Backside photo to continue");
    XCTAssertEqualObjects(vm.confirmationMessageBack, @"Are you sure Chauffeur's Permit Backside is clearly shown in the photo?");
    [vm saveBackImage:[UIImage imageNamed:@"AppIcon"]];
    XCTestExpectation *expectation =  [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(DSChauffeurViewModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.cachedBackImage != nil;
    }] evaluatedWithObject:vm handler:nil];
    [self waitForExpectations:@[expectation] timeout:timeout];
    
    [vm saveBackImage:nil];
    XCTestExpectation *expectation2 =  [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(DSChauffeurViewModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.cachedBackImage == nil;
    }] evaluatedWithObject:vm handler:nil];
    [self waitForExpectations:@[expectation2] timeout:timeout];
}

- (void)testCarPhotoViewModel {
    DSCarPhotoViewModel *vmFront = self.interactor.frontPhotoViewModel;
    XCTAssertEqualObjects(vmFront.headerText, @"Vehicle Information");
    XCTAssertEqualObjects(vmFront.carPhotoDescription, @"Front left angle, showing the license plate");
    XCTAssertEqualObjects(vmFront.confirmationMessage, @"Are you sure the Photo is clearly taken from the Front left angle side and shows your license plate?");
    XCTAssertEqualObjects(vmFront.validationMessage, @"Please upload the car photo required to continue.");
    XCTAssertEqual(vmFront.screen, DSScreenCarPhotoFront);
    [vmFront saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vmFront];
    
    [vmFront saveImage:nil];
    [self assertCacheIsRemovedViewModel:vmFront];
    
    DSCarPhotoViewModel *vmBack = self.interactor.backPhotoViewModel;
    XCTAssertEqualObjects(vmBack.headerText, @"Vehicle Information");
    XCTAssertEqualObjects(vmBack.carPhotoDescription, @"Back right angle showing plate");
    XCTAssertEqualObjects(vmBack.confirmationMessage, @"Are you sure the Photo is clearly taken from the Back right angle side and shows your license plate?");
    XCTAssertEqualObjects(vmBack.validationMessage, @"Please upload the car photo required to continue.");
    XCTAssertEqual(vmBack.screen, DSScreenCarPhotoBack);
    [vmBack saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vmBack];
    
    [vmBack saveImage:nil];
    [self assertCacheIsRemovedViewModel:vmBack];
    
    DSCarPhotoViewModel *vmInside = self.interactor.insidePhotoViewModel;
    XCTAssertEqualObjects(vmInside.headerText, @"Vehicle Information");
    XCTAssertEqualObjects(vmInside.carPhotoDescription, @"Inside photo showing the entire back seat");
    XCTAssertEqualObjects(vmInside.confirmationMessage, @"Are you sure the Photo is clearly taken from Inside the car showing the entire back seat?");
    XCTAssertEqualObjects(vmInside.validationMessage, @"Please upload the car photo required to continue.");
    XCTAssertEqual(vmInside.screen, DSScreenCarPhotoInside);
    [vmInside saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vmInside];
    
    [vmInside saveImage:nil];
    [self assertCacheIsRemovedViewModel:vmInside];
    
    DSCarPhotoViewModel *vmTrunk = self.interactor.trunkPhotoViewModel;
    XCTAssertEqualObjects(vmTrunk.headerText, @"Vehicle Information");
    XCTAssertEqualObjects(vmTrunk.carPhotoDescription, @"Open trunk, full view");
    XCTAssertEqualObjects(vmTrunk.confirmationMessage, @"Are you sure the Photo is showing the Trunk open in full view?");
    XCTAssertEqualObjects(vmTrunk.validationMessage, @"Please upload the car photo required to continue.");
    XCTAssertEqual(vmTrunk.screen, DSScreenCarPhotoTrunk);
    [vmTrunk saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vmTrunk];
    
    [vmTrunk saveImage:nil];
    [self assertCacheIsRemovedViewModel:vmTrunk];
}

- (void)testInspectionStickerViewModel {
    DSInspectionStickerViewModel *vm = self.interactor.inspectionStickerViewModel;
    XCTAssertEqualObjects(vm.headerText, @"Registration Sticker");
    XCTAssertEqualObjects(vm.title, @"Take a photo of your Registration Sticker");
    XCTAssertEqualObjects(vm.subTitle, @"Please make sure that we can easily read all the details.");
    XCTAssertEqualObjects(vm.validationMessage, @"Please upload Registration Sticker photo to continue");
    XCTAssertEqualObjects(vm.validationDateMessage, @"Please, select a valid expiration date");
    [vm saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vm];
    
    [vm saveImage:nil];
    [self assertCacheIsRemovedViewModel:vm];
}

- (void)testLicenseViewModel {
    DSLicenseViewModel *vm = self.interactor.licenseViewModel;
    XCTAssertEqualObjects(vm.headerText, @"Driver License");
    XCTAssertEqualObjects(vm.validationMessage, @"Please upload a License Photo to continue.");
    XCTAssertEqualObjects(vm.validationDateMessage, @"Please select a valid expiration date");
    [vm saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vm];
    
    [vm saveImage:nil];
    [self assertCacheIsRemovedViewModel:vm];
}

- (void)testCarInsuranceViewModel {
    DSCarInsuranceViewModel *vm = self.interactor.insuranceViewModel;
    XCTAssertEqualObjects(vm.headerText, @"Insurance");
    XCTAssertEqualObjects(vm.validationMessage, @"Please upload an Insurance Photo to continue.");
    XCTAssertEqualObjects(vm.validationDateMessage, @"Please select a valid expiration date");
    [vm saveImage:[UIImage imageNamed:@"AppIcon"]];
    [self assertCacheIsSavedViewModel:vm];
    
    [vm saveImage:nil];
    [self assertCacheIsRemovedViewModel:vm];
}

#pragma mark -
- (void)assertCacheIsSavedViewModel:(DSViewModel *)viewModel {
    XCTestExpectation *expectation =  [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(DSDriverPhotoViewModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.isProvided == YES;
    }] evaluatedWithObject:viewModel handler:nil];
    [self waitForExpectations:@[expectation] timeout:timeout];
}
- (void)assertCacheIsRemovedViewModel:(DSViewModel *)viewModel {
    XCTestExpectation *expectation =  [self expectationForPredicate:[NSPredicate predicateWithBlock:^BOOL(DSDriverPhotoViewModel *evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.isProvided == NO;
    }] evaluatedWithObject:viewModel handler:nil];
    [self waitForExpectations:@[expectation] timeout:timeout];
}
@end
*/
