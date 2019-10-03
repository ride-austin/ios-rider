//
//  VKSideMenu.m
//
//  Created by Vladislav Kovalyov on 2/7/16.
//  Copyright © 2016 WOOPSS.com (http://woopss.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VKSideMenu.h"
#import "DNA.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define ROOTVC [[[[UIApplication sharedApplication] delegate] window] rootViewController]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation VKSideMenuItem

@synthesize icon;
@synthesize title;
@synthesize tag;
@end

@interface VKSideMenu() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation VKSideMenu

#pragma mark - Initialization

-(instancetype)init
{
    if (self = [super init])
    {
        [self baseInit];
    }
    
    return self;
}

-(instancetype)initWithWidth:(CGFloat)width andDirection:(VKSideMenuDirection)direction
{
    if ((self = [super init]))
    {
        [self baseInit];
        
        self.width      = width;
        self.direction  = direction;
    }
    
    return self;
}

-(void)baseInit
{
    self.width                      = 220;
    self.direction                  = VKSideMenuDirectionLeftToRight;
    self.enableOverlay              = YES;
    self.automaticallyDeselectRow   = YES;
    self.hideOnSelection            = YES;
    
    self.sectionTitleFont   = [UIFont systemFontOfSize:15.];
    self.selectionColor     = [UIColor colorWithWhite:1. alpha:.5];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    self.backgroundColor    = [UIColor colorWithWhite:1. alpha:.8];
#pragma clang diagnostic pop
    self.textColor          = UIColorFromRGB(0x252525);
    self.iconsColor         = UIColorFromRGB(0x8f8f8f);
    self.sectionTitleColor  = UIColorFromRGB(0x8f8f8f);
    
    if(!SYSTEM_VERSION_LESS_THAN(@"8.0"))
        self.blurEffectStyle = UIBlurEffectStyleExtraLight;
}

-(void)initViews
{
    self.overlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlay.alpha = 0;
    self.overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (self.enableOverlay)
        self.overlay.backgroundColor = [UIColor colorWithWhite:0. alpha:.4];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.overlay addGestureRecognizer:self.tapGesture];
    
    CGRect frame = [self frameHidden];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
    self.view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.view.frame = frame;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    self.tableView.separatorColor   = [UIColor clearColor];
    self.tableView.backgroundColor  = [UIColor blackColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //
    //  added button to close the menu
    //
    UIButton *btHide = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
    [btHide setTitle:@"" forState:UIControlStateNormal];
    btHide.accessibilityLabel = @"Close Menu";
    [btHide addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = btHide;
    [self.view.contentView addSubview:self.tableView];
}

#pragma mark - Appearance

-(void)show
{
    [self initViews];
    [ROOTVC.view.window addSubview:self.overlay];
    [ROOTVC.view.window addSubview:self.view];
    
    CGRect frame = [self frameShowed];
    
    [UIView animateWithDuration:0.275 animations:^
     {
         self.view.frame = frame;
         self.overlay.alpha = 0.6;
     }
                     completion:^(BOOL finished)
     {
         if (self.delegate && [self.delegate respondsToSelector:@selector(sideMenuDidShow:)])
             [self.delegate sideMenuDidShow:self];
     }];
}

-(void)showWithWidth:(CGFloat)width
{
    self.width = width;
    [self show];
}

-(void)hide
{
    [UIView animateWithDuration:0.475 animations:^
     {
         self.view.frame = [self frameHidden];
         self.overlay.alpha = 0.;
     }
                     completion:^(BOOL finished)
     {
         if (self.delegate && [self.delegate respondsToSelector:@selector(sideMenuDidHide:)])
             [self.delegate sideMenuDidHide:self];
         
         [self.view removeFromSuperview];
         [self.overlay removeFromSuperview];
         [self.overlay removeGestureRecognizer:self.tapGesture];
         
         self.overlay = nil;
         self.tableView = nil;
         self.view = nil;
     }];
}

-(BOOL)isVisible {
    return self.view != nil;
}
#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource numberOfSectionsInSideMenu:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource sideMenu:self numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UIImageView *imageViewIcon;
    UILabel *title;
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        
        UIView *bgColorView = [[UIView alloc] init];
        [bgColorView setBackgroundColor:self.selectionColor];
        [cell setSelectedBackgroundView:bgColorView];
    }
    
    VKSideMenuItem *item = [self.dataSource sideMenu:self itemForRowAtIndexPath:indexPath];
    
    CGFloat contentHeight = cell.frame.size.height * .8;
    CGFloat contentTopBottomPadding = cell.frame.size.height * .1;
    
    if (item.icon)
    {
        imageViewIcon = [cell.contentView viewWithTag:100];
        
        if (!imageViewIcon)
        {
            imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(15, contentTopBottomPadding+5, 25, 25)];
            imageViewIcon.tag = 100;
            imageViewIcon.contentMode=UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:imageViewIcon];
        }
        
        imageViewIcon.image = item.icon;
        
        if (self.iconsColor)
        {
            imageViewIcon.image = [imageViewIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            imageViewIcon.tintColor = item.iconColor ?: self.iconsColor;
        }
    }
    
    title = [cell.contentView viewWithTag:200];
    
    if (!title)
    {
        CGFloat titleX = item.icon ? CGRectGetMaxX(imageViewIcon.frame) + 15 : 55;
        title = [[UILabel alloc] initWithFrame:CGRectMake(titleX, contentTopBottomPadding, cell.frame.size.width - titleX - 12, contentHeight)];
        title.tag = 200;
        
        // Overrid for Ride - Tyson
        UIFont *font = [UIFont fontWithName:FontTypeRegular size:14.5];
        title.font = font;

        title.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:title];
    }
    
    title.text      = item.title;
    title.textColor = self.textColor;
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageViewIcon = [cell.contentView viewWithTag:100];
    
    if (imageViewIcon) {
        imageViewIcon.tintColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageViewIcon = [cell.contentView viewWithTag:100];
    
    if (imageViewIcon) {
        imageViewIcon.tintColor = self.iconsColor;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(sideMenu:didSelectRowAtIndexPath:)])
        [_delegate sideMenu:self didSelectRowAtIndexPath:indexPath];
    
    if (self.automaticallyDeselectRow)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.hideOnSelection)
        [self hide];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return indexPath.section == 0 ? 55. : 44.;
 
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sideMenu:headerViewForSection:)])
        
    self.headerView=[self.delegate sideMenu:self headerViewForSection:section];
    return self.headerView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    // Customized for Ride - Tyson
   return  76.5;

}

#pragma mark - UITapGestureRecognition

-(void)didTap:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
        [self hide];
}

#pragma mark - Helpers

-(CGRect)frameHidden
{
    CGFloat x = self.direction == VKSideMenuDirectionLeftToRight ? -self.width : [UIScreen mainScreen].bounds.size.width + self.width;
    return CGRectMake(x, 0, self.width, [UIScreen mainScreen].bounds.size.height);
}

-(CGRect)frameShowed
{
    CGFloat x = self.direction == VKSideMenuDirectionLeftToRight ? 0 : [UIScreen mainScreen].bounds.size.width - self.width;
    return CGRectMake(x, 0, self.width, self.view.frame.size.height);
}

@end
