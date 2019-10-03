//
//  UIView+CompatibleAnchor.h
//  Ride
//
//  Created by Theodore Gonzalez on 09/05/2018.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CompatibleAnchor)

- (NSLayoutYAxisAnchor *)compatibleTopAnchor;
- (NSLayoutYAxisAnchor *)compatibleBottomAnchor;
- (NSLayoutYAxisAnchor *)compatibleCenterYAnchor;
- (NSLayoutXAxisAnchor *)compatibleCenterXAnchor;
- (NSLayoutXAxisAnchor *)compatibleLeadingAnchor;
- (NSLayoutXAxisAnchor *)compatibleTrailingAnchor;

@end
