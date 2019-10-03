//
//  RAFirstModelMock.m
//  Ride
//
//  Created by Roberto Abreu on 22/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAFirstModelMock.h"

@implementation RAFirstModelMock

- (NSArray<NSString *> *)excludeProperties {
    return @[@"anExcludeProp",@"didFinishUpdating",@"didPerformCustomUpdate",
             @"didStartUpdatingWithModel",@"didPropertyUpdated"];
}

- (void)didFinishUpdatingWithModel:(RABaseDataModel *)model {
    self.didFinishUpdating = YES;
}

- (BOOL)performCustomUpdateWithModel:(RABaseDataModel *)model {
    self.didPerformCustomUpdate = YES;
    return NO;
}

- (void)willStartUpdatingWithModel:(RABaseDataModel *)model {
    self.didStartUpdatingWithModel = YES;
}

- (void)didUpdatePropertyWithName:(NSString *)name fromModel:(RABaseDataModel *)model {
    self.didPropertyUpdated = YES;
}

@end
