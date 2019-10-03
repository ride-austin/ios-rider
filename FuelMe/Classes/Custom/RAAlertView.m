//
//  RAAlertView.m
//  Ride
//
//  Created by Kitos on 17/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAAlertView.h"
#import "KLCPopup.h"
#import "RAMacros.h"

static CGFloat const kBaseHeight = 281.0;
static CGFloat const kLabelHeight = 21.0;
static CGFloat const kHorizontalMarginLblLine1 = 40;

@interface RAAlertView ()

@property (nonatomic, retain) IBOutlet UIView *view;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *line1;
@property (nonatomic, retain) IBOutlet UILabel *line2;
@property (nonatomic, retain) IBOutlet UILabel *line3;
@property (nonatomic, retain) IBOutlet UIButton *noButton;
@property (nonatomic, retain) IBOutlet UIButton *yesButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintLine2Height;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintLine3Height;

@property (nonatomic, copy) RAAlertViewActiondBlock actionBlock;

- (IBAction)noButtonPressed:(UIButton*)sender;
- (IBAction)yesButtonPressed:(UIButton*)sender;

- (void)fitLine1:(NSString*)line1;

@property (nonatomic, strong) KLCPopup *popup;
@property (nonatomic) BOOL visible;

@end

@interface NSString (bounds)

- (CGFloat)heightWithFont:(UIFont*)font linebreakMode:(NSLineBreakMode)lineBreakMode constrainedToWidth:(CGFloat)width;

@end

@implementation RAAlertView

+ (RAAlertView *)alertViewWithTitle:(NSString *)title line1:(NSString *)line1 line2:(NSString *)line2 line3:(NSString *)line3 completion:(RAAlertViewActiondBlock)handler {
    NSMutableString *hint = [[NSMutableString alloc] initWithString:line1];
    RAAlertView *alert = [[RAAlertView alloc]initWithFrame:CGRectMake(0, 0, 300, kBaseHeight)];
    alert.titleLabel.text = title;
    alert.line1.text = line1;
    alert.line2.text = line2;
    alert.line3.text = line3;
    
    alert.noButton.layer.cornerRadius = 15;
    alert.yesButton.layer.cornerRadius = 15;

    alert.actionBlock = handler;
    [alert fitLine1:line1];
    
    if (IS_EMPTY(line2)) {
        alert.constraintLine2Height.constant = 0.0;
    } else {
        [hint appendString:@"\n"];
        [hint appendString:line2];
    }
    
    if (IS_EMPTY(line3)) {
        alert.constraintLine3Height.constant = 0.0;
    } else {
        [hint appendString:@"\n"];
        [hint appendString:line3];
    }
    
    alert.yesButton.accessibilityHint = hint;
    CGFloat dxHeight = 0.0;
    CGFloat baseHeightLines = 25.0;
    dxHeight += IS_EMPTY(line2) ? baseHeightLines : 0.0;
    dxHeight += IS_EMPTY(line3) ? baseHeightLines : 0.0;
    
    if (dxHeight > 0.0) {
        alert.frame = CGRectMake(0, 0, 300, kBaseHeight - dxHeight);
    }
    
    alert.popup = [KLCPopup popupWithContentView:alert showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:NO dismissOnContentTouch:NO];
    
    return alert;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.visible = NO;
        [[NSBundle mainBundle] loadNibNamed:@"RAAlertView" owner:self options:nil];
        self.view.frame = frame;
        self.view.layer.cornerRadius = 8;
        [self addSubview:self.view];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.view.layer.cornerRadius = 8;
    [self addSubview:self.view];
}

- (void)noButtonPressed:(UIButton *)sender {
    [self.popup dismiss:YES];
    self.visible = NO;
    if (self.actionBlock) {
        self.actionBlock(NO);
    }
}

- (void)yesButtonPressed:(UIButton *)sender {
    [self.popup dismiss:YES];
    self.visible = NO;
    if (self.actionBlock) {
        self.actionBlock(YES);
    }
}

- (void)show {
    [self.popup show];
    self.visible = YES;
    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.yesButton);
}

- (void)dismiss {
    [self.popup dismiss:YES];
    self.visible = NO;
}

- (void)updateLine1:(NSString *)line1 {
    self.line1.text = line1;
    [self fitLine1:line1];
}

- (void)fitLine1:(NSString*)line1 {
    CGFloat line1Height = [line1 heightWithFont:self.line1.font linebreakMode:self.line1.lineBreakMode constrainedToWidth:self.view.bounds.size.width - kHorizontalMarginLblLine1];
    
    CGFloat dh = line1Height - kLabelHeight;
    if (dh < 0) {
        dh = 0;
    }
    
    CGRect frame = self.frame;
    frame.size.height = kBaseHeight + dh;
    
    self.frame = frame;
}

@end

@implementation NSString (bounds)

- (CGFloat)heightWithFont:(UIFont *)font linebreakMode:(NSLineBreakMode)lineBreakMode constrainedToWidth:(CGFloat)width {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary *attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle.copy};
    NSInteger options = NSStringDrawingUsesLineFragmentOrigin;
    
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:options attributes:attributes context:nil];
    return floor(ceilf(rect.size.height));
}

@end
