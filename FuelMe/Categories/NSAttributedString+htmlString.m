//
//  NSAttributedString+htmlString.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/18/18.
//  Copyright © 2018 RideAustin.com. All rights reserved.
//

#import "NSAttributedString+htmlString.h"
#import <UIKit/UIKit.h>

@implementation NSAttributedString (htmlString)

+ (instancetype)attributedStringFromHTML:(NSString *)htmlString {
    NSData *data = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSError *error;
    NSAttributedString *attString = [[NSAttributedString alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType} documentAttributes:nil error:&error];
    if (error) {
        NSAssert(false, error.localizedDescription);
        return nil;
    }
    return attString;
}

@end
