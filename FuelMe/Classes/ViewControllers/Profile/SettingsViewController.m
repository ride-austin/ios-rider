//
//  SettingsViewController.m
//  Ride
//
//  Created by Tyson Bunch on 5/19/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "SettingsViewController.h"

#import "ConfigurationManager.h"
#import "EditViewController.h"
#import "LocationService.h"
#import "NSNotificationCenterConstants.h"
#import "NSString+Utils.h"
#import "RAAddress.h"
#import "RAEnvironmentManager.h"
#import "RAFavoritePlacesManager.h"
#import "RAMacros.h"
#import "RARideManager.h"
#import "SelectPlaceMapViewController.h"
#import "SettingsSection.h"
@import UserNotifications;

#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kFavoritePlacesSectionTitle = @"Favorite Places";
static NSString * const kAboutSectionTitle = @"About";
static NSString * const kNotificationSectionTitle = @"Notifications";

static NSString * const kPushNotificationTitle = @"Enable Notifications";
static NSString * const kPushNotificationSubTitle = @"Receive notifications related to your trip";
static NSString * const kRate    = @"Rate us in the app store";
static NSString * const kLike    = @"Like us on Facebook";
static NSString * const kLegal   = @"Legal";
static NSString * const kSupport = @"Contact Support";
static NSString * const kSignout = @"Sign out";

static NSUInteger const kIconCellTag = 423;

@interface SettingsViewController ()  <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ivActivityIndicatorView;
@property (nonatomic) NSMutableArray<SettingsSection *> *sections;

@end

@implementation SettingsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sections = [NSMutableArray array];
    [self configureTable];
    [self configureObservers];
    [self updateData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    __weak __typeof__(self) weakself = self;
    self.title = [@"Settings" localized];

    RAUserDataModel *user = [[RASessionManager sharedManager] currentUser];
    self.name.text = user.fullName;
    
    if (user.photoURL) {
        [self.ivActivityIndicatorView startAnimating];
        [self.icon sd_setImageWithURL:user.photoURL placeholderImage:[UIImage imageNamed:@"person_placeholder"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [weakself.ivActivityIndicatorView stopAnimating];
        }];
    } else {
        DBLog(@"PHOTO URL MISSING");
        self.icon.image = [UIImage imageNamed:@"person_placeholder"];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureTable {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setScrollEnabled: YES];
    
    UIColor *textColor = [UIColor colorWithRed:7.0/255.0 green:13.0/255.0 blue:22.0/255.0 alpha:1.0];
    UIFont *font = [UIFont fontWithName:FontTypeRegular size:12];
    if (@available(iOS 9.0,*)) {
        [[UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableViewHeaderFooterView.class]] setFont:font];
        [[UILabel appearanceWhenContainedInInstancesOfClasses:@[UITableViewHeaderFooterView.class]] setTextColor:textColor];
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:font];
        [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:textColor];
        #pragma clang diagnostic pop
    }
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:kNotificationDidChangeCurrentCityType object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)updateData {
    __weak __typeof__(self) weakself = self;
    [self.sections removeAllObjects];
    
    //Section - Favorites
    RAHomeFavoritePlace *home = [RAFavoritePlacesManager homePlace] ?: [RAHomeFavoritePlace new];
    RAWorkFavoritePlace *work = [RAFavoritePlacesManager workPlace] ?: [RAWorkFavoritePlace new];
    SettingsSection *favoriteSection = [SettingsSection favoritesSectionWithTitle:[kFavoritePlacesSectionTitle localized] places:@[home, work]];
    [self.sections addObject:favoriteSection];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus != UNAuthorizationStatusAuthorized) {
            SettingsItem *pushNotification = [SettingsItem itemWithTitle:[kPushNotificationTitle localized] subtitle:kPushNotificationSubTitle didSelectBlock:^{
                UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
                [center requestAuthorizationWithOptions:options
                                      completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                          if (error) {
                                              [RAAlertManager showAlertWithTitle:[ConfigurationManager appName] message:error.localizedDescription];
                                          } else {
                                              if (granted) {
                                                  [weakself updateData];
                                              } else {
                                                  [weakself showSettingsAlert];
                                              }
                                          }
                                      }];
            }];
            SettingsSection *notificationSection = [SettingsSection sectionWithTitle:[kNotificationSectionTitle localized]];
            [notificationSection addObject:pushNotification];
            [weakself.sections insertObject:notificationSection atIndex:1];
        }
        
    }];
    
    //Section - About
    SettingsItem *rating =  [SettingsItem itemWithTitle:[kRate localized]
                                               subtitle:[RAEnvironmentManager sharedManager].version
                                                mainURL:self.generalInfo.appstoreLink];
    rating.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    SettingsItem *fb = [SettingsItem itemWithTitle:[kLike localized]
                                           mainURL:self.generalInfo.facebookUrl];
    
    SettingsItem *legal = [SettingsItem itemWithTitle:[kLegal localized]
                                              mainURL:self.generalInfo.legalRiderURL];
    
    SettingsItem *web = [SettingsItem itemWithTitle:self.generalInfo.companyDomain
                                            mainURL:self.generalInfo.companyWebsite];
    
    SettingsItem *support = [SettingsItem itemWithTitle:[kSupport localized] didSelectBlock:^{
        NSNumber *cityID = [ConfigurationManager shared].global.currentCity.cityID;
        [weakself showMessageViewWithRideID:nil cityID:cityID];
    }];
    
    SettingsSection *aboutSection = [SettingsSection sectionWithTitle:[kAboutSectionTitle localized]];
    [aboutSection addObject:rating];
    [aboutSection addObject:fb];
    [aboutSection addObject:legal];
    [aboutSection addObject:web];
    [aboutSection addObject:support];
    [self.sections addObject:aboutSection];
    
    //Section - Logout
    SettingsSection *logoutSection = [SettingsSection sectionWithTitle:@"    "];
    [logoutSection addObject:[SettingsItem itemWithTitle:[kSignout localized] didSelectBlock:^{
        if ([RARideManager sharedManager].isRiding) {
            [RAAlertManager showAlertWithTitle:[ConfigurationManager appName]
                                       message:@"You cannot logout while on active ride."];
        } else {
            [weakself showHUD];
            [[RASessionManager sharedManager] logoutWithCompletion:^(NSError *error) {
                [weakself hideHUD];
            }];
        }
    }]];
    [self.sections addObject:logoutSection];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (void)showSettingsAlert {
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nullable action) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(currentUserNotificationSettings)]) {
            UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            
            if (grantedSettings.types == UIUserNotificationTypeNone)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"app-settings:"]];
            }
        }

    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Please enable notifications from settings." preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:cancelAction];
    [alert addAction:settingsAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (RAGeneralInfo *)generalInfo {
    return [ConfigurationManager shared].global.generalInfo;
}

#pragma mark - Actions

- (IBAction)editAccount:(id)sender {
    EditViewController *eVC = [[EditViewController alloc] init];
    [self.navigationController pushViewController:eVC animated:YES];
}

#pragma mark - UITableView

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section].title;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *)view;
    tableViewHeaderFooterView.textLabel.font = [UIFont fontWithName:FontTypeRegular size:12];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].rowCount;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsSection *sect = self.sections[indexPath.section];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:sect.cellIdentifier];
    
    if (sect.type == SectionTypeFavoritePlaces) {
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:sect.cellIdentifier];
          
            cell.textLabel.font = [UIFont fontWithName:FontTypeRegular size:12];
            cell.textLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
            cell.detailTextLabel.font = [UIFont fontWithName:FontTypeLight size:10];
            cell.detailTextLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        RAFavoritePlace *place = sect.places[indexPath.row];
        cell.textLabel.text = place.name;
        cell.detailTextLabel.text = place.shortAddress;
        
        cell.imageView.image = [UIImage imageNamed:@"cellIconBlank"];
        cell.imageView.hidden = YES;
        
        UIView *iconIV = [cell.contentView viewWithTag:kIconCellTag];
        [iconIV removeFromSuperview];
        
        UIImageView *iv = [[UIImageView alloc] initWithImage:place.blackScaledIcon];
        iv.tag = kIconCellTag;
        CGPoint center = iv.center;
        center.x = 25;
        center.y = cell.contentView.center.y;
        iv.center = center;
        
        [cell.contentView addSubview:iv];
    }
    else {
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sect.cellIdentifier];
            cell.textLabel.font = [UIFont fontWithName:FontTypeRegular size:12];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.font = [UIFont fontWithName:FontTypeLight size:10];
        }
        
        cell.textLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:67.0/255.0 blue:80.0/255.0 alpha:1.0];
        
        SettingsItem *item = sect.items[indexPath.row];
        cell.textLabel.text = item.title;
        cell.detailTextLabel.text = item.subTitle;
        cell.accessoryType = item.accessoryType;
        cell.detailTextLabel.textColor = item.subTitle ?
        [UIColor colorWithRed:60.0/255.0 green: 67.0/255.0 blue: 80.0/255.0 alpha:1.0] :
        [UIColor colorWithRed: 2.0/255.0 green:167.0/255.0 blue:249.0/255.0 alpha:1.0];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SettingsSection *section = self.sections[indexPath.section];
    if (section.type == SectionTypeFavoritePlaces) {
        //setting button back title to nil is not working!
        self.title = @"";
        
        RAFavoritePlace *place = section.places[indexPath.row];

        SelectPlaceMapViewController *smvc = [[SelectPlaceMapViewController alloc] init];
        smvc.title = place.name;
        smvc.descriptionTitle = place.name;
        smvc.icon = [UIImage imageNamed:place.blackIconName];
        smvc.iconFrame = CGRectMake(10, 10, 20, 20);
        
        if (place.isCoordinateValid) {
            smvc.initialLocation = [[CLLocation alloc] initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
            smvc.initialAddress = place.shortAddress;
        }
        __weak __typeof__(self) weakself = self;
        smvc.selectedPlaceBlock = ^(RAAddress *address) {
            [weakself.navigationController popViewControllerAnimated:YES];
            place.coordinate    = address.location.coordinate;
            place.shortAddress  = address.address;
            place.fullAddress   = address.fullAddress;
            
            [RAFavoritePlacesManager saveFavoritePlace:place];
            [self updateData];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFavoritePlaceChangedNotification object:nil];
        };
        
        [self.navigationController showViewController:smvc sender:self];
    } else if (section.type == SectionTypeNormal) {
        SettingsItem *item = section.items[indexPath.row];
        UIApplication *app = [UIApplication sharedApplication];
        if (item.didSelectBlock) {
            item.didSelectBlock();
        } else if ([app canOpenURL:item.mainURL]) {
            [app openURL:item.mainURL];
        } else if ([app canOpenURL:item.secondaryURL]) {
            [app openURL:item.secondaryURL];
        }
    }
}

@end
