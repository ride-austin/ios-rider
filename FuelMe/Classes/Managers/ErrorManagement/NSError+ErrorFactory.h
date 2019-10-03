//
//  NSError+ErrorFactory.h
//  Ride
//
//  Created by Theodore Gonzalez on 3/1/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

@interface NSError (ErrorFactory)

- (NSError * _Nonnull)filteredError;

@end

@interface NSError (ConstantErrors)

+ (NSError * _Nonnull)facebookPhoneNotProvidedError;
+ (NSError * _Nonnull)facebookEmailNotProvidedError;
+ (NSError * _Nonnull)accountNotEnabledError;
+ (NSError * _Nonnull)initiatedThirdPartyWhileOnTripError;

@end
