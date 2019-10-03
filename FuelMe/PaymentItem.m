//
//  PaymentItem.m
//  Ride
//
//  Created by Roberto Abreu on 5/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "PaymentItem.h"

@interface PaymentItem ()

@property (nonatomic, readwrite) NSString *text;
@property (nonatomic, readwrite) UIColor *textColor;
@property (nonatomic, readwrite) UIImage *iconItem;
@property (nonatomic, readwrite) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, strong) RACardDataModel *card;

@end

@implementation PaymentItem

+ (instancetype)paymentItemWithCard:(RACardDataModel *)card {
    return [[self alloc] initWithCard:card];
}

+ (instancetype)paymentItemWithText:(NSString *)text textColor:(UIColor *)textColor andIconItem:(UIImage *)iconItem {
    return [[self alloc] initWithText:text textColor:textColor iconItem:iconItem accessoryType:UITableViewCellAccessoryNone];
}

+ (instancetype)paymentItemWithText:(NSString *)text textColor:(UIColor *)textColor andIconItem:(UIImage *)iconItem accessoryType:(UITableViewCellAccessoryType)accessoryType{
    return [[self alloc] initWithText:text textColor:textColor iconItem:iconItem accessoryType:accessoryType];
}

- (instancetype)initWithCard:(RACardDataModel *)card {
    NSString *text = [@"**** **** **** " stringByAppendingString:card.cardNumber];
    UIColor *textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
    UIImage *cardIcon = [UIImage imageNamed:card.cardBrand.lowercaseString];
    if (!cardIcon) {
        cardIcon = [UIImage imageNamed:@"stp_card_placeholder"];
    }
    
    PaymentItem *paymentItem = [self initWithText:text textColor:textColor iconItem:cardIcon accessoryType:UITableViewCellAccessoryNone];
    paymentItem.card = card;
    return paymentItem;
}

- (instancetype)initWithText:(NSString *)text textColor:(UIColor *)textColor iconItem:(UIImage *)iconItem accessoryType:(UITableViewCellAccessoryType)accessoryType {
    if (self = [super init]) {
        self.text = text;
        self.textColor = textColor;
        self.iconItem = iconItem;
        self.accessoryType = accessoryType;
    }
    return self;
}

- (NSString *)expiration {
    if (![self isCreditCard]) {
        return nil;
    }
    
    if (!self.card.expMonth || !self.card.expYear) {
        return nil;
    }
    
    NSString *yearFromFirstTwoDigits = [self.card.expYear substringFromIndex:MIN(self.card.expYear.length, 2)];
    NSString *yearLastTwoDigits = [yearFromFirstTwoDigits substringToIndex:MIN(yearFromFirstTwoDigits.length, 2)];
    
    return [NSString stringWithFormat:@"%@/%@", self.card.expMonth, yearLastTwoDigits];
}

- (BOOL)isCreditCard {
    return self.card != nil;
}

- (BOOL)isApplePay {
    return [self.text isEqualToString:@"Apple Pay"];
}

- (BOOL)isBevoBucks {
    return [self.text isEqualToString:@"Bevo Pay"];
}

- (void)updateText:(NSString *)text {
    self.text = text;
}

@end
