//
//  ConfigReferRider.m
//  Ride
//
//  Created by Theodore Gonzalez on 11/10/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "ConfigReferRider.h"

@implementation ConfigReferRider

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
              @"enabled":@"enabled",
              @"tempDetailText":@"detailtexttemplate",
              @"tempEmailBody":@"emailbodytemplate",
              @"tempSMSBody":@"smsbodytemplate",
              @"downloadURL":@"downloadUrl"
            };
}

/**
 *  mantle will return nil object if one of the conditions is false
 */
- (BOOL)validate:(NSError **)error {
    return [super validate:error] &&
            self.tempDetailText.length > 0 &&
            self.tempEmailBody.length  > 0 &&
            self.tempSMSBody.length    > 0 &&
            self.downloadURL.length    > 0;
}
/**
{
    detailtexttemplate = "Every time a new RideAustin user signs up with your invite code, they'll receive their first ride free. Once they take their first ride, you'll automatically get <codeValue> credited into your account (up to $500)";
    downloadUrl = "www.rideaustin.com";
    emailbodytemplate = "<p>You should try RideAustin! Get <codeValue> in ride credit using my code <b><codeLiteral><b>. Download the app at: <downloadUrl></p>";
    smsbodytemplate = "You should try RideAustin! Get <codeValue> in ride credit using my code <codeLiteral> Download the app at: <downloadUrl>";
}
*/
@end
