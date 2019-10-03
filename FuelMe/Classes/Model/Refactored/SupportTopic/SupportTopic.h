//
//  SupportTopic.h
//  Ride
//
//  Created by Robert on 9/3/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RABaseDataModel.h"

@interface SupportTopic : RABaseDataModel

@property (nonatomic, readonly) NSString *topicDescription;
@property (nonatomic, readonly) BOOL hasChildren;
@property (nonatomic, readonly) BOOL hasForms;

@end
