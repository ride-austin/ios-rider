//
//  CreditDetailCollectionViewCell.m
//  Ride
//
//  Created by Roberto Abreu on 8/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "CreditDetailCollectionViewCell.h"

@implementation CreditDetailCollectionViewCell

- (void)configureWithViewModel:(RedemptionViewModel *)redemptionViewModel {
    self.lblValue.text = redemptionViewModel.value;
    self.lblDescription.text = redemptionViewModel.descriptionUses;
    self.lblExpiration.text = redemptionViewModel.descriptionExpiration;
    self.lblCodeValue.text = redemptionViewModel.couponCode;
}

@end
