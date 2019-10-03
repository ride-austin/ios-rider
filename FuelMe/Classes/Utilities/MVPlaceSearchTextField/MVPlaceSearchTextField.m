//
//  MVPlaceSearchTextField.m
//  PlaceSearchAPIDEMO
//
//  Created by Mrugrajsinh Vansadia on 26/04/14.
//  Copyright (c) 2014 Mrugrajsinh Vansadia. All rights reserved.
//


#import "ConfigurationManager.h"
#import "LocationService.h"
#import "MLPAutoCompleteTextField.h"
#import "MVPlaceSearchTextField.h"
#import "PlaceObject.h"
#import "RAPlacesQueryAPI.h"
#import "RAMacros.h"

@interface MVPlaceSearchTextField ()
<MLPAutoCompleteFetchOperationDelegate,
MLPAutoCompleteSortOperationDelegate,
MLPAutoCompleteTextFieldDelegate
>

@end


@implementation MVPlaceSearchTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    RAPlacesQueryAPI *queryAPI = [[RAPlacesQueryAPI alloc] initWithMapView:self.mapview];
    self.autoCompleteDataSource = queryAPI;
    self.autoCompleteDelegate = self;
    self.autoCompleteFontSize = 14;
    self.autoCompleteTableBorderWidth = 0.0;
    self.showTextFieldDropShadowWhenAutoCompleteTableIsOpen = NO;
    self.autoCompleteShouldHideOnSelection = YES;
    self.maximumNumberOfAutoCompleteRows = 5;
    self.autoCompleteShouldHideClosingKeyboard = YES;
}


#pragma mark - AutoComplete Delegates
- (void)autoCompleteDidSelectARow {
    if ([self.placeSearchDelegate respondsToSelector:@selector(placeSearchDidSelectARow:)]) {
        [self.placeSearchDelegate placeSearchDidSelectARow:self];
    }
}

-(void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didSelectAutoCompleteString:(NSString *)selectedString withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlaceObject *place = (PlaceObject *)selectedObject;
    
    __weak __typeof__(self) weakself = self;
    [[GMSPlacesClient sharedClient] lookUpPlaceID:place.placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
        if (result) {
            [weakself.placeSearchDelegate placeSearch:self ResponseForSelectedPlace:result];
        } else {
            DBLog(@"%@", error);
        }
    }];
}
- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
         shouldConfigureCell:(UITableViewCell *)cell
      withAutoCompleteString:(NSString *)autocompleteString
        withAttributedString:(NSAttributedString *)boldedString
       forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
           forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([_placeSearchDelegate respondsToSelector:@selector(placeSearch:ResultCell:withPlaceObject:atIndex:)]){
        [_placeSearchDelegate placeSearch:self ResultCell:cell withPlaceObject:autocompleteObject atIndex:indexPath.row];
    }else{
        cell.contentView.backgroundColor=[UIColor whiteColor];
    }
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    if([_placeSearchDelegate respondsToSelector:@selector(placeSearchWillShowResult:)]){
        [_placeSearchDelegate placeSearchWillShowResult:self];
    }
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    if([_placeSearchDelegate respondsToSelector:@selector(placeSearchWillHideResult:)]){
        [_placeSearchDelegate placeSearchWillHideResult:self];
    }
}

@end
