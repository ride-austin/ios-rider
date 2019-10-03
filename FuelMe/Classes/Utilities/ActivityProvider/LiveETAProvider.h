//
//  LiveETAProvider.h
//  Ride
//
//  Created by Robert on 15/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LiveETAProvider : UIActivityItemProvider

@property (strong, nonatomic) NSString *subject;
@property (strong, nonatomic) NSString *message;

@end
