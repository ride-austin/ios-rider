//
//  RAPaymentProviderInformationPopup.m
//  Ride
//
//  Created by Roberto Abreu on 8/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DNA.h"
#import "RAPaymentProviderInformationPopup.h"
#import "KLCPopup.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RAPaymentProviderInformationPopup ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imgProvider;
@property (weak, nonatomic) IBOutlet UILabel *lblProviderName;
@property (weak, nonatomic) IBOutlet UILabel *lblProviderDetail;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) KLCPopup *popup;

@end

@implementation RAPaymentProviderInformationPopup

+ (instancetype)paymentProviderPopupWithName:(NSString*)name detail:(NSString*)detail {
    RAPaymentProviderInformationPopup *paymentProviderInformationPopup = [[RAPaymentProviderInformationPopup alloc] init];
    paymentProviderInformationPopup.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    paymentProviderInformationPopup.lblProviderName.text = [NSString stringWithFormat:@"Pay with %@",name];
    paymentProviderInformationPopup.lblProviderDetail.text = detail;
    return paymentProviderInformationPopup;
}

+ (instancetype)paymentProviderWithImage:(UIImage *)image name:(NSString *)name detail:(NSString *)detail {
    RAPaymentProviderInformationPopup *paymentProviderInformationPopup = [RAPaymentProviderInformationPopup paymentProviderPopupWithName:name detail:detail];
    [paymentProviderInformationPopup.imgProvider setImage:image];
    return paymentProviderInformationPopup;
}

+ (instancetype)paymentProviderWithPhotoURL:(NSURL *)url name:(NSString *)name detail:(NSString *)detail {
    RAPaymentProviderInformationPopup *paymentProviderInformationPopup = [RAPaymentProviderInformationPopup paymentProviderPopupWithName:name detail:detail];
    [paymentProviderInformationPopup.imgProvider sd_setImageWithURL:url placeholderImage:nil];
    return paymentProviderInformationPopup;
}

#pragma mark - Initializations

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeView];
    }
    return self;
}

- (void)initializeView {
    [[NSBundle mainBundle] loadNibNamed:@"RAPaymentProviderInformationPopup" owner:self options:nil];
    self.contentView.frame = self.bounds;
    [self addSubview:self.contentView];
    [self setupUI];
}

- (void)setupUI {
    NSDictionary *attributes = @{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSFontAttributeName : [UIFont fontWithName:FontTypeRegular size:20.0]
                                  };
    NSAttributedString *disableRoundUpTitle = [[NSAttributedString alloc] initWithString:@"Close" attributes:attributes];
    [self.btnClose setAttributedTitle:disableRoundUpTitle forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)closeTapped:(id)sender {
    [self dismiss];
}

#pragma mark - Actions

- (void)show {
    self.popup = [KLCPopup popupWithContentView:self.contentView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    [self.popup show];
}

- (void)dismiss {
    [self.popup dismiss:YES];
}

@end
