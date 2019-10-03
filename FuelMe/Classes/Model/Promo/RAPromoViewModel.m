//
//  RAPromoViewModel.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAMacros.h"
#import "RAPromoViewModel.h"
#import "ConfigurationManager.h"

@interface RAPromoViewModel()

@property (nonatomic, strong) NSString *downloadURL;
@property (nonatomic, strong) NSString *detailText;
@property (nonatomic, strong) NSString *emailBody;
@property (nonatomic, strong) NSString *emailTitle;
@property (nonatomic, strong) NSString *smsBody;

- (instancetype)initWithPromoCode:(RAPromoCode *)promo andTemplate:(ConfigReferRider *)temp;

@end

@interface RAPromoViewModel (Private)

- (NSString *)fillRawTemplate:(NSString *)template withPromo:(RAPromoCode *)promo;

@end

@implementation RAPromoViewModel

+ (instancetype)viewModelWithPromoCode:(RAPromoCode *)promo andTemplate:(ConfigReferRider *)temp {
    return [[RAPromoViewModel alloc] initWithPromoCode:promo andTemplate:temp];
}

- (instancetype)initWithPromoCode:(RAPromoCode *)promo andTemplate:(ConfigReferRider *)temp {
    self = [super init];
    if (self) {
        self.downloadURL = temp.downloadURL ?: kUniversalDownloadURL;
        self.detailText = [self fillRawTemplate:temp.tempDetailText withPromo:promo];
        self.smsBody = [self fillRawTemplate:temp.tempSMSBody withPromo:promo];
        self.emailBody = [self fillRawTemplate:temp.tempEmailBody withPromo:promo];
        self.emailTitle = [NSString stringWithFormat:@"%@ free credit",[ConfigurationManager appName]];
    }
    return self;
}

@end

#pragma mark - Private

@implementation RAPromoViewModel (Private)

- (NSString *)fillRawTemplate:(NSString *)template withPromo:(RAPromoCode *)promo {
    NSString *text = @"";
    if (promo) {
        NSString *codeValue = [NSString stringWithFormat:@"$%.2f",promo.codeValue.doubleValue];
        text = template;
        text = [text stringByReplacingOccurrencesOfString:@"<codeValue>"   withString:codeValue];
        text = [text stringByReplacingOccurrencesOfString:@"<codeLiteral>" withString:promo.codeLiteral];
        text = [text stringByReplacingOccurrencesOfString:@"<downloadUrl>" withString:self.downloadURL];
    }
    return text;
}

@end
