//
//  GenderViewModel.h
//  Ride
//
//  Created by Theodore Gonzalez on 9/12/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConfigGlobal;
@class RAUserDataModel;

@interface GenderViewModel : NSObject

@property (nonatomic, readonly, nullable) NSString *title;
@property (nonatomic, readonly, nullable) NSString *subtitle;
@property (nonatomic, readonly, nullable) NSArray<NSString *> *genders;
@property (nonatomic, copy) void(^ _Nonnull didSaveGenderHandler)(RAUserDataModel * _Nonnull user);

+ (instancetype _Nonnull)viewModelWithConfig:(ConfigGlobal * _Nonnull)config andDidSaveGenderHandler:(void (^ _Nonnull)(RAUserDataModel * _Nonnull user))didSaveGenderHandler;
- (void)didSelectIndex:(NSUInteger)index withCompletion:(void (^ _Nonnull)(BOOL success))completion;

@end
