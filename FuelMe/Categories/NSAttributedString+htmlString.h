//
//  NSAttributedString+htmlString.h
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (htmlString)

+ (instancetype _Nonnull)attributedStringFromHTML:(NSString * _Nonnull)htmlString;

@end
