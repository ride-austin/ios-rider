//
//  RAMessageController.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/10/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "DNA.h"
#import "InsertingProtocol.h"
#import "RACampaign.h"
#import "RAMessageController.h"
#import "RAMessageView.h"
#import "UIView+CompatibleAnchor.h"
#import "NSAttributedString+htmlString.h"

@interface RAMessageController()

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic) NSMutableArray<RAMessageView *> *presentedMessages;
@property (nonatomic) RAMessageView *stackedRideMessageView;
@property (nonatomic) RAMessageView *discountMessageView;
@property (nonatomic) RAMessageView *paymentDeficiencyMessageView;

@end


@interface RAMessageController(RAMessageViewProtocol) <RAMessageViewProtocol>
@end

@implementation RAMessageController

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController {
    self = [super init];
    if (self) {
        NSAssert(navigationController, @"NavigationController cannot be nil");
        self.navigationController = navigationController;
        self.presentedMessages = [NSMutableArray new];
    }
    return self;
}

- (void)showCampaignMessage:(RACampaign *)campaign inViewController:(UIViewController<InsertingProtocol> *)viewController withDidTapBlock:(void (^)(void))didTapBlock {
    __weak __typeof__(self) weakself = self;
    if (self.discountMessageView) {
        [self.discountMessageView dismissWithCompletion:^{
            [weakself showCampaignMessage:campaign inViewController:viewController withDidTapBlock:didTapBlock];
        }];
        return;
    }
    NSAttributedString *title = [NSAttributedString attributedStringFromHTML:campaign.bannerText];
    RAMessageView *messageView = [[RAMessageView alloc] initWithAttributedTitle:title textAlignment:NSTextAlignmentLeft andIconUrl:campaign.bannerIcon backgroundColor:[UIColor azureBlue] canBeDismissedByUser:NO callback:didTapBlock controller:self];
    
    UIViewController<InsertingProtocol> *vc = viewController;
    UIView *topView = vc.view;
    UIView *insertingView = vc.insertingView;
    [vc.view addSubview:messageView];
    
    messageView.unchangedConstraints =
    @[
      [messageView.leadingAnchor constraintEqualToAnchor:topView.compatibleLeadingAnchor],
      [messageView.trailingAnchor constraintEqualToAnchor:topView.compatibleTrailingAnchor]
      ];
    messageView.initialConstraints =
    @[
      [messageView.bottomAnchor constraintEqualToAnchor:topView.compatibleTopAnchor]
      ];
    messageView.finalConstraints =
    @[
      [messageView.topAnchor constraintEqualToAnchor:insertingView.topAnchor],
      [messageView.bottomAnchor constraintEqualToAnchor:insertingView.bottomAnchor]
      ];
    
    [messageView present];
    self.discountMessageView = messageView;
    messageView.dismissCompletionCallback = ^{
        weakself.discountMessageView = nil;
    };
}

- (void)hideCampaignMessage {
    if (self.discountMessageView) {
        [self.discountMessageView dismiss];
    }
}

- (void)showStackedRideInfoInViewController:(UIViewController<InsertingProtocol> *)vc {
    if (self.stackedRideMessageView) {
        return;
    }
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Closest Driver is finishing up a trip nearby"];
    RAMessageView *messageView = [[RAMessageView alloc] initWithAttributedTitle:title textAlignment:NSTextAlignmentCenter andIconUrl:nil backgroundColor:[UIColor azureBlue] canBeDismissedByUser:NO callback:nil controller:self];
    
    UIView *insertingView = vc.insertingView;
    [vc.view addSubview:messageView];
    messageView.unchangedConstraints =
    @[
      [messageView.leadingAnchor constraintEqualToAnchor:vc.view.leadingAnchor],
      [messageView.trailingAnchor constraintEqualToAnchor:vc.view.trailingAnchor],
      ];
    messageView.initialConstraints =
    @[
      [messageView.bottomAnchor constraintEqualToAnchor:vc.view.topAnchor]
      ];
    messageView.finalConstraints =
    @[
      [messageView.topAnchor constraintEqualToAnchor:insertingView.topAnchor],
      [messageView.bottomAnchor constraintEqualToAnchor:insertingView.bottomAnchor]
      ];
    [messageView present];
    __weak __typeof__(self) weakself = self;
    messageView.dismissCompletionCallback = ^{
        weakself.stackedRideMessageView = nil;
    };
    self.stackedRideMessageView = messageView;
}

- (void)hideStackedRideInfo {
    if (self.stackedRideMessageView) {
        [self.stackedRideMessageView dismiss];
    }
}

- (void)showPaymentDeficiencyMessage:(NSString *)message inViewController:(UIViewController<InsertingProtocol> *)vc didTapBlock:(void (^)(void))didTapBlock {
    if (self.paymentDeficiencyMessageView) {
        return;
    }
    NSAttributedString *attTitle = [[NSAttributedString alloc] initWithString:message];
    RAMessageView *messageView = [[RAMessageView alloc] initWithAttributedTitle:attTitle textAlignment:NSTextAlignmentLeft andIconUrl:nil backgroundColor:[UIColor warningYellow] canBeDismissedByUser:NO callback:didTapBlock controller:self];

    
    UIView *insertingView = vc.insertingView;
    [vc.view addSubview:messageView];
    messageView.unchangedConstraints =
    @[
      [messageView.leadingAnchor constraintEqualToAnchor:vc.view.leadingAnchor],
      [messageView.trailingAnchor constraintEqualToAnchor:vc.view.trailingAnchor],
      ];
    messageView.initialConstraints =
    @[
      [messageView.bottomAnchor constraintEqualToAnchor:vc.view.topAnchor]
      ];
    messageView.finalConstraints =
    @[
      [messageView.topAnchor constraintEqualToAnchor:insertingView.topAnchor],
      [messageView.bottomAnchor constraintEqualToAnchor:insertingView.bottomAnchor]
      ];
    [messageView present];
    __weak __typeof__(self) weakself = self;
    messageView.dismissCompletionCallback = ^{
        weakself.paymentDeficiencyMessageView = nil;
    };
    self.paymentDeficiencyMessageView = messageView;
}

- (void)hidePaymentDeficiencyMessage {
    if (self.paymentDeficiencyMessageView) {
        [self.paymentDeficiencyMessageView dismiss];
    }
}

@end



@implementation RAMessageController(RAMessageViewProtocol)

- (void)messageViewDidPresent:(RAMessageView *)messageView {
    [self.presentedMessages addObject:messageView];
}

- (void)messageViewDidDismiss:(RAMessageView *)messageView {
    [self.presentedMessages removeObject:messageView];
}

@end
