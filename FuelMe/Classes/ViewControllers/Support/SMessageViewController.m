//
//  SMessageViewController.m
//  RideDriver
//
//  Created by Theodore Gonzalez on 9/2/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "SMessageViewController.h"

#import "NSString+Utils.h"
#import "SupportTopicAPI.h"
#import "UITextView+Placeholder.h"
#import "UIBarButtonItem+RAFactory.h"

#define kBaseMargin 10.0

@interface SMessageViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btSend;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewBottom;

@property (nonatomic) NSNumber *cityID;

@end

@implementation SMessageViewController

- (instancetype)initWithRideID:(NSString *)rideID
                       cityID:(NSNumber *)cityID
            withRecipientName:(NSString *)recipient
             andRecipientType:(RecipientType)recipientType {
    if (self = [super init]) {
        self.rideID = rideID;
        self.cityID = cityID;
        self.recipientName = recipient;
        self.recipientType = recipientType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTextView];
    [self configureNavBar];
    [self addObservers];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)configureTextView {
    self.textView.text = @"";
    self.textView.placeholder = [@"Please enter your message" localized];
}

- (void)configureNavBar {
    self.title = [NSString stringWithFormat:[@"CONTACT %@" localized], self.recipientName];
    [self.navigationController.navigationBar setAccessibilityIdentifier:self.title];
    self.btSend = [UIBarButtonItem defaultWithTitle:@"Send" target:self action:@selector(btSendTapped:)];
    [self.btSend setEnabled:NO];
    [self.navigationItem setRightBarButtonItem:self.btSend];
}

- (NSString *)recipientName {
    if ([_recipientName isKindOfClass:[NSString class]]) {
        return _recipientName;
    } else {
        return @"Support".localized.uppercaseString;
    }
}

#pragma mark - KeyboardObservers

- (void)keyboardDidShow:(NSNotification*)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.constraintTextViewBottom.constant = keyboardSize.height + kBaseMargin;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide {
    self.constraintTextViewBottom.constant = kBaseMargin;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [self.btSend setEnabled:self.isValidMessage];
}

#pragma mark Validation

- (BOOL)isValidMessage {
    if (self.textView.text && [self.textView.text isKindOfClass:[NSString class]]) {
        NSString *newString = [self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return ![newString isEqualToString:@""];
    } else {
        return NO;
    }
}

#pragma mark Actions

- (IBAction)btSendTapped:(UIBarButtonItem *)sender {
    switch (self.recipientType) {
        case RecipientTypeSupport:
            [self sendToSupport];
            break;
    }
}

- (void)sendToSupport {
    [super showHUD];
    [SupportTopicAPI postSupportMessage:self.textView.text
                                 rideID:self.rideID
                                 cityID:self.cityID
                         withCompletion:^(NSError *error) {
        if (error) {
            [super hideHUD];
            [RAAlertManager showErrorWithAlertItem:error
                                        andOptions:[RAAlertOption optionWithState:StateActive andShownOption:AllowNetworkError]];
        } else {
            [SVProgressHUD dismissWithCompletion:^{
                [super showSuccessHUDAndPopWithStatus:[@"SUCCESS\nWe'll be in touch soon." localized]];
            }];
        }
    }];
}

@end
