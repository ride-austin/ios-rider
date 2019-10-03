//
//  RAInspectionStickerDetail.m
//  Ride
//
//  Created by Roberto Abreu on 9/12/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RAInspectionStickerDetail.h"

#define kDefaultNavBarTitle @"Auto Inspection Sticker"
#define kDefaultTitle @"Take a photo of your Inspection Sticker"
#define kDefaultContent @"Please make sure that we can easiliy read all the details"

@implementation RAInspectionStickerDetail

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return
    @{
      @"navBarTitle":@"header",
      @"title":@"title1",
      @"content":@"text1",
      @"minYearRequired":@"sticker_required_year",
      @"isEnabled":@"enabled"
      };
}

- (NSString *)navBarTitle {
    return _navBarTitle ? _navBarTitle : kDefaultNavBarTitle;
}

- (NSString *)title {
    return _title ? _title : kDefaultTitle;
}

- (NSString *)content {
    return _content ? _content : kDefaultContent;
}

@end
