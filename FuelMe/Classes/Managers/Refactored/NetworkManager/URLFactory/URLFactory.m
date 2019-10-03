//
//  URLFactory.m
//  Ride
//
//  Created by Theodore Gonzalez on 2/22/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "URLFactory.h"

NSString *const kPathActiveDrivers      = @"acdr";
NSString *const kPathGlobalConfig       = @"configs/rider/global";
NSString *const kPathRequiredVersion    = @"configs/app/info/current?avatarType=RIDER&platformType=IOS";

NSString *const kPathCampaignsProviders = @"campaigns/providers/%@/campaigns";
NSString *const kPathCampaignsSpecific  = @"campaigns/%@";
NSString *const kPathCharities			= @"charities";
NSString *const kPathEvents				= @"events";

NSString *const kPathDrivers            = @"drivers";
NSString *const kPathDriversCarTypes    = @"drivers/carTypes";
//NSString *const KPathDriverTypes        = @"driverTypes";
NSString *const kPathDriversDocuments 	= @"driversDocuments/%@";
NSString *const kDriverPhotoPath        = @"drivers/%@/photo";
NSString *const kPathPhotos 			= @"photos";
NSString *const kPathDriverCarPhoto     = @"carphotos/car/%@";
NSString *const kPathDriverCars         = @"drivers/%@/cars";
NSString *const kPathDriverDirectConnect = @"drivers/connect/%@";
NSString *const kPathDriverDirectConnectHistory = @"rides/history/direct";
NSString *const kPathDriverCheckrPayment = @"drivers/%@/checkr/payment";

NSString *const kPathRides 				= @"rides";
NSString *const kPathRidesCurrent       = @"rides/current?avatarType=RIDER";
NSString *const kPathRidesSpecific 		= @"rides/%@?avatarType=RIDER";
NSString *const kPathRidesGetShareToken = @"rides/%@/getShareToken";
NSString *const kPathRidesMap           = @"rides/%@/map";
NSString *const kPathRidesRating        = @"rides/%@/rating";
NSString *const kPathRidesCancellation  = @"rides/cancellation";
NSString *const kPathRidesCancellationRide = @"rides/cancellation/%@";
NSString *const kPathRidesEstimate      = @"rides/estimate";
NSString *const kPathRidesQueue         = @"rides/queue/%@";
NSString *const kPathRidesSpecialFees   = @"rides/specialFees";
NSString *const kPathRidesUpgrade       = @"rides/upgrade";

NSString *const kPathRidersCurrent      = @"riders/current";
NSString *const kPathRidersSpecific 	= @"riders/%@";
NSString *const kPathRidersCards        = @"riders/%@/cards";
NSString *const kPathRidersCardsSpecific= @"riders/%@/cards/%@";
NSString *const kPathRidersPayments     = @"riders/%@/payments";
NSString *const kPathRidersPayUnpaidBalance = @"riders/%@/payments/pending";
NSString *const kPathStudentEmailVerification = @"emailVerification/verify";
NSString *const kPathRidersPromoCode    = @"riders/%@/promocode";
NSString *const kPathRidersRedemptions  = @"riders/%@/promocode/redemptions";
NSString *const kPathRidersRedemptionsReminder = @"/rest/riders/%@/promocode/remainder";

NSString *const kPathSurgeAreas 		= @"surgeareas";

NSString *const kPathLogin 				= @"login";
NSString *const kPathLogout             = @"logout";
NSString *const kPathFacebookLogin 		= @"facebook";
NSString *const kPathRecoverPassword 	= @"forgot";
NSString *const kPathChangePassword     = @"password";
NSString *const kPathTokens             = @"tokens";

NSString *const kPathUsers              = @"users";
NSString *const kPathUsersCurrent       = @"users/current";
NSString *const kPathUsersExists 		= @"users/exists";
NSString *const kPathUsersSpecific      = @"users/%@";

NSString *const kPathSupport              = @"support";
NSString *const kPathSupportTopic         = @"supporttopics/list/RIDER";
NSString *const kPathSupportTopicChildren = @"supporttopics/%@/children";
NSString *const kPathSupportTopicForm     = @"supporttopics/%@/form";
NSString *const kPathSupportTopicMessage  = @"/rest/support/default";

NSString *const kPathLostAndFoundLost     = @"lostandfound/lost";
NSString *const kPathLostAndFoundFound    = @"lostandfound/found";
NSString *const kPathLostAndFoundContact  = @"lostandfound/contact";

NSString *const kPathPhoneVerificationVerify      = @"phoneVerification/verify";
NSString *const kPathPhoneVerificationRequestCode = @"phoneVerification/requestCode";

NSString *const kPathRequestSplitFareForRide = @"splitfares/%@?%@";
NSString *const kPathSplitFareAccept         = @"splitfares/%@/accept";
NSString *const kPathSplitFareRequested      = @"splitfares/%@/requested";
NSString *const kPathSplitFareList           = @"splitfares/%@/list";
NSString *const kPathSplitFareSpecific       = @"splitfares/%@";
