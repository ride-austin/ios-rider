//
//  RASideMenuHeaderView.h
//  Ride
//
//  Created by Theodore Gonzalez on 8/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RACustomView.h"

@interface RASideMenuHeaderView : RACustomView

+ (instancetype _Nonnull)viewWithWidth:(CGFloat)width target:(id _Nonnull)target action:(SEL _Nonnull)action;
- (void)updateName:(NSString * _Nullable)name imageURL:(NSURL * _Nullable)imageURL;

@end
