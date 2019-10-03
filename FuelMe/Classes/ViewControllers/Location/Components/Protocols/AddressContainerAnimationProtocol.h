//
//  AddressContainerAnimationProtocol.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/4/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AddressContainerAnimationProtocol <NSObject>

- (void)setAddressContainerTopConstraint:(CGFloat)constant;
- (void)setAddressContainerLeadingTrailingConstraint:(CGFloat)constant;
- (void)setDestinationFieldTopConstraint:(CGFloat)constant;
- (void)setCommentFieldTopConstraint:(CGFloat)constant;
@property (nonatomic) UIView *viewAddressFields;
@property (nonatomic) UIView *viewPickupField;
@property (nonatomic) UIView *viewDestinationField;

@end
