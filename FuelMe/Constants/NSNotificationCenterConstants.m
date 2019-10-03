#import "NSNotificationCenterConstants.h"

#pragma mark - SplitFare
NSString * const kNotificationDidUpdateCurrentRider = @"kNotificationDidUpdateCurrentRider";
NSString * const kNotificationDidUpdateCurrentUserGender = @"kNotificationDidUpdateCurrentUserGender";
NSString * const kNotificationDidUpdateFemaleDriverSwitch = @"kNotificationDidUpdateFemaleDriverSwitch";
NSString * const kNotificationSplitFareDeclined     = @"kNotificationSplitFareDeclined";
NSString * const kNotificationSplitFareAccepted     = @"kNotificationSplitFareAccepted";
NSString * const kNotificationSplitFareRequested    = @"kNotificationSplitFareRequested";
NSString * const kNotificationSplitFareDataUpdated  = @"kNotificationSplitFareDataUpdated";

#pragma mark - SurgeArea
NSString * const kSurgeAreaUpdateNotification = @"kSurgeAreaUpdateNotification";

#pragma mark - Places
NSString * const kPlaceSearchSelectedNotification = @"kPlaceSearchSelectedNotification";
NSString * const kFavoritePlaceChangedNotification = @"kFavoritePlaceChangedNotification";

#pragma mark - Ride Synchronization
NSString * const kNotificationShouldSynchronizeCurrentRide = @"kNotificationShouldSynchronizeCurrentRide";

#pragma mark - Category Slider Image
NSString * const kNotificationDidDownloadSliderImage = @"kNotificationDidDownloadSliderImage";

#pragma mark - Picker Address
NSString * const kNotificationPickerAddressWillAppear   = @"kNotificationPickerAddressWillAppear";
NSString * const kNotificationPickerAddressDidDisappear = @"kNotificationPickerAddressDidDisappear";

NSString * const kNotificationAddressValuesFilled = @"kNotificationAddressValuesFilled";
