//
//  PickerAddressViewController.h
//  Ride
//
//  Created by Roberto Abreu on 9/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PickerAddressViewModel.h"

#import <GoogleMaps/GMSMapView.h>

@class PickerAddressViewController;

@protocol PickerAddressDelegate

- (void)pickerAddressViewController:(PickerAddressViewController *)pickerAddressViewController didSelectPlace:(RAPlace *)place;
- (void)didRemoveDestinationFromPickerAddressViewController:(PickerAddressViewController *)pickerAddressViewController;

@end

@interface PickerAddressViewController : UIViewController

//IBOulets
@property (weak, nonatomic) IBOutlet UITableView *tblPlaces;

//Properties
@property (assign, nonatomic, readonly) RAPickerAddressFieldType pickerAddressFieldType;
@property (weak, nonatomic) id<PickerAddressDelegate> delegate;

//Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTblPlacesTop;

- (instancetype)initWithDelegate:(id<PickerAddressDelegate>)delegate addressFieldType:(RAPickerAddressFieldType)pickerAddressFieldType previousAddress:(NSString *)previousAddress andMapView:(GMSMapView *)mapView;

@end
