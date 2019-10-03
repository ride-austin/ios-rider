//
//  SocialMediaItem.m
//  Ride
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SocialMediaItem.h"
#import "RAMacros.h"

@interface SocialMediaItem ()

@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSString *title;

@end

@implementation SocialMediaItem

-(instancetype)initWithTitle:(NSString *)title andImagenamed:(NSString *)imageName{
        self = [super init];
        
        if (self) {
            self.title = title;
            self.icon = [UIImage imageNamed:imageName];
        }
        
        return self;

}

-(void)shareText:(NSString *)text link:(NSString *)link title:(NSString*)title fromViewController:(UIViewController *)vc withCompletion:(ShareCompletionBlock)handler{
    DBLog(@"WARNING: shareText this should be implemented in sub-class");
}

@end
