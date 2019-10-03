//
//  RAMessageView.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/10/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RAMessageView;
@protocol RAMessageViewProtocol <NSObject>
- (void)messageViewDidPresent:(RAMessageView * _Nonnull)messageView;
- (void)messageViewDidDismiss:(RAMessageView * _Nonnull)messageView;
@end

@interface RAMessageView : UIView

@property (nonatomic) NSArray<NSLayoutConstraint *> * _Nullable initialConstraints;
@property (nonatomic) NSArray<NSLayoutConstraint *> * _Nullable unchangedConstraints;
@property (nonatomic) NSArray<NSLayoutConstraint *> * _Nullable finalConstraints;

/** Callback block called after the user taps on the messageView */
@property (nonatomic, copy) void (^ _Nullable callback)(void);

/** Callback block called after the messageView finishes dismissing */
@property (nonatomic, copy) void (^ _Nullable dismissCompletionCallback)(void);
- (instancetype _Nonnull)initWithAttributedTitle:(NSAttributedString *_Nonnull)attributedTitle
                                   textAlignment:(NSTextAlignment)textAlignment
                                      andIconUrl:(NSURL *_Nullable)iconURL
                                 backgroundColor:(UIColor *_Nullable)backgroundColor
                            canBeDismissedByUser:(BOOL)canBeDismissedByUser
                                        callback:(void(^ _Nullable)(void))callback
                                      controller:(id<RAMessageViewProtocol> _Nonnull )controller;
- (void)present;
- (void)dismiss;
- (void)dismissWithCompletion:(void(^ _Nullable)(void))completion;
@end
