//
//  SelectPlaceMapViewController.h
//  Ride
//
//  Created by Kitos on 20/8/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "BaseViewController.h"

@class RAAddress;

typedef void (^SelectedPlaceBlock) (RAAddress *address);

@interface SelectPlaceMapViewController : BaseViewController

@property (strong, nonatomic) UIImage *icon;
@property (assign, nonatomic) CGRect iconFrame;
@property (strong, nonatomic) UIImage *pinIcon;
@property (strong, nonatomic) NSString *initialAddress;
@property (strong, nonatomic) CLLocation *initialLocation;
@property (strong, nonatomic) NSString *descriptionTitle;
@property (nonatomic, copy) SelectedPlaceBlock selectedPlaceBlock;

@end
