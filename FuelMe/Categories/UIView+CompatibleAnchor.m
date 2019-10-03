//
//  UIView+CompatibleAnchor.m
//  Ride
//
//  Created by Theodore Gonzalez on 09/05/2018.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "UIView+CompatibleAnchor.h"

@implementation UIView (CompatibleAnchor)

- (NSLayoutYAxisAnchor *)compatibleTopAnchor {
    if (@available(iOS 11.0,*)) {
        return self.safeAreaLayoutGuide.topAnchor;
    } else {
        return self.topAnchor;
    }
}

- (NSLayoutYAxisAnchor *)compatibleBottomAnchor {
    if (@available(iOS 11.0,*)) {
        return self.safeAreaLayoutGuide.bottomAnchor;
    } else {
        return self.bottomAnchor;
    }
}

- (NSLayoutYAxisAnchor *)compatibleCenterYAnchor {
    if (@available(iOS 11.0,*)) {
        return self.safeAreaLayoutGuide.centerYAnchor;
    } else {
        return self.centerYAnchor;
    }
}

- (NSLayoutXAxisAnchor *)compatibleCenterXAnchor {
    if (@available(iOS 11.0,*)) {
        return self.safeAreaLayoutGuide.centerXAnchor;
    } else {
        return self.centerXAnchor;
    }
}

- (NSLayoutXAxisAnchor *)compatibleLeadingAnchor {
    if (@available(iOS 11.0,*)) {
        return self.safeAreaLayoutGuide.leadingAnchor;
    } else {
        return self.leadingAnchor;
    }
}

- (NSLayoutXAxisAnchor *)compatibleTrailingAnchor {
    if (@available(iOS 11.0,*)) {
        return self.safeAreaLayoutGuide.trailingAnchor;
    } else {
        return self.trailingAnchor;
    }
}

@end
