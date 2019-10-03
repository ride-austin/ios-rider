//
//  NSString+Utils.h
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

+ (NSString*)urlEncodedString:(NSDictionary*)params;

- (BOOL)isEmpty;
- (NSString *)md5;
- (NSString *)trim;
- (NSDate *)serverDate;
- (NSString *)localized;
- (NSString *)matchWithPattern:(NSString *)pattern;
- (NSDate *)dateFromStringWithFormat:(NSString *)format;

@end
