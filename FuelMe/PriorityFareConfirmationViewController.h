//
//  PriorityFareConfirmationViewController.h
//  Ride
//
//  Created by Roberto Abreu on 3/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"
#import "RACarCategoryDataModel.h"

typedef void(^PriorityFareConfirmed)(BOOL accepted);

@interface PriorityFareConfirmationViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UILabel *lblSurgeFactor;
@property (weak, nonatomic) IBOutlet UILabel *lblMinimumFare;
@property (weak, nonatomic) IBOutlet UILabel *lblMin;
@property (weak, nonatomic) IBOutlet UILabel *lblMile;
@property (copy, nonatomic) PriorityFareConfirmed handler;

#pragma mark - IBOutlets Confirmation SubScreen
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmationTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblNumberToType;
@property (weak, nonatomic) IBOutlet UITextField *txtFirstNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtSecondNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblDot;
@property (weak, nonatomic) IBOutlet UILabel *lblNormalFareTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnConfirmation;

#pragma mark - Initializer
- (id)initWithCategory:(RACarCategoryDataModel*)category;

@end
