//
//  NSString+XMLEncoding.m
//  RedStamp
//
//  Created by Martin Grider on 2/17/11.
//  Copyright 2011 Recursive Awesome, LLC. All rights reserved.
//

#import "NSString+XMLEncoding.h"
#import "NSMutableString+XMLEncoding.h"


@implementation NSString (NSString_XMLEncoding)


- (NSString *)xmlSimpleEscapeString
{
	NSMutableString *escapeStr = [NSMutableString stringWithString:self];

	return [escapeStr xmlSimpleEscape];
}


- (NSString *)xmlSimpleUnescapeString
{
	NSMutableString *unescapeStr = [NSMutableString stringWithString:self];

	return [unescapeStr xmlSimpleUnescape];
}

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    NSUInteger sourceLen = strlen((const char *)source);
    for (NSUInteger i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}
@end
