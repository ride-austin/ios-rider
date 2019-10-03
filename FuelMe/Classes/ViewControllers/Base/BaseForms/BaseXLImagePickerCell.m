//
//  BaseXLImagePickerCell.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/24/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "BaseXLImagePickerCell.h"

#import "NSString+Utils.h"
#import "RAPhotoPickerControllerManager.h"
#import "UIImage+Ride.h"
#import "RAAlertManager.h"

NSString * const XLFormRowDescriptorTypeBaseXLImagePickerCell = @"XLFormRowDescriptorTypeBaseXLImagePickerCell";

@interface BaseXLImagePickerCell()

@property (nonatomic) RAPhotoPickerControllerManager *pickerManager;

@end

@implementation BaseXLImagePickerCell

#pragma mark - XLFormLifeCycle

+ (void)load {
    NSDictionary *registration = @{XLFormRowDescriptorTypeBaseXLImagePickerCell : NSStringFromClass([self class])};
    [[XLFormViewController cellClassesForRowDescriptorTypes] addEntriesFromDictionary:registration];
}

- (void)configure {
    [super configure];
}

- (void)update {
    [super update];
    self.lbTitle.text = self.rowDescriptor.title;
    [self didUpdateRowDescriptorValue];
}

- (void)didUpdateRowDescriptorValue {
    BOOL hasValue = [self.rowDescriptor.value isKindOfClass:[UIImage class]];
    self.ivValue.image       = hasValue ? self.rowDescriptor.value : nil;
    self.ivValue.alpha       = hasValue;
    self.ivPlaceholder.alpha =!hasValue;
}

#pragma mark - XLFormRowDescriptor

- (UIView *)inputView {
    return nil;
}

- (BOOL)canBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}

- (BOOL)becomeFirstResponder {
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [super resignFirstResponder];
}

- (BOOL)formDescriptorCellCanBecomeFirstResponder {
    return [self.rowDescriptor isDisabled] == NO;
}

- (BOOL)formDescriptorCellBecomeFirstResponder {
    if (self.isFirstResponder) {
        return self.resignFirstResponder;
    }
    return self.becomeFirstResponder;
}

- (void)formDescriptorCellDidSelectedWithFormController:(XLFormViewController *)controller {
    [self.pickerManager showPickerControllerFromViewController:self.formViewController sender:self.ivPlaceholder allowEditing:YES finishedBlock:^(UIImage *picture, NSError *error) {
        BOOL valid = [self isImageValid:picture];
        if (valid) {
            CGFloat maxArea = 480000;
            picture = [UIImage imageWithImage:picture scaledToMaxArea:maxArea];
        }
        
        self.rowDescriptor.value = valid ? picture : nil;
        [self didUpdateRowDescriptorValue];
    } cancelledBlock:nil];
}

+ (CGFloat)formDescriptorCellHeightForRowDescriptor:(XLFormRowDescriptor *)rowDescriptor {
    return 100;
}

- (RAPhotoPickerControllerManager *)pickerManager {
    if (!_pickerManager) {
        _pickerManager = [RAPhotoPickerControllerManager pickerManager];
    }
    return _pickerManager;
}

#pragma mark - Validation

- (BOOL)isImageValid:(UIImage *)image {
    if (image && [image imageValidSizeForMinArea:190*250]) {
        return YES;
    } else {
        NSString *message = [@"Please upload a High Quality Photo with a minimum size of 190x250 pixels to be readable." localized];
        [RAAlertManager showErrorWithAlertItem:message
                                    andOptions:[RAAlertOption optionWithTitle:[@"Invalid Size" localized] andState:StateActive]];
        return NO;
    }
}

@end
