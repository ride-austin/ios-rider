//
//  BaseViewController.m
//  RideAustin.com
//
//  Created by Tyson Bunch on 7/25/13.
//  Copyright (c) 2013 FuelMe, Inc. All rights reserved.
//

#import "BaseViewController.h"

#import "SMessageViewController.h"
#import "UIDevice+VersionCheck.h"

#import "GAIDictionaryBuilder.h"
#import <MessageUI/MessageUI.h>

@interface BaseViewController ()

- (void)trackWithCategory:(NSString*)category withAction:(NSString*)action withLabel:(NSString*)label withValue:(NSNumber*)value;

@end

@implementation BaseViewController

- (void)trackWithCategory:(NSString*)category withAction:(NSString*)action withLabel:(NSString*)label withValue:(NSNumber*)value {
    //id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    //[tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:[self.className stringByAppendingPathComponent:label] value:nil] build]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAlertShowing = NO;
	
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    super.screenName = self.className;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)configureAllTapsWillDismissKeyboard {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tgr setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tgr];
}

- (void)dismissKeyboard{
    [self.view endEditing:YES];
}

- (void)addChildViewController:(UIViewController*)controller withContainer:(UIView*)container {
    [controller willMoveToParentViewController:self];
    controller.view.frame = container.bounds;
    [self addChildViewController:controller];
    [container addSubview:controller.view];
    [controller didMoveToParentViewController:self];
}

//Debug purpose
//- (void)dealloc {
//   DBLog(@"%@ dealloc",NSStringFromClass([self class]));
//}

@end

@implementation BaseViewController (Tracker)

- (void)trackButtonUI:(NSString*)label {
    [self trackUI:@"ButtonPressed" label:label];
}

- (void)trackUI:(NSString*)action label:(NSString*)label {
    [self trackWithCategory:@"UI" withAction:action withLabel:label withValue:nil];
}

- (void)trackEvent:(NSString*)action label:(NSString*)label {
    [self trackWithCategory:@"Event" withAction:action withLabel:label withValue:nil];
}

@end

@implementation BaseViewController (SendMessage)

- (void)showMessageViewWithRideID:(NSString *)rideID cityID:(NSNumber *)cityID {
    SMessageViewController *vc =
    [[SMessageViewController alloc] initWithRideID:rideID cityID:cityID withRecipientName:nil andRecipientType:RecipientTypeSupport];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSupportEmail:(UIBarButtonItem *)sender {
    __weak __typeof__(self) weakself = self;
    
    NSString *email = @"support@rideaustin.com";
    NSString *message = [NSString stringWithFormat:@"You may reach us at %@", email];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Need help?" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    alert.popoverPresentationController.barButtonItem = sender;
    if ([MFMailComposeViewController canSendMail]) {
        UIAlertAction *openMail = [UIAlertAction actionWithTitle:@"Open Mail app" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakself showMail];
        }];
        [alert addAction:openMail];
    }
    UIAlertAction *copyEmail = [UIAlertAction actionWithTitle:@"Copy email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIPasteboard generalPasteboard].string = email;
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:copyEmail];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showMail {
    MFMailComposeViewController *picker = [MFMailComposeViewController new];
    picker.mailComposeDelegate = self;
    //[picker setSubject:self.promoViewModel.emailTitle];
    //[picker setMessageBody:self.promoViewModel.emailBody isHTML:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:^{
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
        }
    }];
}
@end
