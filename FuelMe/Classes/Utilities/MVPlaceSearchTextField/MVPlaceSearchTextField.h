//
//  MVPlaceSearchTextField.h
//  PlaceSearchAPIDEMO
//
//  Created by Mrugrajsinh Vansadia on 26/04/14.
//  Copyright (c) 2014 Mrugrajsinh Vansadia. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "MLPAutoCompleteTextField.h"
#import "MVPlaceSearchTextField.h"
#import "PlaceObject.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
@protocol PlaceSearchTextFieldDelegate;

@interface MVPlaceSearchTextField : MLPAutoCompleteTextField

@property(nonatomic,weak) IBOutlet id<PlaceSearchTextFieldDelegate>placeSearchDelegate;
@property (nonatomic,weak) GMSMapView *mapview;

@end

@protocol PlaceSearchTextFieldDelegate <NSObject>

@optional
//RA-4623
-(void)placeSearchDidSelectARow:(MVPlaceSearchTextField*)textfield;
-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace*)responseDict;
-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField;
-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField;
-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index;
@end

