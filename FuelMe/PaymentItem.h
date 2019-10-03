//
//  PaymentItem.h
//  Ride
//
//  Created by Roberto Abreu on 5/7/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RACardDataModel.h"

@interface PaymentItem : NSObject

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *expiration;
@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, readonly) UIImage *iconItem;
@property (nonatomic, readonly) UITableViewCellAccessoryType accessoryType;
@property (nonatomic, readonly) RACardDataModel *card;

@property (nonatomic, copy) void(^didSelectItem)(PaymentItem* paymentItem);
@property (nonatomic, copy) void(^didTapInfoButton)(void);

+ (instancetype)paymentItemWithCard:(RACardDataModel*)card;
+ (instancetype)paymentItemWithText:(NSString*)text textColor:(UIColor*)textColor andIconItem:(UIImage*)iconItem;
+ (instancetype)paymentItemWithText:(NSString*)text textColor:(UIColor*)textColor andIconItem:(UIImage*)iconItem accessoryType:(UITableViewCellAccessoryType)accessoryType;

//Convenience Initilizers
- (instancetype)initWithCard:(RACardDataModel*)card;
- (instancetype)initWithText:(NSString*)text textColor:(UIColor*)textColor iconItem:(UIImage*)iconItem accessoryType:(UITableViewCellAccessoryType)accessoryType;

- (BOOL)isCreditCard;
- (BOOL)isApplePay;
- (BOOL)isBevoBucks;
- (void)updateText:(NSString *)text;

@end
