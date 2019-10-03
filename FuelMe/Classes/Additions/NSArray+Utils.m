//
//  NSArray+Utils.m
//  Ride
//
//  Created by Carlos Alcala on 9/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "NSArray+Utils.h"
#import "Contact.h"
#import "RAMacros.h"

@implementation NSArray (Utils)

+ (NSArray *)namesForContacts:(NSArray *)contacts {
    NSMutableArray *names = [NSMutableArray array];
    for (Contact *contact in contacts) {
        NSString *name = nil;
        
        //check lastname to include on name or not
        if (!IS_EMPTY(contact.lastName)) {
            name = [NSString stringWithFormat:@"%@ %@", contact.firstName, contact.lastName];
        } else {
            name = contact.firstName;
        }
        
        
        [names addObject:name];
    }
    return names;
}

+ (NSArray *)phonesForContacts:(NSArray *)contacts {
    NSMutableArray *phones = [NSMutableArray array];
    for (Contact *contact in contacts) {
        NSString *phone = nil;
        
        //check lastname to include on name or not
        if (contact.phoneNumbers.count > 0) {
            //send first number
            phone = [contact.phoneNumbers firstObject];
            [phones addObject:phone];
        }
    }
    return phones;
}

- (NSArray*)sortArrayWithKey:(NSString*)key withAscending:(BOOL)ascending {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:key ascending:ascending selector:@selector(compare:)];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *sortedArray = [self sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

- (NSArray *)mapWithBlock:(id _Nullable(^)(id _Nonnull, BOOL * _Nonnull stop))mapBlock {
    __block NSMutableArray *mutableArray = [NSMutableArray new];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id mapObject = mapBlock(obj, stop);
        if (mapObject) {
            [mutableArray addObject:mapObject];
        }
    }];
    return mutableArray;
}

@end
