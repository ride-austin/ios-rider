//
//  SystemVersionCompare.h
//  Ride
//
//  Created by Theodore Gonzalez on 11/15/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)
#endif /* SystemVersionCompare_h */
