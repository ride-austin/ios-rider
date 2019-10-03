//
//  NIDropDownDefines.h
//  Ride
//
//  Created by Carlos Alcala on 11/18/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#ifndef NIDropDownDefines_h
#define NIDropDownDefines_h

typedef enum : NSUInteger {
    Up = 0,
    Down
} DropDownType;

@protocol NIDropDownDelegate
- (void)niDropDownDidSelect:(NSString *)option;
@end


#endif /* NIDropDownDefines_h */
