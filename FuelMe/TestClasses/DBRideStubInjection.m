//
//  DBRideStubInjection.m
//  Ride
//
//  Created by Marcos Alba on 15/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "DBRideStubInjection.h"
#import "RAMacros.h"

@interface DBRideStubInjection ()

@property (nonatomic, strong) NSDictionary *jsonDict;

@end

@implementation DBRideStubInjection : NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.injectionType = DBRITRideChildObject;
        self.injectAfterStatus = MockRideStatusDriverAssigned;
        self.delay = 0;
        self.totalDelay = 0;
        self.timeout = 0;
        self.injectJSONFile = nil;
        self.jsonDict = nil;
    }
    return self;
}

-(void)setInjectJSONFile:(NSString *)injectJSONFile{
    _injectJSONFile = injectJSONFile;
    
    if (injectJSONFile) {
        NSString *injectJSONPath = [[NSBundle mainBundle] pathForResource:injectJSONFile ofType:@"json"];
        if (injectJSONPath) {
            NSError *parseError = nil;
            NSData *jsonData = [NSData dataWithContentsOfFile:injectJSONPath options:0 error:&parseError];
            if (!parseError && jsonData) {
                NSError *error = nil;
                self.jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:0
                                                                  error:&error];
                if (error) {
                    DBLog(@"Error parsing injection: %@",error);
                }
            }
            else if(parseError) {
                DBLog(@"Error getting injection data from file: %@ - %@",injectJSONFile,parseError);
            }
            else {
                DBLog(@"No data to inject in file: %@",injectJSONFile);
            }
        }
        else {
            DBLog(@"No file found with name: %@",injectJSONFile);
        }
    }
}

-(NSString *)description{
    return [NSString stringWithFormat:@"<--\n - DBRideStubInjection -\n type: %lu\n afterStatus: %lu\n totalDelay: %lu\n timeout: %ld\n JSON: %@\n-->", (unsigned long)self.injectionType, (unsigned long)self.injectAfterStatus, (unsigned long)self.totalDelay, (long)self.timeout,self.jsonDict];
}

@end
