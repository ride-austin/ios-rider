//
//  DriverInfoView.m
//  Ride
//
//  Created by Theodore Gonzalez on 4/5/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//



#import "DriverInfoView.h"
#import "FlatButton+FlatButton_StyleFacade.h"
#import "NSString+Utils.h"
#import "RAMacros.h"
#import "RARideDataModel.h"
#import "UIView+ArrowAnimation.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DriverInfoView()

@property (weak, nonatomic) id <DriverInfoViewDelegate> delegate;
@property (weak, nonatomic) id <DriverInfoViewNavigationProtocol> flowController;
@property (weak, nonatomic) IBOutlet UIView *vWhiteBox;
@property (weak, nonatomic) IBOutlet UIView *vDriver;
@property (weak, nonatomic) IBOutlet UILabel *lbDriverName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLbDriverNameExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLbDriverNameCollapsed;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLBDriverNameVerticalSpacing;

@property (weak, nonatomic) IBOutlet UIImageView *ivDriverPhoto;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiDriverPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbDriverRating;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVDriverCenterExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVDriverCenterCollapsed;

@property (weak, nonatomic) IBOutlet UIView *vCar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVCarCenterExpanded;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVCarCenterCollapsed;
@property (weak, nonatomic) IBOutlet UILabel *lbCarCategory;
@property (weak, nonatomic) IBOutlet UILabel *lbCarName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLbCarNameCenter;
@property (weak, nonatomic) IBOutlet UILabel *lbCarPlateCollapsed;
@property (weak, nonatomic) IBOutlet UILabel *lbCarPlateExpanded;
@property (weak, nonatomic) IBOutlet UIImageView *ivCarPhoto;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aiCarPhoto;

@property (weak, nonatomic) IBOutlet UIView *vAnimatingArrow;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintVSeparator1to2;
@property (weak, nonatomic) IBOutlet FlatButton *btLiveEta;
@property (weak, nonatomic) IBOutlet FlatButton *btCancel;

@property (weak, nonatomic) IBOutlet UIButton *btFareEstimate;
@property (weak, nonatomic) IBOutlet UIButton *btFareSplit;


@end

@implementation DriverInfoView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSAssert(false, @"Please make necessary changes to be used in storyboard");
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame flowController:(id<DriverInfoViewNavigationProtocol>)flowController andDelegate:(id<DriverInfoViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.hidden = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.delegate = delegate;
        self.flowController = flowController;
        [self customInit];
    }
    return self;
}

- (void)customInit {
    [self updateState:DriverInfoViewStateCollapsed animated:NO];
    self.ivDriverPhoto.layer.cornerRadius  = self.ivDriverPhoto.frame.size.width/2.0;
    self.ivDriverPhoto.layer.masksToBounds = YES;
    self.ivDriverPhoto.clipsToBounds = YES;
    
    self.ivCarPhoto.layer.cornerRadius  = self.ivCarPhoto.frame.size.width/2.0;
    self.ivCarPhoto.layer.masksToBounds = YES;
    self.ivCarPhoto.clipsToBounds = YES;
    
    //deaf label
    self.constraintVSeparator1to2.constant = -1;
    
    [self.btCancel  applyCornerButtonStyle];
    [self.btLiveEta applyCornerButtonStyle];
    [self configureAccessibility];
}
- (void)configureAccessibility {
#ifdef AUTOMATION
    self.accessibilityLabel = [@"Driver Info View" localized];
#endif
    self.btCancel.accessibilityLabel = [@"Cancel trip" localized];
    self.btFareSplit.accessibilityLabel    = [@"Fare Split" localized];
    self.btFareEstimate.accessibilityLabel = [@"See Fare Estimate" localized];
    self.lbCarCategory.accessibilityIdentifier = @"carCategoryLabel";
//    self.lbCarCategory.accessibilityIdentifier = @"carCategoryExpandedLabel"; //when expanded
    
}

- (CGFloat)contentHeight {
    CGFloat bottomMargin = 11;
    return CGRectGetMaxY(self.vWhiteBox.frame) + bottomMargin;
}

//height is 271 when deaf, 228 when not deaf
- (CGFloat)visibleHeightCollapsed {
    return 105;
}

- (void)updateState:(DriverInfoViewState)state animated:(BOOL)animated {
    //if voice over is on, always expanded
    if (UIAccessibilityIsVoiceOverRunning()) {
        state = DriverInfoViewStateExpanded;
    }
    _state = state;
    switch (state) {
        case DriverInfoViewStateCollapsed:
            //photo size = 75x75
            //rating box 63x24
            //driver
            self.constraintLbDriverNameExpanded.active = NO;
            self.constraintLbDriverNameCollapsed.active = YES;
            self.constraintLBDriverNameVerticalSpacing.constant = 12;
            self.constraintVDriverCenterExpanded.active = NO;
            self.constraintVDriverCenterCollapsed.active = YES;
            
            self.vAnimatingArrow.hidden = NO;
            [self.vAnimatingArrow showArrowAnimation];
            
            //car
            self.vCar.alpha = 0;
            self.constraintVCarCenterExpanded.active = NO;
            self.constraintVCarCenterCollapsed.active = YES;
            self.constraintLbCarNameCenter.constant = 30;
            self.lbCarPlateCollapsed.alpha = 1;
            
            //super view
            [self.delegate driverInfoView:self willResizeWithVisibleHeight:self.visibleHeightCollapsed];
            break;
            
        case DriverInfoViewStateExpanded:
            //photo size = 60x60
            //driver
            self.constraintLbDriverNameExpanded.active = YES;
            self.constraintLbDriverNameCollapsed.active = NO;
            self.constraintLBDriverNameVerticalSpacing.constant = 40;
            self.constraintVDriverCenterExpanded.active = YES;
            self.constraintVDriverCenterCollapsed.active = NO;
            
            self.vAnimatingArrow.hidden = YES;
            [self.vAnimatingArrow hideArrowAnimation];
            
            //car
            self.vCar.alpha = 1;
            self.constraintVCarCenterExpanded.active = YES;
            self.constraintVCarCenterCollapsed.active = NO;
            self.constraintLbCarNameCenter.constant = 0;
            self.lbCarPlateCollapsed.alpha = 0;
            
            //super view
            [self.delegate driverInfoView:self willResizeWithVisibleHeight:self.contentHeight];
            break;
    }

    [self.superview setNeedsLayout];
    if (animated) {
        [self animate];
    }
}

- (void)animate {
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.transform = CGAffineTransformIdentity;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)collapse {
    [self updateState:DriverInfoViewStateCollapsed animated:YES];
}

- (void)updateContentBasedOnRide:(RARideDataModel *)ride {
    __weak __typeof__(self) weakself = self;

    RACarDataModel *car = ride.activeDriver.selectedCar;
    
    NSString *carName = [NSString stringWithFormat:@"%@ %@ %@",car.color,car.make,car.model];
    NSString *licensePlate = car.licensePlate;
    
    self.lbCarName.text = carName.uppercaseString ?: @"";
    self.lbCarPlateExpanded.text  = licensePlate.uppercaseString ?: @"";
    self.lbCarPlateCollapsed.text = licensePlate.uppercaseString ?: @"";
    
    [self.aiCarPhoto startAnimating];
    [self.ivCarPhoto sd_setImageWithURL:car.photoURL placeholderImage:[UIImage imageNamed:@"carPhotoPlaceholderWithCar"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakself.aiCarPhoto stopAnimating];
    }];
    
    RACarCategoryDataModel *carType = ride.requestedCarType;
    self.lbCarCategory.text = carType.title.uppercaseString ?: @"";
    
    RADriverDataModel *driver = ride.activeDriver.driver;
    RAUserDataModel *user = driver.user;
    self.lbDriverRating.text = driver.displayRating;
    self.lbDriverName.text = user.displayName.uppercaseString ?: @"";
    [self.aiDriverPhoto startAnimating];
    [self.ivDriverPhoto sd_setImageWithURL:driver.photoURL placeholderImage:[UIImage imageNamed:@"person_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakself.aiDriverPhoto stopAnimating];
    }];
    
    self.constraintVSeparator1to2.constant = ride.activeDriver.driver.isDeaf ?  43 : -1;
    [self layoutIfNeeded];
}

- (void)updateBasedOnRide:(RARideDataModel *)ride {
    switch (ride.status) {
        case RARideStatusDriverAssigned:
        case RARideStatusDriverReached:
            self.hidden = NO;
            self.btCancel.enabled = YES;
            break;
            
        case RARideStatusActive:
            self.hidden = NO;
            self.btCancel.enabled = NO;
            break;
        default:
            //clear data
            self.hidden = YES;
            break;
    }
    [self updateContentBasedOnRide:ride];
}

#pragma mark - Actions

- (IBAction)didTapLiveETA:(UIButton *)sender {
    [self.flowController navigateToShareETAWithSender:sender];
}

- (IBAction)didTapCancel:(UIButton *)sender {
    sender.enabled = NO;
    [self.delegate driverInfoView:self didTapCancelWithCompletion:^{
        sender.enabled = YES;
    }];
}

- (IBAction)didTapFareEstimate:(UIButton *)sender {
    sender.enabled = NO;
    [self.delegate driverInfoView:self didTapFareEstimate:sender];
}

- (IBAction)didTapFareSplit:(UIButton *)sender {
    sender.enabled = NO;
    [self.flowController navigateToSplitFare];
    sender.enabled = YES;
}

- (IBAction)didTapDriverPhoto:(UIButton *)sender {
    CGRect innerFrame = [self convertRect:self.ivDriverPhoto.frame fromView:self.vDriver];
    CGRect originalFrame = [self.superview convertRect:innerFrame fromView:self];
    [self.flowController navigateToFullscreenFromImageView:self.ivDriverPhoto withOriginalFrame:originalFrame];
}

- (IBAction)didTapCarPhoto:(UIButton *)sender {
    CGRect innerFrame = [self convertRect:self.ivCarPhoto.frame fromView:self.vCar];
    CGRect originalFrame = [self.superview convertRect:innerFrame fromView:self];
    [self.flowController navigateToFullscreenFromImageView:self.ivCarPhoto withOriginalFrame:originalFrame];
}

- (IBAction)didTapArrowAndLabels:(UIButton *)sender {
    switch (self.state) {
        case DriverInfoViewStateCollapsed:
            [self updateState:DriverInfoViewStateExpanded animated:YES];
            break;
            
        case DriverInfoViewStateExpanded:
            [self updateState:DriverInfoViewStateCollapsed animated:YES];
            break;
    }
}

- (IBAction)didPan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self];
    CGPoint velocity = [sender velocityInView:self];
    if (sender.state == UIGestureRecognizerStateBegan) {
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        DBLog(@"translation y: %f", translation.y);
        DBLog(@"origin y: %f", self.frame.origin.y);
        CGFloat minOriginY = [UIScreen mainScreen].bounds.size.height - self.contentHeight - 64 - 50;
        CGFloat resultantY = self.frame.origin.y;
        BOOL shouldUpdate = resultantY > minOriginY;
        if (shouldUpdate) {
            
            self.transform = CGAffineTransformMakeTranslation(0, translation.y);
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        DBLog(@"velocity y: %f", velocity.y);
        BOOL shouldExpand = velocity.y < 0;
        if (shouldExpand) {
            [self updateState:DriverInfoViewStateExpanded animated:YES];
        } else {
            [self collapse];
        }
    }
}

@end
