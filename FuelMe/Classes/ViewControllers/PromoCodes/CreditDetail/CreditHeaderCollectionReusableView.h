//
//  CreditHeaderCollectionReusableView.h
//  Ride
//
//  Created by Roberto Abreu on 8/30/17.
//  Copyright © 2017 RideAustin.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditHeaderCollectionReusableView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *lblTitleHeader;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalCredit;

@end
