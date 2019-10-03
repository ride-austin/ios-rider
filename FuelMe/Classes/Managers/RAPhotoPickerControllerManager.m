//
//  RAPhotoPickerControllerManager.m
//  RideAustin
//
//  Created by Kitos on 3/10/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "RAPhotoPickerControllerManager.h"

@interface RAPhotoPickerControllerManager ()

@property (nonatomic,copy) RAPhotoPickerFinishedBlock finishedBlock;
@property (nonatomic,copy) RAPhotoPickerCancelledBlock cancelledBlock;

@end

@interface RAPhotoPickerControllerManager (ImagePickerDelegate)<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@end

@implementation RAPhotoPickerControllerManager

+ (RAPhotoPickerControllerManager *)pickerManager{
    return [RAPhotoPickerControllerManager new];
}

- (instancetype)init {
    if (self = [super init]) {}
    return self;
}

- (void)showPickerControllerFromViewController:(UIViewController *)viewController sender:(UIView *)sender allowEditing:(BOOL)allow finishedBlock:(RAPhotoPickerFinishedBlock)finishedHandler {
    [self showPickerControllerFromViewController:viewController sender:sender allowEditing:allow finishedBlock:finishedHandler cancelledBlock:nil];
}

- (void)showPickerControllerFromViewController:(UIViewController *)viewController sender:(UIView *)sender allowEditing:(BOOL)allow finishedBlock:(RAPhotoPickerFinishedBlock)finishedHandler cancelledBlock:(RAPhotoPickerCancelledBlock)cancelledHandler{
    self.finishedBlock = finishedHandler;
    self.cancelledBlock = cancelledHandler;
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = allow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [viewController presentViewController:picker animated:YES completion:NULL];
        }
        else {
            NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.camera.notAvailable" code:-1 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Camera is not available in this device or you haven't give access to this aplication. Please check your settings."}];
            if (self.finishedBlock) {
                self.finishedBlock(nil,error);
            }
        }
    }];

    UIAlertAction *rollAction = [UIAlertAction actionWithTitle:@"Choose from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = allow;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [viewController presentViewController:picker animated:YES completion:NULL];
        }
        else {
            NSError *error = [NSError errorWithDomain:@"com.rideaustin.error.photLibrary.notAvailable" code:-2 userInfo:@{NSLocalizedFailureReasonErrorKey: @"Cannot access to the camera roll. Please check your settings."}];
            if (self.finishedBlock) {
                self.finishedBlock(nil,error);
            }
        }
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.finishedBlock = NULL;
        
        if (self.cancelledBlock) {
            self.cancelledBlock();
        }
    }];

    UIAlertController *sourceSelection = [UIAlertController alertControllerWithTitle:@"Source" message:@"From where do you want to take the picture?" preferredStyle:UIAlertControllerStyleActionSheet];
    sourceSelection.popoverPresentationController.sourceView = sender;
    sourceSelection.popoverPresentationController.sourceRect = sender.bounds;
    [sourceSelection addAction:cameraAction];
    [sourceSelection addAction:rollAction];
    [sourceSelection addAction:cancelAction];
    
    [viewController presentViewController:sourceSelection animated:YES completion:nil];
}

@end

#pragma mark ImagePicker Delegate

@implementation RAPhotoPickerControllerManager (ImagePickerDelegate)

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *chosenImage = editedImage ? editedImage : originalImage;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.finishedBlock) {
            self.finishedBlock(chosenImage,nil);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.cancelledBlock) {
            self.cancelledBlock();
        }
    }];
}

@end
