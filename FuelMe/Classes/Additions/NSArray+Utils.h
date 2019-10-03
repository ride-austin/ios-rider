//
//  NSArray+Utils.h
//  Ride
//
//  Created by Carlos Alcala on 9/2/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utils)

+ (NSArray* _Nonnull)namesForContacts:(NSArray * _Nonnull)contacts;
+ (NSArray* _Nonnull)phonesForContacts:(NSArray * _Nonnull)contacts;
- (NSArray* _Nonnull)sortArrayWithKey:(NSString * _Nonnull)key withAscending:(BOOL)ascending;
- (NSArray* _Nonnull)mapWithBlock:(id _Nullable(^_Nonnull)(id _Nonnull, BOOL * _Nonnull stop))mapBlock;

@end
