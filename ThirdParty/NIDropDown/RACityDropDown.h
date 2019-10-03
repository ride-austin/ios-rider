//
//  RACityDropDown.h
//  RACityDropDown
//
//  Created by Carlos Alcala on 11/19/16.
//

#import <UIKit/UIKit.h>
#import "RACity.h"

@class RACityDropDown;
@protocol RACityDropDownDelegate
- (void) RACityDropDownDidSelect:(RACity *)selected;
@end

@interface RACityDropDown : UIView <UITableViewDelegate, UITableViewDataSource> {
    NSString *animationDirection;
    UIImageView *imgView;
}

@property (nonatomic, retain) id <RACityDropDownDelegate> delegate;
@property (nonatomic, retain) NSString *animationDirection;
@property (nonatomic, retain) NSArray<RACity*> *list;

-(void)hideDropDown:(UIButton *)b;
-(id)showDropDown:(UIButton *)b height:(CGFloat)height options:(NSArray *)options direction:(NSString *)direction;

@end
