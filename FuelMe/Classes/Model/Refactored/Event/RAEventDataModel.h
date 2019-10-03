//
//  RAEventDataModel.h
//  Ride
//
//  Created by Kitos on 15/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

#import "RAEventsProtocol.h"

typedef NS_ENUM(NSUInteger, RAEventType) {
    RAEventUnknown = 0,
    RAEventSurgeAreaUpdate  = 1,
    RAEventSurgeAreaUpdates = 2
};

@interface RAEventDataModel : RABaseDataModel

@property (nonatomic) RAEventType type;

@end


@interface RAEventDataModel (RASurgeAreasEventProtocol) <RASurgeAreasEventProtocol>

- (NSArray<RASurgeAreaDataModel *> *)updatedSurgeAreas;

@end


@interface RAEventDataModel (RASurgeAreaEventProtocol) <RASurgeAreaEventProtocol>

- (RASurgeAreaDataModel *)updatedSurgeArea;

@end
