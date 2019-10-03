//
//  BottomDrawerView.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BottomDrawerView.h"

#import "NSString+Utils.h"

@interface BottomDrawerView()
@property (weak, nonatomic) id flowController;
@property (weak, nonatomic) id <BottomDrawerViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lbETATitle;
@property (weak, nonatomic) IBOutlet UILabel *lbETAValue;
@property (weak, nonatomic) IBOutlet UILabel *lbMaxSizeValue;
@property (weak, nonatomic) IBOutlet UILabel *lbMaxSizeTitle;

@end

@implementation BottomDrawerView

- (instancetype)initWithFlowController:(id)flowController andDelegate:(id<BottomDrawerViewDelegate>)delegate {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.hidden = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.flowController = flowController;
        self.delegate = delegate;
        [self configureSwipeGestureRecognizer];
    }
    return self;
}

- (void)configureSwipeGestureRecognizer {
    UISwipeGestureRecognizer *swipeCategoryUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCategorySliderAction:)];
    [swipeCategoryUp setDirection:UISwipeGestureRecognizerDirectionUp];
    
    UISwipeGestureRecognizer *swipeCategoryDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCategorySliderAction:)];
    [swipeCategoryDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.categorySlider addGestureRecognizer:swipeCategoryUp];
    [self.categorySlider addGestureRecognizer:swipeCategoryDown];
}

- (void)swipeCategorySliderAction:(UISwipeGestureRecognizer *)sender {
    [self.delegate drawerView:self didSwipe:sender.direction];
}

- (IBAction)btViewPricingTapped:(UIButton *)sender {
    [self.delegate drawerView:self didTapViewPricing:sender];
}

- (IBAction)btGetRideEstimateTapped:(UIButton *)sender {
    [self.delegate drawerView:self didTapGetRideEstimate:sender];
}

- (IBAction)carCategoryHasChanged:(RACategorySlider *)sender {
    [self.delegate drawerView:self didChangeSelectedCategory:sender.selectedCategory];
}

- (IBAction)btChevronTapped:(UIButton *)sender {
    [self.delegate drawerView:self didTapChevron:sender];
}

- (void)updateLabelsWithPickupETA:(NSInteger)pickupETA {
    if (pickupETA == NSNotFound) {
        self.lbETAValue.text = @"- -";
        self.lbETATitle.accessibilityLabel = [@"ETA not available" localized];
    } else {
        self.lbETAValue.text = [NSString stringWithFormat:[@"%ld MIN" localized], pickupETA/60];
        self.lbETATitle.accessibilityLabel = [NSString stringWithFormat:[@"ETA %ld minutes" localized], pickupETA/60];
    }
    
    int maxSeats = self.categorySlider.selectedCategory.maxPersons.intValue;
    self.lbMaxSizeValue.text = [NSString stringWithFormat:[@"%d PEOPLE" localized], maxSeats];
    self.lbMaxSizeTitle.accessibilityLabel = [NSString stringWithFormat:[@"Max Size %d people" localized], maxSeats];
}

- (CGFloat)constantWithVisibleSlider {
    return - (CGRectGetHeight(self.frame) - CGRectGetHeight(self.categorySlider.frame));
}

- (CGFloat)constantWithVisibleDrawer {
    return 0;
}

@end

@implementation BottomDrawerView (RALocationViewState)

- (void)updateVisibilityBasedOnState:(RALocationViewState)state {
    self.hidden = [self isHiddenForState:state];
}

- (BOOL)isHiddenForState:(RALocationViewState)state {
    switch (state) {
        case RALocationViewStateClear:          return NO;
        case RALocationViewStateInitial:        return NO;
        case RALocationViewStatePrepared:       return YES;
        case RALocationViewStateRequesting:     return YES;
        case RALocationViewStateRideAssigned:   return YES;
        case RALocationViewStateWaitingDriver:  return YES;
        case RALocationViewStateDriverReached:  return YES;
        case RALocationViewStateTripStarted:    return YES;
        case RALocationViewStateTripCanceled:   return NO;
        case RALocationViewStateRating:         return NO;
    }
}

@end
