#import "DSDriverPhotoViewModel.h"
#import "DriverPhotoViewController.h"
#import "NSString+Utils.h"
#import "Ride-Swift.h"
#import "UIImage+Ride.h"
#import "WebViewController.h"

@interface DriverPhotoViewController ()

@property (nonatomic) DSDriverPhotoViewModel *viewModel;
@property (nonatomic, strong) RAPhotoPickerControllerManager *picturePickerManager;

@end

@implementation DriverPhotoViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.viewModel.headerText];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)configureViewModel {
    self.viewModel = self.coordinator.driverPhotoViewModel;
    self.title = self.viewModel.headerText;
    if (self.viewModel.cachedImage) {
        self.photo = self.viewModel.cachedImage;
    }
}

- (void)setPhoto:(UIImage *)photo {
    _photo = photo;
    self.imagePhoto.image = photo;
}

#pragma mark- Button Action

- (IBAction)takePhotoAction:(id)sender {
    
    //RA-4280 Changed to native control
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
    __weak DriverPhotoViewController *weakSelf = self;
    [self.picturePickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        BOOL valid = [weakSelf isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        [weakSelf.viewModel saveImage:picture];
        weakSelf.viewModel.didConfirm = NO;
        weakSelf.photo = valid ? picture : nil;
        
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
    
    if (!self.photo) {
        [RAAlertManager showErrorWithAlertItem:[@"Please upload your photo to continue." localized]
                                    andOptions:[RAAlertOption optionWithTitle:[@"Driver Signup" localized] andState:StateActive]];
        return;
    }
    
    if (self.viewModel.didConfirm) {
        [self showNextRegistrationScreen];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:super.regConfig.appName
                                                                    message:self.viewModel.confirmationDescription
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *yes = [UIAlertAction actionWithTitle:[@"YES" localized] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakself.viewModel.didConfirm = YES;
            [weakself showNextRegistrationScreen];
        }];
        
        UIAlertAction *no  = [UIAlertAction actionWithTitle:[@"NO" localized] style:UIAlertActionStyleCancel handler:nil];
        [ac addAction:yes];
        [ac addAction:no];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (void)showNextRegistrationScreen {
    [self.coordinator showNextScreenFromScreen:DSScreenDriverPhoto];
}

@end
