// KLCPopup.m
//
// Created by Jeff Mascia
// Copyright (c) 2013-2014 Kullect Inc. (http://kullect.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "KLCPopup.h"

static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);

KLCPopupLayout KLCPopupLayoutMake(KLCPopupHorizontalLayout horizontal, KLCPopupVerticalLayout vertical)
{
  KLCPopupLayout layout;
  layout.horizontal = horizontal;
  layout.vertical = vertical;
  return layout;
}

const KLCPopupLayout KLCPopupLayoutCenter = { KLCPopupHorizontalLayoutCenter, KLCPopupVerticalLayoutCenter };


@interface NSValue (KLCPopupLayout)
+ (NSValue*)valueWithKLCPopupLayout:(KLCPopupLayout)layout;
- (KLCPopupLayout)KLCPopupLayoutValue;
@end


@interface KLCPopup ()

- (void)updateForInterfaceOrientation;
- (void)didChangeStatusBarOrientation:(NSNotification*)notification;

// Used for calling dismiss:YES from selector because you can't pass primitives, thanks objc
- (void)dismiss;

@property (nonatomic) UIView *backgroundView;
@property (nonatomic) UIView *containerView;

@property (nonatomic) BOOL isBeingShown;
@property (nonatomic) BOOL isShowing;
@property (nonatomic) BOOL isBeingDismissed;

@end

@implementation KLCPopup

#pragma mark -

- (void)dealloc {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];

  // stop listening to notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init {
  return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = YES;
    
    self.shouldDismissOnBackgroundTouch = YES;
    self.shouldDismissOnContentTouch = NO;
    
    self.showType = KLCPopupShowTypeShrinkIn;
    self.dismissType = KLCPopupDismissTypeShrinkOut;
    self.maskType = KLCPopupMaskTypeDimmed;
    self.dimmedMaskAlpha = 0.5;
    
    self.isBeingShown = NO;
    self.isShowing = NO;
    self.isBeingDismissed = NO;
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.containerView];
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
  }
  return self;
}

#pragma mark - Properties

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
    }
    return _backgroundView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}
#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  
  UIView* hitView = [super hitTest:point withEvent:event];
  if (hitView == self) {
    
    // Try to dismiss if backgroundTouch flag set.
    if (_shouldDismissOnBackgroundTouch) {
      [self dismiss:YES];
    }
    
    // If no mask, then return nil so touch passes through to underlying views.
    if (_maskType == KLCPopupMaskTypeNone) {
      return nil;
    } else {
      return hitView;
    }
    
  } else {
    
    // If view is within containerView and contentTouch flag set, then try to hide.
    if ([hitView isDescendantOfView:_containerView]) {
      if (_shouldDismissOnContentTouch) {
        [self dismiss:YES];
      }
    }
    return hitView;
  }
}


#pragma mark - Class Public

+ (KLCPopup*)popupWithContentView:(UIView*)contentView
{
  KLCPopup* popup = [[[self class] alloc] init];
  popup.contentView = contentView;
  return popup;
}


+ (KLCPopup*)popupWithContentView:(UIView*)contentView
                         showType:(KLCPopupShowType)showType
                      dismissType:(KLCPopupDismissType)dismissType
                         maskType:(KLCPopupMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch
{
  KLCPopup* popup = [[[self class] alloc] init];
  popup.contentView = contentView;
  popup.showType = showType;
  popup.dismissType = dismissType;
  popup.maskType = maskType;
  popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
  popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
  return popup;
}


+ (void)dismissAllPopups {
  NSArray* windows = [[UIApplication sharedApplication] windows];
  for (UIWindow* window in windows) {
    [window forEachPopupDoBlock:^(KLCPopup *popup) {
      [popup dismiss:NO];
    }];
  }
}


#pragma mark - Public

- (void)show {
  [self showWithLayout:KLCPopupLayoutCenter];
}


- (void)showWithLayout:(KLCPopupLayout)layout {
  [self showWithLayout:layout duration:0.0];
}


- (void)showWithDuration:(NSTimeInterval)duration {
  [self showWithLayout:KLCPopupLayoutCenter duration:duration];
}


- (void)showWithLayout:(KLCPopupLayout)layout duration:(NSTimeInterval)duration {
  NSDictionary* parameters = @{@"layout" : [NSValue valueWithKLCPopupLayout:layout],
                               @"duration" : @(duration)};
  [self showWithParameters:parameters];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView*)view {
  [self showAtCenter:center inView:view withDuration:0.0];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration {
  NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
  [parameters setValue:[NSValue valueWithCGPoint:center] forKey:@"center"];
  [parameters setValue:@(duration) forKey:@"duration"];
  [parameters setValue:view forKey:@"view"];
  [self showWithParameters:[NSDictionary dictionaryWithDictionary:parameters]];
}


- (void)dismiss:(BOOL)animated {
  
  if (_isShowing && !_isBeingDismissed) {
    _isBeingShown = NO;
    _isShowing = NO;
    _isBeingDismissed = YES;
    
    // cancel previous dismiss requests (i.e. the dismiss after duration call).
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];

    [self willStartDismissing];
    
    if (self.willStartDismissingCompletion != nil) {
      self.willStartDismissingCompletion();
    }
    
      __weak __typeof__(self) weakself = self;
    dispatch_async( dispatch_get_main_queue(), ^{

      // Animate background if needed
      void (^backgroundAnimationBlock)(void) = ^(void) {
        weakself.backgroundView.alpha = 0.0;
      };
      
      if (animated && (weakself.showType != KLCPopupShowTypeNone)) {
        // Make fade happen faster than motion. Use linear for fades.
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:backgroundAnimationBlock
                         completion:NULL];
      } else {
        backgroundAnimationBlock();
      }
      
      // Setup completion block
      void (^completionBlock)(BOOL) = ^(BOOL finished) {
        
        [self removeFromSuperview];
        
        weakself.isBeingShown = NO;
        weakself.isShowing = NO;
        weakself.isBeingDismissed = NO;
        
        [self didFinishDismissing];
        
        if (self.didFinishDismissingCompletion != nil) {
          self.didFinishDismissingCompletion();
        }
      };
      
      NSTimeInterval bounce1Duration = 0.13;
      NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
      
      // Animate content if needed
      if (animated) {
        switch (weakself.dismissType) {
          case KLCPopupDismissTypeFadeOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                               weakself.containerView.alpha = 0.0;
                             } completion:completionBlock];
            break;
          }
            
          case KLCPopupDismissTypeGrowOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               weakself.containerView.alpha = 0.0;
                               weakself.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             } completion:completionBlock];
            break;
          }
            
          case KLCPopupDismissTypeShrinkOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               weakself.containerView.alpha = 0.0;
                               weakself.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                             } completion:completionBlock];
            break;
          }
            
          case KLCPopupDismissTypeSlideOutToTop: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case KLCPopupDismissTypeSlideOutToBottom: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.y = CGRectGetHeight(self.bounds);
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case KLCPopupDismissTypeSlideOutToLeft: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case KLCPopupDismissTypeSlideOutToRight: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.x = CGRectGetWidth(self.bounds);
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            
            break;
          }
            
          case KLCPopupDismissTypeBounceOut: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               weakself.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  weakself.containerView.alpha = 0.0;
                                                  weakself.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case KLCPopupDismissTypeBounceOutToTop: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.y += 40.0;
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = weakself.containerView.frame;
                                                  finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                                  weakself.containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case KLCPopupDismissTypeBounceOutToBottom: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.y -= 40.0;
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = weakself.containerView.frame;
                                                  finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                                  weakself.containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case KLCPopupDismissTypeBounceOutToLeft: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.x += 40.0;
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = weakself.containerView.frame;
                                                  finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                                  weakself.containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            break;
          }
            
          case KLCPopupDismissTypeBounceOutToRight: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = weakself.containerView.frame;
                               finalFrame.origin.x -= 40.0;
                               weakself.containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = weakself.containerView.frame;
                                                  finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                                  weakself.containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            break;
          }
            
          default: {
            self.containerView.alpha = 0.0;
            completionBlock(YES);
            break;
          }
        }
      } else {
        self.containerView.alpha = 0.0;
        completionBlock(YES);
      }
      
    });
  }
}


#pragma mark - Private

- (void)showWithParameters:(NSDictionary*)parameters {
    __weak __typeof__(self) weakself = self;
  // If popup can be shown
  if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
    _isBeingShown = YES;
    _isShowing = NO;
    _isBeingDismissed = NO;
    
    [self willStartShowing];
    
    dispatch_async( dispatch_get_main_queue(), ^{
      
      // Prepare by adding to the top window.
      if(!self.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
          if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self];
            
            break;
          }
        }
      }
      
      // Before we calculate layout for containerView, make sure we are transformed for current orientation.
      [self updateForInterfaceOrientation];
      
      // Make sure we're not hidden
      self.hidden = NO;
      self.alpha = 1.0;
      
      // Setup background view
      weakself.backgroundView.alpha = 0.0;
      if (weakself.maskType == KLCPopupMaskTypeDimmed) {
        weakself.backgroundView.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:self.dimmedMaskAlpha];
      } else {
        weakself.backgroundView.backgroundColor = [UIColor clearColor];
      }
      
      // Animate background if needed
      void (^backgroundAnimationBlock)(void) = ^(void) {
        weakself.backgroundView.alpha = 1.0;
      };
      
      if (weakself.showType != KLCPopupShowTypeNone) {
        // Make fade happen faster than motion. Use linear for fades.
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:backgroundAnimationBlock
                         completion:NULL];
      } else {
        backgroundAnimationBlock();
      }
      
      // Determine duration. Default to 0 if none provided.
      NSTimeInterval duration;
      NSNumber* durationNumber = [parameters valueForKey:@"duration"];
      if (durationNumber != nil) {
        duration = [durationNumber doubleValue];
      } else {
        duration = 0.0;
      }
      
      // Setup completion block
      void (^completionBlock)(BOOL) = ^(BOOL finished) {
        weakself.isBeingShown = NO;
        weakself.isShowing = YES;
        weakself.isBeingDismissed = NO;
        
        [self didFinishShowing];
        
        if (self.didFinishShowingCompletion != nil) {
          self.didFinishShowingCompletion();
        }
        
        // Set to hide after duration if greater than zero.
        if (duration > 0.0) {
          [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
        }
      };
      
      // Add contentView to container
      if (weakself.contentView.superview != weakself.containerView) {
        [weakself.containerView addSubview:self.contentView];
      }
      
      // Re-layout (this is needed if the contentView is using autoLayout)
      [self.contentView layoutIfNeeded];
      
      // Size container to match contentView
      CGRect containerFrame = weakself.containerView.frame;
      containerFrame.size = self.contentView.frame.size;
      weakself.containerView.frame = containerFrame;
      // Position contentView to fill it
      CGRect contentViewFrame = self.contentView.frame;
      contentViewFrame.origin = CGPointZero;
      self.contentView.frame = contentViewFrame;
      
      // Reset _containerView's constraints in case contentView is uaing autolayout.
      UIView* contentView = weakself.contentView;
      NSDictionary* views = NSDictionaryOfVariableBindings(contentView);
      
      [weakself.containerView removeConstraints:weakself.containerView.constraints];
      [weakself.containerView addConstraints:
       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                               options:0
                                               metrics:nil
                                                 views:views]];
      
      [weakself.containerView addConstraints:
       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                               options:0
                                               metrics:nil
                                                 views:views]];
      
      // Determine final position and necessary autoresizingMask for container.
      CGRect finalContainerFrame = containerFrame;
      UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
      
      // Use explicit center coordinates if provided.
      NSValue* centerValue = [parameters valueForKey:@"center"];
      if (centerValue != nil) {
        
        CGPoint centerInView = [centerValue CGPointValue];
        CGPoint centerInSelf;
        
        // Convert coordinates from provided view to self. Otherwise use as-is.
        UIView* fromView = [parameters valueForKey:@"view"];
        if (fromView != nil) {
          centerInSelf = [self convertPoint:centerInView fromView:fromView];
        } else {
          centerInSelf = centerInView;
        }
        
        finalContainerFrame.origin.x = (centerInSelf.x - CGRectGetWidth(finalContainerFrame)/2.0);
        finalContainerFrame.origin.y = (centerInSelf.y - CGRectGetHeight(finalContainerFrame)/2.0);
        containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
      }
      
      // Otherwise use relative layout. Default to center if none provided.
      else {
        
        NSValue* layoutValue = [parameters valueForKey:@"layout"];
        KLCPopupLayout layout;
        if (layoutValue != nil) {
          layout = [layoutValue KLCPopupLayoutValue];
        } else {
          layout = KLCPopupLayoutCenter;
        }
        
        switch (layout.horizontal) {
            
          case KLCPopupHorizontalLayoutLeft: {
            finalContainerFrame.origin.x = 0.0;
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case KLCPopupHorizontalLayoutLeftOfCenter: {
            finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)/3.0 - CGRectGetWidth(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case KLCPopupHorizontalLayoutCenter: {
            finalContainerFrame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame))/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case KLCPopupHorizontalLayoutRightOfCenter: {
            finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)*2.0/3.0 - CGRectGetWidth(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case KLCPopupHorizontalLayoutRight: {
            finalContainerFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
            break;
          }
            
          default:
            break;
        }
        
        // Vertical
        switch (layout.vertical) {
            
          case KLCPopupVerticalLayoutTop: {
            finalContainerFrame.origin.y = 0;
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case KLCPopupVerticalLayoutAboveCenter: {
            finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)/3.0 - CGRectGetHeight(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case KLCPopupVerticalLayoutCenter: {
            finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame))/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case KLCPopupVerticalLayoutBelowCenter: {
            finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)*2.0/3.0 - CGRectGetHeight(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case KLCPopupVerticalLayoutBottom: {
            finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
            break;
          }
            
          default:
            break;
        }
      }
      
      weakself.containerView.autoresizingMask = containerAutoresizingMask;
      
      // Animate content if needed
      switch (weakself.showType) {
        case KLCPopupShowTypeFadeIn: {
          
          weakself.containerView.alpha = 0.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:UIViewAnimationOptionCurveLinear
                           animations:^{
                             weakself.containerView.alpha = 1.0;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeGrowIn: {
          
          weakself.containerView.alpha = 0.0;
          // set frame before transform here...
          CGRect startFrame = finalContainerFrame;
          weakself.containerView.frame = startFrame;
          weakself.containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
                             weakself.containerView.alpha = 1.0;
                             // set transform before frame here...
                             weakself.containerView.transform = CGAffineTransformIdentity;
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          
          break;
        }
          
        case KLCPopupShowTypeShrinkIn: {
          weakself.containerView.alpha = 0.0;
          // set frame before transform here...
          CGRect startFrame = finalContainerFrame;
          weakself.containerView.frame = startFrame;
          weakself.containerView.transform = CGAffineTransformMakeScale(1.25, 1.25);
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
                             weakself.containerView.alpha = 1.0;
                             // set transform before frame here...
                             weakself.containerView.transform = CGAffineTransformIdentity;
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeSlideInFromTop: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeSlideInFromBottom: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = CGRectGetHeight(self.bounds);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeSlideInFromLeft: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeSlideInFromRight: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = CGRectGetWidth(self.bounds);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          
          break;
        }
          
        case KLCPopupShowTypeBounceIn: {
          weakself.containerView.alpha = 0.0;
          // set frame before transform here...
          CGRect startFrame = finalContainerFrame;
          weakself.containerView.frame = startFrame;
          weakself.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:15.0
                              options:0
                           animations:^{
                             weakself.containerView.alpha = 1.0;
                             weakself.containerView.transform = CGAffineTransformIdentity;
                           }
                           completion:completionBlock];
          
          break;
        }
          
        case KLCPopupShowTypeBounceInFromTop: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeBounceInFromBottom: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = CGRectGetHeight(self.bounds);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeBounceInFromLeft: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case KLCPopupShowTypeBounceInFromRight: {
          weakself.containerView.alpha = 1.0;
          weakself.containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = CGRectGetWidth(self.bounds);
          weakself.containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
                             weakself.containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        default: {
          self.containerView.alpha = 1.0;
          self.containerView.transform = CGAffineTransformIdentity;
          self.containerView.frame = finalContainerFrame;
          
          completionBlock(YES);
          
          break;
        }
      }
      
    });
  }
}


- (void)dismiss {
  [self dismiss:YES];
}


- (void)updateForInterfaceOrientation {
  
  // We must manually fix orientation prior to iOS 8
  if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat angle;
    
    switch (orientation) {
      case UIInterfaceOrientationPortraitUpsideDown:
        angle = M_PI;
        break;
      case UIInterfaceOrientationLandscapeLeft:
        angle = -M_PI/2.0f;;
        
        break;
      case UIInterfaceOrientationLandscapeRight:
        angle = M_PI/2.0f;
        
        break;
      default: // as UIInterfaceOrientationPortrait
        angle = 0.0;
        break;
    }
    
    self.transform = CGAffineTransformMakeRotation(angle);
  }

  self.frame = self.window.bounds;
}


#pragma mark - Notification handlers

- (void)didChangeStatusBarOrientation:(NSNotification*)notification {
  [self updateForInterfaceOrientation];
}


#pragma mark - Subclassing

- (void)willStartShowing {
  
}


- (void)didFinishShowing {
  
}


- (void)willStartDismissing {
  
}


- (void)didFinishDismissing {
  
}

@end




#pragma mark - Categories

@implementation UIView(KLCPopup)


- (void)forEachPopupDoBlock:(void (^)(KLCPopup* popup))block {
  for (UIView *subview in self.subviews)
  {
    if ([subview isKindOfClass:[KLCPopup class]])
    {
      block((KLCPopup *)subview);
    } else {
      [subview forEachPopupDoBlock:block];
    }
  }
}


- (void)dismissPresentingPopup {
  
  // Iterate over superviews until you find a KLCPopup and dismiss it, then gtfo
  UIView* view = self;
  while (view != nil) {
    if ([view isKindOfClass:[KLCPopup class]]) {
      [(KLCPopup*)view dismiss:YES];
      break;
    }
    view = [view superview];
  }
}

@end




@implementation NSValue (KLCPopupLayout)

+ (NSValue *)valueWithKLCPopupLayout:(KLCPopupLayout)layout
{
  return [NSValue valueWithBytes:&layout objCType:@encode(KLCPopupLayout)];
}

- (KLCPopupLayout)KLCPopupLayoutValue
{
  KLCPopupLayout layout;
  
  [self getValue:&layout];
  
  return layout;
}

@end
