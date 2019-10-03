//
//  DriverCarFrontViewController.m
//  Ride
//
//  Created by Carlos Alcala on 9/21/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DriverCarPhotoViewController.h"
#import "DSCarPhotoViewModel.h"
#import "UIImage+Ride.h"
#import "Ride-Swift.h"

@interface DriverCarPhotoViewController ()

@property (strong, nonatomic) RAPhotoPickerControllerManager *picturePickerManager;
@property (nonatomic) DSCarPhotoViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITextView *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imagePhoto;
@property (weak, nonatomic) DSFlowController *coordinator;

@end

@implementation DriverCarPhotoViewController

- (instancetype)initWithType:(CarPhotoType)carPhotoType andCoordinator:(DSFlowController *)coordinator {
    if (self = [super init]) {
        self.coordinator = coordinator;
        switch (carPhotoType) {
            case FrontPhoto:
                self.viewModel = coordinator.frontPhotoViewModel;
                break;
                
            case BackPhoto:
                self.viewModel = coordinator.backPhotoViewModel;
                break;
                
            case InsidePhoto:
                self.viewModel = coordinator.insidePhotoViewModel;
                break;
                
            case TrunkPhoto:
                self.viewModel = coordinator.trunkPhotoViewModel;
                break;
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    
    
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUI];
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
}

- (void)configureUI {
    self.title = self.viewModel.headerText;
    self.lblDescription.text = self.viewModel.carPhotoDescription;
    self.lblDescription.font = [UIFont fontWithName:FontTypeLight size:19.0];
    [self setPhoto:self.viewModel.cachedImage ?: self.viewModel.carPhotoDefaultImage];
}

- (void)setPhoto:(UIImage *)photo {
    self.imagePhoto.image = photo;
}
#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    // show the photo picker
    __weak typeof(self) weakSelf = self;
    
    //RA-4280 native control photo picker
    [self.picturePickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        
        BOOL valid = [weakSelf isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        weakSelf.viewModel.didConfirm = NO;
        UIImage *validImage = valid ? picture : nil;
        [weakSelf.viewModel saveImage:validImage];
        [weakSelf setPhoto:validImage];
    } cancelledBlock:nil];
}

- (void)didTapNext {
    __weak __typeof__(self) weakself = self;
    if (![[RANetworkManager sharedManager] isNetworkReachable]) {
        [RAAlertManager showErrorWithAlertItem:@"Internet Connection is down. Please try again later."
                                    andOptions:[RAAlertOption optionWithTitle:@"Network Offline" andState:StateActive]];
        return;
    }
    
    //RA-2642 - photo should be mandatory to continue
    if (!self.viewModel.cachedImage) {
        [RAAlertManager showErrorWithAlertItem:self.viewModel.validationMessage
                                    andOptions:[RAAlertOption optionWithTitle:@"Driver Signup" andState:StateActive]];
        return;
    }
    
    if (self.viewModel.didConfirm) {
        [self showNextController];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.viewModel.appName message:self.viewModel.confirmationMessage preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakself.viewModel.didConfirm = YES;
            [weakself showNextController];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (void)showNextController {
    [self.coordinator showNextScreenFromScreen:self.viewModel.screen];
}

@end
