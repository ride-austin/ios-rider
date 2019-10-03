//
//  GenderViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 9/12/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GenderViewModel.h"
#import "ConfigGlobal.h"
#import "RAMacros.h"
#import "RASessionManager.h"
#import "RAAlertManager.h"

@implementation GenderViewModel

+ (instancetype)viewModelWithConfig:(ConfigGlobal *)config andDidSaveGenderHandler:(void (^)(RAUserDataModel *))didSaveGenderHandler {
    return [[self alloc] initWithConfig:config andDidSaveGenderHandler:didSaveGenderHandler];
}

- (instancetype)initWithConfig:(ConfigGlobal *)config andDidSaveGenderHandler:(void (^)(RAUserDataModel * ))didSaveGenderHandler {
    if (self = [super init]) {
        _title    = config.genderSelection.title;
        _subtitle = config.genderSelection.subtitle;
        _genders  = config.genderSelection.options;
        _didSaveGenderHandler = didSaveGenderHandler;
    }
    return self;
}

- (void)dealloc {
    DBLog(@"dealloc");
}

- (void)didSelectIndex:(NSUInteger)index withCompletion:(void (^)(BOOL))completion {
    NSString *gender = self.genders[index];
    [[RASessionManager sharedManager] updateUserGender:gender withCompletion:^(RAUserDataModel *user, NSError *error) {
        completion(error == nil);
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithShownOption:AllowNetworkError]];
        } else {
            self.didSaveGenderHandler(user);
        }
    }];
}

@end
