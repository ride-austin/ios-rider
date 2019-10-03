//
//  CreateProfileViewController.m
//  Ride
//
//  Created by Tyson Bunch on 5/12/16
//

#import "CreateProfileViewController.h"

#import "ErrorReporter.h"
#import "NSString+Utils.h"
#import "RAMacros.h"
#import "UIImage+Ride.h"
#import "UITextField+Helpers.h"
#import "UITextField+Valid.h"
#import "WebViewController.h"

#import <AFNetworking/UIImageView+AFNetworking.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface CreateProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblAgreementTitle;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobile;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) RAPhotoPickerControllerManager *picturePickerManager;

- (NSArray*)validate;

@end

@implementation CreateProfileViewController

#pragma mark - Initializers

- (id)initWithEmail:(NSString*)email mobile:(NSString*)mobile password:(NSString*)password {
    self = [super init];
    if (self) {
        self.email = email;
        self.mobile = mobile;
        self.password = password;
    }
    return self;
}

#pragma mark - Lifecycle VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [@"CREATE A PROFILE" localized];
    self.navigationController.navigationBar.accessibilityIdentifier = self.title;
    //picker manager
    self.picturePickerManager = [RAPhotoPickerControllerManager pickerManager];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [self loadDataFromFacebook];
    }
    
    [self setupDesign];
    
    self.firstNameTextField.isAccessibilityElement = YES;
    self.lastNameTextField.isAccessibilityElement = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem defaultWithTitle:@"Next" target:self action:@selector(didTapNext)]];
}

- (void)setupDesign {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //Add Paddings to fields
    [self.firstNameTextField addLeftPadding:10.0];
    [self.lastNameTextField addLeftPadding:10.0];
    
    self.lblAgreementTitle.text = [self.lblAgreementTitle.text stringByReplacingOccurrencesOfString:@"Ride Austin" withString:[ConfigurationManager appName]];
}

#pragma mark - IBAction

- (IBAction)launchweb:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] initWithUrl:[ConfigurationManager shared].global.generalInfo.companyWebsite
                                                                         urlTitle:[NSString stringWithFormat:@"%@.com",[ConfigurationManager appName]]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)privacy:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] initWithUrl:[ConfigurationManager shared].global.generalInfo.privacyURL
                                                                         urlTitle:[@"Privacy Policy" localized]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)terms:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] initWithUrl:[ConfigurationManager shared].global.generalInfo.legalRiderURL
                                                                         urlTitle:[@"Terms & Conditions" localized]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)editPicture:(id)sender {
    [self.view endEditing:YES];
    
    // show the photo picker
    __weak typeof(self) weakSelf = self;
    
    //RA-4280 native control photo picker
    [self.picturePickerManager showPickerControllerFromViewController:self sender:sender allowEditing:YES finishedBlock:^(UIImage *image, NSError *error) {
        if (image) {
            CGFloat maxArea = 480000;
            image = [UIImage imageWithImage:image scaledToMaxArea:maxArea];
        }
        
        weakSelf.pictureView.image = image;
        [weakSelf.firstNameTextField becomeFirstResponder];
#ifdef AUTOMATION
        weakSelf.pictureView.accessibilityValue = [NSString stringWithFormat:@"%p",image];
#endif
    } cancelledBlock:nil];
}

#pragma mark - Private

- (void)didTapNext {
    [self.view endEditing:YES];
    NSArray* errors = [self validate];
    if(errors) {
        NSError *err = [NSError errorWithDomain:@"com.rideaustin.error.createprofile" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey:[errors firstObject]}];
        [RAAlertManager showErrorWithAlertItem:err
                                    andOptions:[RAAlertOption optionWithState:StateActive]];

        [[errors lastObject] becomeFirstResponder];
    } else {
        // Check if retail or not.. For now just register.
        [self showHUD];
        
        RAUserDataModel *user = [RAUserDataModel new];
        user.email = self.email;
        user.firstname = self.firstNameTextField.text;
        user.lastname = self.lastNameTextField.text;
        user.phoneNumber = self.mobile;
        user.password = self.password;
        user.picture = self.pictureView.image;
        
        __weak CreateProfileViewController *weakSelf = self;
        [[RASessionManager sharedManager] registerUser:user
                                        withCompletion:^(RAUserDataModel *user, NSError *error) {
                                            [weakSelf hideHUD];
                                            
                                            if (!error) {
                                                [weakSelf.delegate createProfileViewControllerDidRegisterSuccessfully:weakSelf];
                                            } else {
                                                [RAAlertManager showErrorWithAlertItem:error
                                                                            andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
                                            }
                                        }
         ];
    }
}

- (NSArray*)validate {
    if (self.firstNameTextField.isEmpty) {
        return @[[@"Please enter your firstname." localized], self.firstNameTextField ];
    } else if (self.firstNameTextField.text.trim.length < 2) {
        return @[[@"Please enter a valid first name with minimum two letters." localized], self.firstNameTextField ];
    } else if (!self.firstNameTextField.isValidEnglishName) {
        return @[[@"Please enter a valid first name with english letters only." localized], self.firstNameTextField ];
    }
    
    if (self.lastNameTextField.isEmpty) {
        return @[[@"Please enter your lastname." localized], self.lastNameTextField ];
    } else if (self.lastNameTextField.text.trim.length < 2) {
        return @[[@"Please enter a valid last name with minimum two letters." localized], self.lastNameTextField ];
    } else if (!self.lastNameTextField.isValidEnglishName) {
        return @[[@"Please enter a valid last name with english letters only." localized], self.lastNameTextField ];
    }
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    textField.text = textField.text.trim;
    if(textField == self.firstNameTextField) {
        [self.lastNameTextField becomeFirstResponder];
    } else if(textField == self.lastNameTextField) {
        [self didTapNext];
    }
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    //FIX RA-5903 Implement check for infinite TextField length <= 255
    BOOL shouldChange = YES;
    
    // prevent crashing undo
    if(range.length + range.location > textField.text.length) {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    shouldChange = newLength <= kTextFieldMaxLength;
    
    return shouldChange;
}

#pragma mark- Grab Facebook Data

- (void) loadDataFromFacebook {
    FBSDKGraphRequest *gr = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                              parameters:@{@"fields": @"id,name,email,first_name,last_name"}];
    
    [self showHUD];
    __weak CreateProfileViewController *weakSelf = self;
    [gr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHUD];
            });
        } else {
            NSString *firstName = result[@"first_name"];
            NSString *lastName  = result[@"last_name"];
            NSString *fbId      = result[@"id"];
            
            self.firstNameTextField.text = firstName;
            self.lastNameTextField.text = lastName;
        
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large",fbId]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
            [self.pictureView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"AddPicture"] success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.pictureView setImage:image];
                    [weakSelf hideHUD];
                });
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf hideHUD];
                });
            }];
        }
    }];
}

@end
