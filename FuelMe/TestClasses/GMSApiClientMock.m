//
//  GMSApiClientMock.m
//  Ride
//
//  Created by Roberto Abreu on 6/5/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "GMSApiClientMock.h"

#pragma mark - GMSFilterMock

@interface GMSFilterMock : NSObject

@property (nonatomic, strong) NSString *query;
@property (nonatomic, strong) NSString *responseFile;
@property (nonatomic, assign, getter=isReguexExpression) BOOL regex;

- (instancetype)initWithQuery:(NSString*)query responseFile:(NSString*)responseFile;
- (BOOL)matchQuery:(NSString*)query;

@end

@implementation GMSFilterMock

- (instancetype)initWithQuery:(NSString*)query responseFile:(NSString*)responseFile {
    if (self = [super init]) {
        self.query = query;
        self.responseFile = responseFile;
    }
    return self;
}

- (BOOL)matchQuery:(NSString *)query {
    if (self.isReguexExpression) {
        NSError *error;
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:self.query options:NSRegularExpressionCaseInsensitive error:&error];
        NSAssert(!error, @"Regular Expression Error : %@ - %@",self.query,error.localizedDescription);
        return [regularExpression numberOfMatchesInString:query options:0 range:NSMakeRange(0, query.length)] > 0;
    } else {
        return [self.query containsString:query];
    }
}

@end

#pragma mark - GMSApiClientMock

@interface GMSApiClientMock ()

@property (nonatomic, strong) NSMutableArray <GMSFilterMock*>* filters;

@end

@implementation GMSApiClientMock

+ (instancetype)sharedInstance {
    static GMSApiClientMock *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GMSApiClientMock alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _filters = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addMapQuery:(NSString *)query toResponseFile:(NSString *)fileNames {
    [self addQuery:query isRegularExp:NO toResponseFile:fileNames];
}

- (void)addMapRegexQuery:(NSString *)regQuery toResponseFile:(NSString *)fileName {
    [self addQuery:regQuery isRegularExp:YES toResponseFile:fileName];
}

- (void)addQuery:(NSString*)query isRegularExp:(BOOL)regExp toResponseFile:(NSString*)fileName {
    GMSFilterMock *filterMock = [[GMSFilterMock alloc] initWithQuery:query.lowercaseString responseFile:fileName];
    filterMock.regex = regExp;
    [self.filters insertObject:filterMock atIndex:0];
}

- (NSDictionary *)predictionsWithQuery:(NSString *)query {
    for (GMSFilterMock *filter in self.filters) {
        if ([filter matchQuery:query.lowercaseString]) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:filter.responseFile ofType:@"json"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            return dict;
        }
    }
    NSAssert(false, @"GMSApiClientMock failed to find: %@", query);
    return nil;
}

@end


