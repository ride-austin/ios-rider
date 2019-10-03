#import <Foundation/Foundation.h>
#import "RABaseDataModel.h"

@interface RADirectConnectHistory : RABaseDataModel

@property (nonatomic, nonnull) NSString *directConnectId;
@property (nonatomic, nonnull) NSString *driverFirstName;
@property (nonatomic, nonnull) NSString *driverLastName;
/// 08/17/2019 02:21 AM
/// requestedAt is mandatory but Date can be decoded incorrectly
@property (nonatomic, nullable) NSDate *requestedAt;
@property (nonatomic, nullable) NSURL *photoURL;

@end
