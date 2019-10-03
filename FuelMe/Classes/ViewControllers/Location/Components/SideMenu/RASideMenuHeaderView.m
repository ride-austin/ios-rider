//
//  RASideMenuHeaderView.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/27/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "RASideMenuHeaderView.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface RASideMenuHeaderView()

@property (weak, nonatomic) IBOutlet UIButton *btHeader;
@property (weak, nonatomic) IBOutlet UIImageView *ivRider;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ivActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UILabel *lbRider;

@end

@implementation RASideMenuHeaderView

- (instancetype)initWithWidth:(CGFloat)width target:(id)target action:(SEL)action {
    CGRect frame = CGRectMake(0, 0, width, 77);
    if (self = [super initWithFrame:frame]) {
        self.accessibilityElementsHidden = YES;
        [self.btHeader addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)updateName:(NSString *)name imageURL:(NSURL *)imageURL {
    _lbRider.text = name;
    __weak __typeof__(self) weakself = self;
    [self.ivActivityIndicatorView startAnimating];
    [_ivRider sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"Icon-user"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [weakself.ivActivityIndicatorView stopAnimating];
    }];
}

+ (instancetype)viewWithWidth:(CGFloat)width target:(id)target action:(SEL)action {
    return [[self alloc] initWithWidth:width target:target action:action];
}

@end
