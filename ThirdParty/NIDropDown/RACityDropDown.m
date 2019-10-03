//
//  RACityDropDown.m
//  RACityDropDown
//
//  Created by Carlos Alcala on 11/19/16.
//

#import "RACityDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface RACityDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, assign) CGFloat rowHeight;

@end

@implementation RACityDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize delegate;
@synthesize animationDirection;

- (id)showDropDown:(UIButton *)b height:(CGFloat)height options:(NSArray *)options direction:(NSString *)direction {
    btnSender = b;
    animationDirection = direction;
    self.table = (UITableView *)[super init];
    self.rowHeight = 30;
    if (self) {
        // Initialization code
        CGRect btn = b.frame;
        self.list = [NSArray arrayWithArray:options];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        self.table.delegate = self;
        self.table.dataSource = self;
        self.table.layer.cornerRadius = 5;
        self.table.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
        self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y-height, btn.size.width, height);
        } else if([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, height);
        }
        self.table.frame = CGRectMake(0, 0, btn.size.width, height);
        [UIView commitAnimations];
        [b.superview addSubview:self];
        [self addSubview:self.table];
    }
    return self;
}

-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    }
    
    self.layer.cornerRadius = 0;
    self.layer.shadowRadius = 0;
    self.layer.shadowOpacity = 0;
    
    self.table.frame = CGRectMake(0, 0, btn.size.width, 0);
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    RACity* city = [self.list objectAtIndex:indexPath.row];
    
    cell.textLabel.text = city.displayName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.imageView.backgroundColor = [UIColor clearColor];
    
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor grayColor];
    cell.selectedBackgroundView = v;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:btnSender];
    
    RACity* selectedCity = [self.list objectAtIndex:indexPath.row];
    
    if (self.delegate) {
        [self.delegate RACityDropDownDidSelect:selectedCity];
    }
}

@end
