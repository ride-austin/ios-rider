//
//  NSString+Utils.m
//  RideAustin
//
//  Created by Kitos on 9/8/16.
//  Copyright © 2016 Crossover Markets Inc. All rights reserved.
//

#import "NSString+Utils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utils)

+ (NSString*)urlEncodedString:(NSDictionary*)params {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params) {
        id value = [params objectForKey:key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", key, value];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

- (BOOL)isEmpty {
    if (self && [self trim].length > 0) {
        return NO;
    }
    return YES;
}

- (NSString*)md5 {
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (NSString*)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSDate *)serverDate {
    return [self dateFromStringWithFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
}

- (NSString *)localized {
    return NSLocalizedString(self, @"");
}

- (NSDate *)dateFromStringWithFormat:(NSString *)format {
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:format];

    return [dateFormatter dateFromString:self];
}

- (NSString*)matchWithPattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSString* match = @"";
    
    if (error) {
        return match;
    }
    
    NSArray* matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (matches.count > 0) {
        match = [self substringWithRange:[matches[0] range]];
    }
    
    return match;
}

@end
