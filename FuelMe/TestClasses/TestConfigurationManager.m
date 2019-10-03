//
//  TestConfigurationManager.m
//  Ride
//
//  Created by Marcos Alba on 15/6/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "TestConfigurationManager.h"

@interface TestConfigurationManager ()

@property (nonatomic, strong) NSDictionary *configurations;
@property (nonatomic, getter=isTesting) BOOL testing;
@property (nonatomic, strong) TestConfiguration *configuration;

- (void)loadStubs;

@end

@implementation TestConfigurationManager

+ (TestConfigurationManager *)sharedManager {
    static TestConfigurationManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[TestConfigurationManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *environment = [NSProcessInfo processInfo].environment;
        self.testing = environment[@"AUTOMATION"] != nil;
        
        self.configuration = [[TestConfiguration alloc] init];
        [self.configuration loadConfigurationFromFile:@"StubConfigurations"];
        
        if (self.configuration.useStubs) {
            [self loadStubs];
        }
    }
    return self;
}

- (void)loadStubs {
    NSMutableArray *ma = [NSMutableArray array];
    NSArray<NSString*>* arguments = [NSProcessInfo processInfo].arguments;
    [arguments enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@"MAP"]) {
            NSString *networkStubMappingPath = [[NSBundle mainBundle] pathForResource:@"NetworkStubMapping" ofType:@"plist"];
            NSDictionary *networkStubMapping = [NSDictionary dictionaryWithContentsOfFile:networkStubMappingPath];
            
            NSAssert(networkStubMapping, @"NetworkStubMapping should not be nil");
            NSAssert([[networkStubMapping allKeys] containsObject:obj], @"Network Stub Mapping doesn't contain Map");
            
            NSArray <NSString*>* methodMapping = [networkStubMapping objectForKey:obj];
            if (methodMapping) {
                [ma addObjectsFromArray:methodMapping];
            }
        }
    }];
    
    self.configuration.stubMethods = [NSArray arrayWithArray:ma];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<--\n - TestConfigurationManager -\n Testing: %@\n%@ \n-->",[self isTesting]?@"True":@"False",self.configuration];
}

@end
