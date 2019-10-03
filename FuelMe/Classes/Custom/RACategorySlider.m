//
//  RACategorySlider.m
//  CategorySliderPrototype
//
//  Created by Roberto Abreu on 9/9/16.
//  Copyright © 2016 homeappz. All rights reserved.
//

#import "DNA.h"
#import "RACategorySlider.h"
#import "RANode.h"
#import "NSNotificationCenterConstants.h"
#import <SDWebImage/SDWebImageManager.h>

#define kLineColor [UIColor colorWithRed:183.0/255 green:186.0/255 blue:190.0/255 alpha:1.0]
#define kTitleColor [UIColor colorWithRed:0/255 green:9.0/255 blue:35.0/255 alpha:0.7]
#define kBorderHandle [UIColor colorWithRed:0/255 green:122.0/255 blue:255.0/255 alpha:0.8]

const NSUInteger kMarginSide = 40;
const NSUInteger kElementsYOffset = 10;
NSString *kBorderAnimation = @"kBorderAnimation";

@interface RACategorySlider()

@property (nonatomic,strong) RACarCategoryDataModel *selectedCategory;

@property (nonatomic,strong) NSMutableArray<RANode*> *nodes;
@property (nonatomic,strong) NSDictionary<NSString*,RANode*> *nodesByName;

@property (nonatomic,strong) CALayer *handler;
@property (nonatomic,strong) CALayer *handlerInternalPriority;
/**
 *  @brief initialized on beginTrackingWithTouch, if self.handler moves far from touchPressedX, then its a drag else its a tap
 */
@property (nonatomic) CGFloat touchPressedX;
@property (nonatomic) BOOL touchPressed;
@property (nonatomic) BOOL handlerCarMoved;

@property (nonatomic,strong) CAShapeLayer *line;

- (void)moveToNode:(RANode*)node;

@end

@interface RACategorySlider(Accessibility)

@end

@implementation RACategorySlider
@synthesize  selectedCategory = _selectedCategory;

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHandlerImageCar) name:kNotificationDidDownloadSliderImage object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (RACarCategoryDataModel *)selectedCategory {
    if (!_selectedCategory) {
        if (self.nodes.count > 0) {
            _selectedCategory = self.nodes.firstObject.category;
        }
    }
    return _selectedCategory;
}

- (void)moveToCategory:(NSString *)category {
    RANode *node = self.nodesByName[category];
    if (node) {
        [self moveToNode:node];
    }
}

- (void)updateDrawing {
    
    [[self.layer.sublayers copy] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    if (!self.dataSource) {
        return;
    }
    
    self.nodes = [NSMutableArray array];
    
    //Base Line
    [self drawBaseLine];
    
    //Draw Nodes
    [self drawNodes];
    
    //Draw Handle
    [self drawHandle];
    
    //Set Default selected Category
    if ([self.nodes count] > 0) {
        BOOL hasValidSelection = self.selectedCategory && [self.dataSource indexForCategory:self.selectedCategory] != NSNotFound;
        if (hasValidSelection == NO) {
            self.selectedCategory = self.nodes.firstObject.category;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        
        [[SDWebImageManager sharedManager] loadImageWithURL:self.selectedCategory.sliderIconUrl options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                self.handler.contents = (__bridge id)image.CGImage;
            }
        }];
        
        self.handler.contentsScale = [UIScreen mainScreen].scale;
    }
}

- (void)reloadData {
    [self updateDrawing];
}

- (void)setDataSource:(id<RACategoryDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

#pragma mark - DRAW COMPONENTS

- (void)drawBaseLine {
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    CAShapeLayer *line = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(kMarginSide, self.bounds.size.height / 2 + kElementsYOffset)];
    [path addLineToPoint:CGPointMake(screenBounds.width - kMarginSide, self.bounds.size.height / 2 + kElementsYOffset)];
    line.path = path.CGPath;
    line.strokeColor = kLineColor.CGColor;
    line.borderWidth = 1.0;
    [self.layer addSublayer:line];
    
    self.line = line;
}

- (void)drawNodes {
    
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    
    NSUInteger numberOfCategories = [self.dataSource numberOfNodesInCategorySlider];
    CGFloat totalSize = screenBounds.width - (kMarginSide * 2);
    CGFloat marginBetweenNode = totalSize / (numberOfCategories - 1);
    CGFloat widthTitleLabel = (screenBounds.width - 10) / numberOfCategories;
    UIFont *font = [self bestFitFont];
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    //Nodes
    for (int i=0; i<numberOfCategories; i++) {
        RACarCategoryDataModel *currentCategory = [self.dataSource categoryAtIndex:i];
        RANode *node = [[RANode alloc] initWithCategory:currentCategory];
        
        //Position Node
        [node setBounds:CGRectMake(0, 0, 15, 15)];
        node.position = CGPointMake(kMarginSide + (marginBetweenNode * i), self.bounds.size.height / 2 + kElementsYOffset);
        
        [self.layer addSublayer:node];
        [self.nodes addObject:node];
        
        //Title
        CGFloat kTitleOffsetY = 25;
        CATextLayer *titleLayer = [CATextLayer layer];
        CGRect frame = [currentCategory.title boundingRectWithSize:CGSizeMake(widthTitleLabel, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        
        titleLayer.string = currentCategory.title.uppercaseString;
        titleLayer.font = (__bridge CFTypeRef _Nullable)font.fontName;
        titleLayer.fontSize = font.pointSize;
        titleLayer.backgroundColor = [UIColor clearColor].CGColor;
        titleLayer.borderWidth = 0.0;
        titleLayer.foregroundColor = kTitleColor.CGColor;
        [titleLayer setBounds:CGRectMake(0, 0, widthTitleLabel, frame.size.height)];
        [titleLayer setAlignmentMode:kCAAlignmentCenter];
        [titleLayer setWrapped:YES];
        titleLayer.position = CGPointMake(node.position.x, node.position.y - kTitleOffsetY);
        titleLayer.contentsScale = [UIScreen mainScreen].scale;
        
        node.titleLayer = titleLayer;
        [self.layer addSublayer:titleLayer];
        
        //Priority Layers
        CGFloat kPriorityOffset = 13.5;
        CALayer *priorityLayer = [CALayer layer];
        priorityLayer.bounds = CGRectMake(0, 0, 15, 15);
        priorityLayer.contents = (__bridge id)[UIImage imageNamed:@"Icon-p"].CGImage;
        priorityLayer.contentsScale = [UIScreen mainScreen].scale;
        priorityLayer.position = CGPointMake(titleLayer.bounds.size.width / 2, (titleLayer.bounds.size.height / 2) - kPriorityOffset);
        priorityLayer.opacity = 0;
        
        node.priorityLayer = priorityLayer;
        [titleLayer addSublayer:priorityLayer];
        
        md[currentCategory.title] = node;
    }
    
    self.nodesByName = [NSDictionary dictionaryWithDictionary:md];
    
    //Animate nodes
    for (int i = 0; i < self.nodes.count; i++) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 + kElementsYOffset)];
        animation.toValue = [NSValue valueWithCGPoint:self.nodes[i].position];
        
        [self.nodes[i] addAnimation:animation forKey:@"nodeAnimation"];
    }
}

- (void)drawHandle {
    CGFloat handleDiameter = 45;
    
    CALayer *handle = [CALayer layer];
    [handle setBounds:CGRectMake(0, 0, handleDiameter, handleDiameter)];
    [handle setPosition:self.handlePosition];
    [handle setCornerRadius:handleDiameter/2.0];
    [handle setBackgroundColor:[UIColor clearColor].CGColor];
    [handle setContentsScale:[UIScreen mainScreen].scale];
    [handle setShadowOffset:CGSizeMake(0, 0)];
    [handle setShadowRadius:3];
    [handle setShadowOpacity:0.5];
    [self.layer addSublayer:handle];
    self.handler = handle;
    
    CALayer *handleInternalPriority = [CALayer layer];
    [handleInternalPriority setBorderColor:kBorderHandle.CGColor];
    [handleInternalPriority setBounds:handle.bounds];
    [handleInternalPriority setAnchorPoint:CGPointZero];
    [handleInternalPriority setCornerRadius:handle.cornerRadius];
    [self.handler addSublayer:handleInternalPriority];
    self.handlerInternalPriority = handleInternalPriority;

    [self updateTitleLabelPosition];
}

- (CGPoint)handlePosition {
    if (self.handler != nil) {
        NSInteger index = [self.dataSource indexForCategory:self.selectedCategory];
        BOOL hasValidSelection = index != NSNotFound && self.nodes.count > index;
        if (hasValidSelection) {
            return self.nodes[index].position;
        }
    }
    return CGPointMake(kMarginSide, self.bounds.size.height / 2 + kElementsYOffset);
}

- (void)addBorderAnimationToHandler {
    CAKeyframeAnimation *borderAnimation = [CAKeyframeAnimation animationWithKeyPath:@"borderWidth"];
    [borderAnimation setAutoreverses:YES];
    [borderAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    borderAnimation.duration = 1.0;
    borderAnimation.repeatCount = INFINITY;
    [borderAnimation setValues:@[[NSNumber numberWithInt:1.0],[NSNumber numberWithInt:0.0]]];
    [self.handlerInternalPriority addAnimation:borderAnimation forKey:kBorderAnimation];
}

#pragma mark - HANDLE HANDLER

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    CGPoint touchLocation = [touch locationInView:self];

    _handlerCarMoved = NO;
    
    if ([self.handler hitTest:touchLocation]) {
        _touchPressed = YES;
        _touchPressedX = self.handler.position.x;
        [self.handlerInternalPriority removeAnimationForKey:@"borderAnimation"];
        return YES;
    }
    
    for (RANode *node in self.nodes) {
        if (CGRectContainsPoint([node frameWithOffset], touchLocation) || [node.titleLayer hitTest:touchLocation]) {
            self.handler.position = node.position;
            [self endTrackingWithTouch:touch withEvent:event];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint touchLocation = [touch locationInView:self];
    
    if ([self.handler hitTest:touchLocation]) {
        if (self.handlerCarMovedBeyondTolerance) {
            _handlerCarMoved = YES;
        }
        
        self.handler.opacity = 0.7;
        [self updateTitleLabelPosition];
        [self updateHandlerImageCar];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.handler.position = CGPointMake([self normalizeX:touchLocation.x], self.handler.position.y);
        [CATransaction commit];
        return YES;
    }
    
    [self endTrackingWithTouch:touch withEvent:event];
    return NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    //set selected category
    RANode *selectedNode = [self moveHandlerToNearNode];
    self.selectedCategory = selectedNode.category;
    
    //Restore appearance Handler
    self.handler.opacity = 1.0;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    if (!_handlerCarMoved && _touchPressed) {
        if (self.dataSource) {
            [self.dataSource didTapCategoryHandler];
        }
    }
    
    _handlerCarMoved = NO;
    _touchPressed = NO;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    [self endTrackingWithTouch:nil withEvent:event];
}

- (BOOL)handlerCarMovedBeyondTolerance {
    CGFloat tolerance = 20;
    return fabs(_touchPressedX - self.handler.position.x) > tolerance;
}

#pragma mark - HELPER METHODS

- (CGFloat)normalizeX:(CGFloat)xPosition {
    return MAX(MIN(self.bounds.size.width - kMarginSide, xPosition),kMarginSide);
}

- (CGFloat)distanceBetweenHandlerAndNode:(RANode*)node {
    CGPoint nodePos = node.position;
    CGPoint handlerPos = self.handler.position;
    return sqrtf(powf(nodePos.x - handlerPos.x, 2));
}

- (RANode*)nearNode {
    CGFloat minDistance = 9999999;
    RANode *minNode = nil;
    for (RANode *node in self.nodes) {
        CGFloat distance = [self distanceBetweenHandlerAndNode:node];
        if (distance <= minDistance) {
            minDistance = distance;
            minNode = node;
        }
    }
    return minNode;
}

- (RANode*)moveHandlerToNearNode {
    RANode *minNode = [self nearNode];

    [self moveToNode:minNode];
    
    return minNode;
}

- (void)moveToNode:(RANode *)node {
    if (node) {
        [self.handler setPosition:node.position];
    }
    
    [self updateTitleLabelPosition];
    [self updateHandlerImageCar];
    
    if ([node.category hasPriority]) {
        [self addBorderAnimationToHandler];
    }else{
        [self.handlerInternalPriority removeAnimationForKey:kBorderAnimation];
    }
    
    self.selectedCategory = node.category;
}

- (void)updateHandlerImageCar {
    RANode *minNode = [self nearNode];
    if (minNode && minNode.category) {
        [[SDWebImageManager sharedManager] loadImageWithURL:minNode.category.sliderIconUrl options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            if (image) {
                self.handler.contents = (__bridge id)image.CGImage;
            }
        }];
    }
}

- (void)updateTitleLabelPosition {
    RANode *minNode = [self nearNode];
    if (minNode) {
        if (minNode.titleLayer) {
            minNode.titleLayer.position = CGPointMake(minNode.position.x, minNode.position.y - 36);
        }
    }
    
    for (RANode *node in self.nodes) {
        if (![node isEqual:minNode]) {
            node.titleLayer.position = CGPointMake(node.position.x, node.position.y - 25);
        }
    }
}

- (void)reloadSurgeAreas:(NSArray<RASurgeAreaDataModel *> *)surgeAreas {
    for (RANode *node in self.nodes) {
        [node.category processSurgeAreas:surgeAreas];
        node.priorityLayer.opacity = node.category.hasPriority ? 1.0 : 0.0;
    }
    
    if ([self.selectedCategory hasPriority]) {
        [self addBorderAnimationToHandler];
    }else{
        [self.handlerInternalPriority removeAnimationForKey:kBorderAnimation];
    }
}

- (void)clearAllSurgeAreas {
    for (RANode *node in self.nodes) {
        [node.category clearSurgeAreas];
        node.priorityLayer.opacity = 0.0;
        [self updateSelectedCategoryWithNode:node];
    }
    
    [self.handlerInternalPriority removeAnimationForKey:kBorderAnimation];
}

- (void)clearSurgeAreas:(NSArray<RASurgeAreaDataModel *> *)surgeAreas {
    for (RANode *node in self.nodes) {
        [node.category clearSurgeAreas];
        node.priorityLayer.opacity = 0.0;
        [self updateSelectedCategoryWithNode:node];
    }
    
    if ([self.selectedCategory hasPriority]) {
        [self addBorderAnimationToHandler];
    }else{
        [self.handlerInternalPriority removeAnimationForKey:kBorderAnimation];
    }
}

- (BOOL)isTouchableArea:(CGPoint)location {
    BOOL touchableArea = YES;
    
    for (RANode *node in self.nodes) {
        if ([node hitTest:location] || [node.titleLayer hitTest:location]) {
            touchableArea = NO;
            break;
        }
    }
    
    if (touchableArea && [self.handler hitTest:location]) {
        touchableArea = NO;
    }
    
    return touchableArea;
}

- (UIFont*)bestFitFont {
    NSUInteger numberOfCategories = [self.dataSource numberOfNodesInCategorySlider];
    CGFloat widthTitleLabel = (self.bounds.size.width - 10) / numberOfCategories;
    
    //Find max lenght text
    NSString *largeTitle = @"";
    for (int i=0; i<numberOfCategories; i++) {
        RACarCategoryDataModel *currentCategory = [self.dataSource categoryAtIndex:i];
        if (currentCategory.title.length > largeTitle.length) {
            largeTitle = currentCategory.title;
        }
    }
    
    const int kMaxFontSize = 10;
    const int kMinFontSize = 8;
    int currentFontSize = kMaxFontSize;
    UIFont *font = [self titleCategoryFontWithSize:currentFontSize];
    CGSize sizeWithFont = [largeTitle.uppercaseString sizeWithAttributes:@{NSFontAttributeName:font}];
    while (sizeWithFont.width > widthTitleLabel) {
        currentFontSize -= 0.1;
        font = [self titleCategoryFontWithSize:currentFontSize];
        sizeWithFont = [largeTitle sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    
    currentFontSize = MAX(kMinFontSize, MIN(currentFontSize,kMaxFontSize));
    return [self titleCategoryFontWithSize:currentFontSize];
}

- (UIFont*)titleCategoryFontWithSize:(int)fontSize {
    return [UIFont fontWithName:FontTypeRegular size:fontSize];
}

- (void)updateSelectedCategoryWithNode:(RANode *)node {
    if ([self.selectedCategory.title isEqualToString:node.category.title]) {
        self.selectedCategory = node.category;
    }
}

@end

#pragma mark - Accessibility

@implementation RACategorySlider (Accessibility)

- (BOOL)isAccessibilityElement {
    return NO;
}

- (NSInteger)accessibilityElementCount {
    if (self.dataSource) {
        return [self.dataSource numberOfNodesInCategorySlider];
    }
    
    return 0;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    RANode *node = [self.nodes objectAtIndex:index];
    UIAccessibilityElement *element = node.accessibilityElement;
    if (element == nil) {
        element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        element.accessibilityTraits = UIAccessibilityTraitButton;
        element.accessibilityLabel = node.category.title;
        node.accessibilityElement = element;
    }
    
    if (index == [self.dataSource indexForCategory:self.selectedCategory]) {
        element.accessibilityHint = @"swipe right or left to pick a different request, swipe up twice to set pickup location";
#ifdef AUTOMATION
        element.accessibilityLabel = [NSString stringWithFormat:@"{\"title\":\"%@\",\"selected\":\"%@\"}", node.category.title, @"true"];
#endif
    } else {
        element.accessibilityHint = @"double tap to select";
#ifdef AUTOMATION
        element.accessibilityLabel = [NSString stringWithFormat:@"{\"title\":\"%@\",\"selected\":\"%@\"}", node.category.title, @"false"];
#endif
    }
    
    element.accessibilityFrame = [self convertRect:node.frameWithOffset toView:[UIApplication sharedApplication].keyWindow];
    return element;
}

@end
