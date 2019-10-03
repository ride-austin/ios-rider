//
//  RACustomTextField.h
//  Ride
//
//  Created by Kitos on 6/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACustomTextField;

@protocol RACustomTextFieldDelegate <NSObject>

- (void)textField:(RACustomTextField*)textfield hasChangedBorderEnabled:(BOOL)enabled;

@end

@interface RACustomTextField : UITextField

@property (nonatomic, assign) IBOutlet id<RACustomTextFieldDelegate> customDelegate;

@property (nonatomic) BOOL borderEnabled;
@property (nonatomic) BOOL hideBorder;
@property (nonatomic) IBInspectable CGFloat paddingOffset;

@end
