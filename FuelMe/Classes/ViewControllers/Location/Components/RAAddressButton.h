//
//  RAAddressButton.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/4/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RideConstants.h"

@interface RAAddressButton : UIButton

#if TARGET_INTERFACE_BUILDER
@property (nonatomic) IBInspectable NSInteger fieldType;
#else
@property (nonatomic) RAPickerAddressFieldType fieldType;
#endif

@property (nonatomic) IBInspectable NSString *placeholder;

@property (nonatomic) NSString *text;

@end
