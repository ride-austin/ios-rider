//
//  RideAustinAutoCompleteTextField.m
//  Ride
//
//  Created by Todd Guion on 6/16/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "RideAustinPlaceSearchTextField.h"

NSString * const kRideAustinAutoCompleteCellReuseIdentifier = @"kRideAustinAutoCompleteCellReuseIdentifier";

@implementation RideAustinPlaceSearchTextField


- (CGFloat)autoCompleteFontSize {
    return 14.0;
}

- (CGFloat)detailAutoCompleteFontSize {
    return 13.0;
}

- (UIColor *)textColor {
    return [UIColor blackColor];
}

- (UIColor *)detailTextColor {
    return [UIColor grayColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = kRideAustinAutoCompleteCellReuseIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [self autoCompleteTableViewCellWithReuseIdentifier:cellIdentifier];
        cell.preservesSuperviewLayoutMargins = NO;
        cell.separatorInset = UIEdgeInsetsZero;
        cell.layoutMargins = UIEdgeInsetsZero;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    
    id<MLPAutoCompletionObject> autoCompleteResult = self.autoCompleteSuggestions[indexPath.row];
    
    [self configureCell:cell atIndexPath:indexPath withAutoCompleteResult:autoCompleteResult];
    
    
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
withAutoCompleteResult:(id<MLPAutoCompletionObject>)autoCompleteResult
{
    NSAttributedString *primaryAddress = autoCompleteResult.userInfo[@"primaryAddress"];
    NSAttributedString *secondaryAddress = autoCompleteResult.userInfo[@"secondaryAddress"];
    
    cell.textLabel.textColor = self.textColor;
    cell.textLabel.attributedText = primaryAddress;
    cell.detailTextLabel.textColor = self.detailTextColor;
    cell.detailTextLabel.attributedText = secondaryAddress;
    
    [cell.textLabel setFont:[UIFont fontWithName:self.font.fontName size:self.autoCompleteFontSize]];
    [cell.detailTextLabel setFont:[UIFont fontWithName:self.font.fontName size:self.detailAutoCompleteFontSize]];
    
    NSString *accessibilityLabel = [NSString stringWithFormat:@"%@, %@",primaryAddress.string,secondaryAddress.string];
    cell.accessibilityLabel = accessibilityLabel;
    
    if(self.autoCompleteTableCellTextColor){
        [cell.textLabel setTextColor:self.autoCompleteTableCellTextColor];
    }
}

@end
