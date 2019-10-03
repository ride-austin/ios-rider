//
//  PlaceObject.h
//  PlaceSearchAPIDEMO
//
//  Created by Mrugrajsinh Vansadia on 25/04/14.
//  Copyright (c) 2014 Mrugrajsinh Vansadia. All rights reserved.
//

#import "PlaceIconTypes.h"
#import <Foundation/Foundation.h>
@interface PlaceObject : NSObject

@property (nonatomic) NSString *placeID;
@property (nonatomic) NSAttributedString *attributedFullText;
@property (nonatomic) NSAttributedString *attributedPrimaryText;
@property (nonatomic) NSAttributedString *attributedSecondaryText;
@property (nonatomic) NSArray<NSString *> *types;

- (instancetype)initWithFullText:(NSAttributedString *_Nonnull)fullText
                     primaryText:(NSAttributedString *_Nonnull)primaryText
                   secondaryText:(NSAttributedString *_Nonnull)secondaryText
                         placeID:(NSString *_Nonnull)placeID
                           types:(NSArray<NSString *> *_Nullable)types;
- (PlaceIconType)iconType;

@end

#import "MLPAutoCompletionObject.h"
@interface PlaceObject(MLPAutoCompletionObject) <MLPAutoCompletionObject>
@end
