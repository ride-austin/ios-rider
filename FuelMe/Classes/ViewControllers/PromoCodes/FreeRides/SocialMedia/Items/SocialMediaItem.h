//
//  SocialMediaItem.h
//  Ride
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocialMediaItem : NSObject

@property (nonatomic, readonly) UIImage *icon;
@property (nonatomic, readonly) NSString *title;

-(instancetype)initWithTitle:(NSString*)title andImagenamed:(NSString*)imageName;

typedef void (^ShareCompletionBlock)(NSError *error);
-(void)shareText:(NSString*)text link:(NSString*)link title:(NSString*)title fromViewController:(UIViewController*)vc withCompletion:(ShareCompletionBlock)handler;

@end
