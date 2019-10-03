//
//  DriverInsuranceViewController.m
//  RideAustin
//
//  Created by Tyson Bunch on 2/27/15.
//  Copyright (c) 2015 FuelMe LLC. All rights reserved.
//

#import "DriverInsuranceViewController.h"
#import "DriverSSNViewController.h"

@interface DriverInsuranceViewController ()

@property (nonatomic, strong) NSMutableDictionary *userData;

@end

@implementation DriverInsuranceViewController


-(IBAction)takePhoto:(id)sender {
    [self showHUD];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hideHUD:YES];
    });
}

- (void)hudWasHidden:(MBProgressHUD*)hud {
    UIImage *image = [UIImage imageNamed:@"Background"];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageStr = [imageData base64EncodedString];
    
    self.userData[@"insuranceData"]  = imageStr;
    
    DriverSSNViewController *dSS = [[DriverSSNViewController alloc] initWithUserData:self.userData];
    [self.navigationController pushViewController:dSS animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Insurance";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.toolbarHidden = YES;
}

- (id)initWithUserData:(NSDictionary*)userData {
    self = [super init];
    if (self) {
        self.userData = [NSMutableDictionary dictionaryWithDictionary:userData];
    }
    return self;
}

@end
