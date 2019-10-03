//
//  SupportTableViewController.m
//  Ride
//
//  Created by Robert on 7/2/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import "SupportTableViewController.h"

#import "SupportTopicAPI.h"
#import "UIViewController+tripHistoryNavigation.h"

@implementation SupportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.parentTopic.topicDescription;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 50;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.subTopics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SupportTripCell" forIndexPath:indexPath];
    
    NSString *issue = self.subTopics[indexPath.row].topicDescription;
    cell.textLabel.text = issue;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SupportTopic *supportTopic = self.subTopics[indexPath.row];
    [self showNextScreenForTopic:supportTopic withTripHistory:self.tripHistoryDataModel];
}

@end
