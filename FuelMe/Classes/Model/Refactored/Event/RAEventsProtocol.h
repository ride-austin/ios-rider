//
//  RAEventsProtocol.h
//  Ride
//
//  Created by Theodore Gonzalez on 10/13/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

@class RASurgeAreaDataModel;

@protocol RASurgeAreasEventProtocol <NSObject>

@required
- (NSArray<RASurgeAreaDataModel *> *)updatedSurgeAreas;

@end

@protocol RASurgeAreaEventProtocol <NSObject>

@required
- (RASurgeAreaDataModel *)updatedSurgeArea;

@end
