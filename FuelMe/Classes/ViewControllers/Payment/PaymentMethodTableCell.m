//
//  PaymentMethodTableCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/17/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PaymentMethodTableCell.h"

#import "PaymentItem.h"

@interface PaymentMethodTableCell()

@property (weak, nonatomic) IBOutlet UIImageView *ivIcon;
@property (weak, nonatomic) IBOutlet UIButton *btInfo;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;

@end

@implementation PaymentMethodTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self configureDefaults];
}

- (void)configureDefaults {
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
#ifdef AUTOMATION
    self.isAccessibilityElement = YES;
#endif
}

- (void)setPaymentItem:(PaymentItem *)paymentItem {
    _paymentItem = paymentItem;
    [self updateViewBasedOnItem:paymentItem];
}

- (void)updateViewBasedOnItem:(PaymentItem *)paymentItem {
    self.ivIcon.image       = paymentItem.iconItem;
    self.lbTitle.text       = paymentItem.text;
    self.lbTitle.textColor  = paymentItem.textColor;
    self.btInfo.hidden      = paymentItem.didTapInfoButton == nil;
    self.accessoryType      = paymentItem.accessoryType;
    
    if (paymentItem.isCreditCard) {
        self.accessibilityLabel = [NSString stringWithFormat:@"Card ending in %@",paymentItem.card.cardNumber];
        self.accessibilityHint = @"Double tap to check card options";
        self.contentView.alpha = [paymentItem.card.cardExpired boolValue] ? 0.3 : 1.0;
    }
}

- (IBAction)didTapInfoButton:(UIButton *)sender {
    if (self.paymentItem.didTapInfoButton) {
        self.paymentItem.didTapInfoButton();
    }
}

@end
