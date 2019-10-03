//
//  DriverTNCFrontViewController.m
//  Ride
//
//  Created by Carlos Alcala on 2/9/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DSChauffeurViewModel.h"
#import "DriverTNCFrontViewController.h"
#import "NSString+Utils.h"
#import "Ride-Swift.h"
#import "UIImage+Ride.h"

@interface DriverTNCFrontViewController ()

@property (nonatomic) DSChauffeurViewModel *viewModel;
@property (nonatomic, strong) RAPhotoPickerControllerManager *picturePickerManager;
@property (weak, nonatomic) IBOutlet UITextView *tvTitle1;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitle1;
@property (weak, nonatomic) IBOutlet UITextView *tvSubtitle2;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle2;
@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;

@end

@implementation DriverTNCFrontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
    [self configureLayout];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)setPhoto:(UIImage *)photo {
    self.imagePhoto.image = photo;
}

#pragma mark - Configure Helper Functions

- (void)configureLayout {
    CGFloat padding = -self.tvSubtitle2.textContainer.lineFragmentPadding;
    self.tvSubtitle2.textContainerInset = UIEdgeInsetsMake(0,padding,0,padding);
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.chauffeurViewModel;
    if (self.viewModel.cachedFrontImage) {
        [self setPhoto:self.viewModel.cachedFrontImage];
    }
    
    self.title = self.viewModel.headerText;
    self.tvTitle1.text = self.viewModel.title1;
    self.tvSubtitle1.text = self.viewModel.subtitle1;
    self.lbTitle2.text = self.viewModel.title2;
    self.tvSubtitle2.attributedText = self.viewModel.subtitle2;
    
    [self configureAccessibility];
}

- (void)configureAccessibility {
    self.tvTitle1.accessibilityLabel = self.viewModel.title1;
    self.tvSubtitle1.accessibilityLabel = self.viewModel.subtitle1;
    self.lbTitle2.accessibilityLabel = self.viewModel.title2;
    self.tvSubtitle2.accessibilityLabel = self.viewModel.subtitle2.string;
}

#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
    __weak typeof(self) weakSelf = self;
    [self.picturePickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        BOOL valid = [weakSelf isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        weakSelf.viewModel.didConfirmFront = NO;
        UIImage *validImage = valid ? picture : nil;
        [weakSelf.viewModel saveFrontImage:validImage];
        [weakSelf setPhoto:validImage];
    } cancelledBlock:nil];
}

//
//    RA-2266
//    iPhone 6/6+, iPhone 5/5S, iPhone 4S(8 MP) - 3264 x
//    2448 pixels
//    iPhone 4, iPad 3, iPodTouch(5 MP) - 2592 x 1936 pixels
//    Size Validation based on the minium iPhone4/iPod Photo Resolutions above
//
- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

- (void)didTapNext {
    
    __weak __typeof__(self) weakself = self;
    
    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:[@"Internet Connection is down. Please try again later." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Network Offline" localized] andState:StateActive]];
        return;
    }
    
    //RA-8657 - TNC card not required
    if (!self.viewModel.cachedFrontImage) {
        RAAlertOption *option = [RAAlertOption optionWithTitle:[@"Driver Signup" localized] andState:StateActive];
        [option addAction:[RAAlertAction actionWithTitle:[@"Ok" localized] style:UIAlertActionStyleCancel handler:nil]];
        [option addAction:[RAAlertAction actionWithTitle:[@"Skip" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself showNextRegistrationScreen];
        }]];
        
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationMessage
                                    andOptions:option];
        return;
    }
    
    if (self.viewModel.didConfirmFront) {
        [self showNextRegistrationScreen];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:self.viewModel.appName
                                                                    message:self.viewModel.confirmationMessage
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakself.viewModel.didConfirmFront = YES;
            [weakself showNextRegistrationScreen];
        }];
        
        UIAlertAction *no  = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil];
        [ac addAction:yes];
        [ac addAction:no];
        
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)showNextRegistrationScreen {
    if (self.viewModel.cachedFrontImage) {
        [self.coordinator showNextScreenFromScreen:DSScreenChauffeurPermitFront];
    } else { // If no photo it means that user has skipped TNC upload
        [self.coordinator showNextScreenFromScreen:DSScreenChauffeurPermitBack];
    }
}

@end

