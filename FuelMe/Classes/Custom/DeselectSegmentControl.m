//
//  DeselectSegmentControl.m
//  Ride
//
//  Created by Theodore Gonzalez on 8/30/16.
//  Copyright © 2016 RideAustin.com. All rights reserved.
//

#import "DeselectSegmentControl.h"

@implementation DeselectSegmentControl {
    BOOL _touchBegan;
    BOOL _reactOnTouchBegan;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchBegan = YES;
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    [super touchesBegan:touches withEvent:event];
    if (_reactOnTouchBegan) {
        // before iOS7 the segment is selected in touchesBegan
        if (previousSelectedSegmentIndex == self.selectedSegmentIndex) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchBegan = NO;
    NSInteger previousSelectedSegmentIndex = self.selectedSegmentIndex;
    [super touchesEnded:touches withEvent:event];
    if (!_reactOnTouchBegan) {
        CGPoint locationPoint = [[touches anyObject] locationInView:self];
        CGPoint viewPoint = [self convertPoint:locationPoint fromView:self];
        if ([self pointInside:viewPoint withEvent:event]) {
            // on iOS7 the segment is selected in touchesEnded
            if (previousSelectedSegmentIndex == self.selectedSegmentIndex) {
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    if(controlEvents == UIControlEventValueChanged){
        _reactOnTouchBegan = _touchBegan;
    }
    [super sendActionsForControlEvents:controlEvents];
}

@end
