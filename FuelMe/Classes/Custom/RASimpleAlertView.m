//
//  RASimpleAlertView.m
//  Ride
//
//  Created by Roberto Abreu on 14/9/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RASimpleAlertView.h"
#import "DNA.h"
#import "KLCPopup.h"

const CGFloat kAlertWidth = 277.0;
const CGFloat kMessageMargin = 14;

@interface RASimpleAlertView()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) KLCPopup *popup;

@end

@implementation RASimpleAlertView

+ (RASimpleAlertView*)simpleAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message{
    UIFont *fontMessage = [UIFont fontWithName:FontTypeLight size:13.0];
    
    CGFloat baseMessageHeight = 25.0;
    CGRect messageSize = [message boundingRectWithSize:CGSizeMake(kAlertWidth - kMessageMargin * 2, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:fontMessage} context:nil];
    
    CGFloat baseHeight = 132.0;
    
    RASimpleAlertView *alert = [[RASimpleAlertView alloc] initWithFrame:CGRectMake(0, 0, kAlertWidth, baseHeight + (messageSize.size.height - baseMessageHeight))];
    alert.lblTitle.text = title;
    alert.lblMessage.font = fontMessage;
    alert.lblMessage.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    [alert.lblMessage setText:message afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
        NSArray *matches = [linkDetector matchesInString:[mutableAttributedString string] options:0 range:NSMakeRange(0, [mutableAttributedString length])];
        
        UIFont *fontLinks = [UIFont fontWithName:@"Helvetica-BoldOblique" size:13.0];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontLinks.fontName, fontLinks.pointSize, NULL);
        
        for (NSTextCheckingResult *match in matches) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:[match range]];
        }
        
        CFRelease(font);
        return mutableAttributedString;
    }];
    
    alert.popup = [KLCPopup popupWithContentView:alert.containerView showType:KLCPopupShowTypeGrowIn dismissType:KLCPopupDismissTypeShrinkOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    return alert;
}

- (void)show {
    [[[[UIApplication sharedApplication] windows] firstObject] endEditing:YES];
    [self.popup show];
}

- (IBAction)dismiss:(id)sender {
    [self.popup dismiss:YES];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSBundle mainBundle] loadNibNamed:@"RASimpleAlertView" owner:self options:nil];
        self.containerView.frame = frame;
    }
    return self;
}

@end
