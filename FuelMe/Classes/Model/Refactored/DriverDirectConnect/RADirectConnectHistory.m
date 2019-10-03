#import "RADirectConnectHistory.h"
#import "NSString+Date.h"

@implementation RADirectConnectHistory

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{ @"directConnectId"  : @"directConnectId",
              @"driverFirstName"   : @"driverFirstName",
              @"driverLastName"   : @"driverLastName",
              @"requestedAt"     : @"requestedAt",
              @"photoURL" : @"photoURL"
              };
}

+ (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy h:mm a"];
    return dateFormatter;
}
    
+ (NSValueTransformer *)requestedAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *dateString, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [self.dateFormatter stringFromDate:date];
    }];
}

@end
