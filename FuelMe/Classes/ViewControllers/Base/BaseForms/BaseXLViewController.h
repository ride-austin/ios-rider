//
//  BaseXLViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#undef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#import <XLForm/XLForm.h>
#import "XLFormRowDescriptor+factory.h"
#import "UIViewController+progressHUD.h"
#import "NSObject+className.h"
@interface BaseXLViewController : XLFormViewController

@end
@interface BaseXLViewController (validation)
- (BOOL)isFormValid;
@end
