//
//  UIViewController+tripHistoryNavigation.m
//  Ride
//
//  Created by Theodore Gonzalez on 5/25/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "UIViewController+tripHistoryNavigation.h"

#import "LostItemFormViewController.h"
#import "NSObject+className.h"
#import "SupportTableViewController.h"
#import "SupportTopicAPI.h"
#import "SupportViewController.h"
#import "UIStoryboard+tripHistoryInvoker.h"

@implementation UIViewController (tripHistoryNavigation)

#pragma mark - Navigation

- (void)showNextScreenForTopic:(SupportTopic *)supportTopic withTripHistory:(TripHistoryDataModel *)tripHistory {
    if (supportTopic.hasChildren) {
        [self navigateToChildrenOfTopic:supportTopic withTripHistory:tripHistory];
    } else if (supportTopic.hasForms) {
        [self navigateToFormOfTopic:supportTopic withTripHistory:tripHistory];
    } else {
        [self showSupportViewControllerWithTopic:supportTopic andTripHistory:tripHistory];
    }
}

#pragma mark - Load Data

- (void)navigateToChildrenOfTopic:(SupportTopic *)supportTopic withTripHistory:(TripHistoryDataModel *)tripHistory {
    [SVProgressHUD show];
    [SupportTopicAPI getTopicsWithParentId:supportTopic.modelID withCompletion:^(NSArray<SupportTopic *> *supportTopics, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            if (supportTopics.count > 0) {
                [self showSupportListWithTopics:supportTopics fromParent:supportTopic andTripHistory:tripHistory];
            } else {
                [self showSupportViewControllerWithTopic:supportTopic andTripHistory:tripHistory];
            }
        }
    }];
}

- (void)navigateToFormOfTopic:(SupportTopic *)supportTopic withTripHistory:(TripHistoryDataModel *)tripHistory {
    [SVProgressHUD show];
    [SupportTopicAPI getFormForTopic:supportTopic withCompletion:^(LIOptionDataModel *form, NSError *error) {
        [SVProgressHUD dismiss];
        if (error) {
            [RAAlertManager showErrorWithAlertItem:error andOptions:[RAAlertOption optionWithState:StateActive]];
        } else {
            [self showFormViewControllerWithTopic:supportTopic form:form andTripHistory:tripHistory];
        }
        
    }];
}

#pragma mark - Show View Controllers

- (void)showFormViewControllerWithTopic:(SupportTopic *)supportTopic
                                   form:(LIOptionDataModel *)form
                         andTripHistory:(TripHistoryDataModel *)tripHistory {
    LostItemFormViewController *vc = (LostItemFormViewController *)[UIStoryboard tripHistoryViewControllerWithId:[LostItemFormViewController className]];
    [vc setFormDataModel:form andTripHistory:tripHistory];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSupportListWithTopics:(NSArray *)supportTopics
                       fromParent:(SupportTopic *)supportTopic
                   andTripHistory:(TripHistoryDataModel *)tripHistory {
    SupportTableViewController *vc = (SupportTableViewController *)[UIStoryboard tripHistoryViewControllerWithId:[SupportTableViewController className]];
    vc.tripHistoryDataModel = tripHistory;
    vc.parentTopic = supportTopic;
    vc.subTopics   = supportTopics;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showSupportViewControllerWithTopic:(SupportTopic *)supportTopic
                            andTripHistory:(TripHistoryDataModel *)tripHistory {
    SupportViewController *vc = (SupportViewController *)[UIStoryboard tripHistoryViewControllerWithId:[SupportViewController className]];
    vc.selectedSupportTopic = supportTopic;
    vc.tripHistoryDataModel = tripHistory;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
