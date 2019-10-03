//
//  PaddedTextField.m
//  Ride
//
//  Created by Abdul Rehman on 16/05/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "PaddedTextField.h"

@implementation PaddedTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    // Text position
    return CGRectInset(bounds, 10, 10);
}

@end
