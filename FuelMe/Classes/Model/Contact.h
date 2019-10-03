//
//  Contact.h
//  Ride
//
//  Created by Abdul Rehman on 02/09/2016.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Contacts/Contacts.h>
#import <UIKit/UIKit.h>

#import "SplitFare.h"

@interface Contact : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSMutableArray *phoneNumbers;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic, assign) BOOL accepted;

- (instancetype)initWithContact:(CNContact*)contact;
- (instancetype)initWithSourceSplitFare:(SplitFare*)splitFare;
- (instancetype)initWithTargetContact:(NSDictionary*)dict;

@end
