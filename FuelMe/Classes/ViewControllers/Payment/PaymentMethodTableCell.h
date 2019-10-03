//
//  PaymentMethodTableCell.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaymentItem;

@interface PaymentMethodTableCell : UITableViewCell

@property (weak, nonatomic) PaymentItem *paymentItem;

@end
