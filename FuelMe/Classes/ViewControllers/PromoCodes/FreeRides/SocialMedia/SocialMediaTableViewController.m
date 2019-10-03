//
//  SocialMediaTableViewController.m
//  Ride
//
//  Created by Kitos on 11/7/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SocialMediaTableViewController.h"
#import "NSString+Utils.h"
#import "SMFacebookItem.h"
#import "SMTwitterItem.h"
#import "SMWhatsappItem.h"
#import <Crashlytics/Crashlytics.h>

static NSString *const kSMItemCellIdentifier = @"kSMItemCellIdentifier";

@interface SocialMediaTableViewController ()

@property (nonatomic, strong) NSArray <SocialMediaItem*> *items;

@end

@implementation SocialMediaTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [@"Free Rides" localized];

    SMWhatsappItem *whatsItem = [SMWhatsappItem new];
    SMFacebookItem *fbItem    = [SMFacebookItem new];
    SMTwitterItem *twItem     = [SMTwitterItem  new];
    
    self.items = @[whatsItem, fbItem, twItem];
}

@end


@implementation SocialMediaTableViewController (TableDatasource)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kSMItemCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSMItemCellIdentifier];
    }
    
    SocialMediaItem *smItem = self.items[indexPath.row];
    
    cell.imageView.image = smItem.icon;
    CGFloat widthScale  = 30.0 / smItem.icon.size.width;
    CGFloat heightScale = 30.0 / smItem.icon.size.height;
    cell.imageView.transform = CGAffineTransformMakeScale(widthScale, heightScale);
    cell.textLabel.text = smItem.title;
    cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

@end

@implementation SocialMediaTableViewController (TableDelegate)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SocialMediaItem *smItem = self.items[indexPath.row];

    [smItem shareText:self.sharingText link:self.downloadURL title:nil fromViewController:self withCompletion:^(NSError *error) {
        if (error) {
            NSString *message = error.localizedRecoverySuggestion;
            if (!message) {
                message = error.localizedFailureReason;
            }
            if (!message) {
                message = error.localizedDescription;
            }
            if (!message) {
                message = [NSString stringWithFormat:@"Unknown error. Status: %ld",(long)error.code];
            }
            
            //log error
            [CrashlyticsKit recordError:error];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ok",@"") style:UIAlertActionStyleCancel handler:nil];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"GENERIC_ERROR_TITLE", @"") message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:okAction];
            
            __weak SocialMediaTableViewController *weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

@end
