//
//  RAPopUpViewController.h
//  Ride
//
//  Created by Theodore Gonzalez on 2/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, RAPopupShowType) {
    RAPopupShowTypeBounceIn = 0
};

typedef NS_ENUM(NSUInteger, RAPopupDismissType) {
    RAPopupDismissTypeBounceOut = 0
};

@interface RAPopUpViewController : BaseViewController
// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// Animation transition for presenting. default = bounce in
@property (nonatomic, assign) RAPopupShowType showType;

// Animation transition for dismissing. default = bounce out
@property (nonatomic, assign) RAPopupDismissType dismissType;
- (void)showInParent:(UIViewController *)parent;
@end
