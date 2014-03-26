/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://github.com/mmllr All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this
 software and associated documentation files (the "Software"), to deal in the Software
 without restriction, including without limitation the rights to use, copy, modify, merge,
 publish, distribute, sublicense, and/or sell copies of the Software, and to permit
 persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies
 or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
 FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
 
 */
//
//  MMCoverFlowLayer.m
//
//  Created by Markus Müller on 31.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "CALayer+NSAccessibility.h"
#import "MMMacros.h"

static const CGFloat kDefaultEyeDistance = 1500.;
static const CFTimeInterval kDefaultScrollDuration = .4;
static const CGFloat kDefaultReflectionOffset = -.4;

static void* kLayoutObservationContext = @"layoutContext";
static void* kReloadContentObservationContext = @"reloadContent";

@interface MMCoverFlowLayer ()

@property (nonatomic, strong, readwrite) MMCoverFlowLayout *layout;
@property (nonatomic, readwrite) NSIndexSet *visibleItemIndexes;
@property (nonatomic, readonly) CGPoint selectedScrollPoint;
@property (nonatomic, strong) CAReplicatorLayer *replicatorLayer;
@property (nonatomic, strong) CATransformLayer *transformLayer;

@end

@implementation MMCoverFlowLayer

@dynamic numberOfItems;
@dynamic selectedScrollPoint;
@dynamic contentLayers;
@dynamic showsReflection;
@dynamic reflectionOffset;

#pragma mark - class methods

+ (instancetype)layerWithLayout:(MMCoverFlowLayout*)layout
{
	return [[self alloc] initWithLayout:layout];
}

+ (NSSet*)layoutObservationKeyPaths
{
	return [NSSet setWithObjects:@"stackedAngle", @"interItemSpacing", @"selectedItemIndex", @"stackedDistance", @"verticalMargin", nil];
}

+ (NSSet*)reloadContentObservationKeyPaths
{
	return [NSSet setWithObjects:@"numberOfItems", nil];
}

+ (CAReplicatorLayer*)createReplicatorLayer
{
	CAReplicatorLayer *layer = [CAReplicatorLayer layer];
	layer.preservesDepth = YES;
	layer.instanceBlueOffset = layer.instanceGreenOffset = layer.instanceRedOffset = kDefaultReflectionOffset;
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	return layer;
}

+ (CATransformLayer*)createTransformLayer
{
	CATransformLayer *layer = [CATransformLayer layer];
	layer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
	return layer;
}

#pragma mark - init/cleanup

- (id)init
{
	return [self initWithLayout:nil];
}

- (id)initWithLayout:(MMCoverFlowLayout*)layout
{
	NSParameterAssert(layout);

    self = [super init];
    if (self) {
		_layout = layout;
		_inLiveResize = NO;
		_visibleItemIndexes = [NSIndexSet indexSet];
		_scrollDuration = kDefaultScrollDuration;
		_transformLayer = [[self class] createTransformLayer];
		_replicatorLayer = [[self class] createReplicatorLayer];
		[_transformLayer addSublayer:_replicatorLayer];
		[self addSublayer:_transformLayer];
		self.masksToBounds = NO;
		self.eyeDistance = kDefaultEyeDistance;
		self.delegate = self;
		self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		[self setupObservations];
		[self setupAccessibility];
    }
    return self;
}

- (void)dealloc
{
    [self tearDownObservations];
}

#pragma mark - accessors

- (NSUInteger)numberOfItems
{
	return self.layout.numberOfItems;
}

- (CGRect)selectedItemFrame
{
	if ( self.layout.selectedItemIndex != NSNotFound ) {
		CALayer *selectedLayer = self.contentLayers[self.layout.selectedItemIndex];
		return [self convertRect:selectedLayer.bounds fromLayer:selectedLayer];
	}
	return CGRectZero;
}

- (void)setEyeDistance:(CGFloat)eyeDistance
{
	_eyeDistance = eyeDistance;
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = 1. / - eyeDistance;
	self.transformLayer.sublayerTransform = transform;
}

- (NSArray*)contentLayers
{
	return self.replicatorLayer.sublayers;
}

- (BOOL)showsReflection
{
	return (self.replicatorLayer.instanceCount == 2);
}

- (void)setShowsReflection:(BOOL)showsReflection
{
	self.replicatorLayer.instanceCount = showsReflection ? 2 : 1;
}

- (CGFloat)reflectionOffset
{
	return self.replicatorLayer.instanceBlueOffset;
}

- (void)setReflectionOffset:(CGFloat)reflectionOffset
{
	CGFloat validOffset = CLAMP(reflectionOffset, -1, 0);

	self.replicatorLayer.instanceBlueOffset = validOffset;
	self.replicatorLayer.instanceGreenOffset = validOffset;
	self.replicatorLayer.instanceRedOffset = validOffset;
}

- (void)setInLiveResize:(BOOL)inLiveResize
{
	_inLiveResize = inLiveResize;
	if (inLiveResize == NO) {
		[self setNeedsLayout];
	}
}


#pragma mark - class logic

- (void)reloadContent
{
	self.replicatorLayer.sublayers = nil;

	for ( NSInteger i = 0; i < self.layout.numberOfItems; ++i ) {
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayer:contentLayerForIndex:)] ) {
			CALayer *contentLayer = [self.dataSource coverFlowLayer:self contentLayerForIndex:i];
			[self.replicatorLayer addSublayer:contentLayer];
		}
	}
	[self layoutSublayers];
}

- (NSUInteger)indexOfLayerAtPoint:(CGPoint)pointInLayer
{
	CGPoint pointInSuperLayer =[self convertPoint:pointInLayer
										  toLayer:self.superlayer];
	CALayer *hitLayer = [[self hitTest:pointInSuperLayer ] modelLayer];
	NSNumber *indexOfLayer = [hitLayer valueForKey:kMMCoverFlowLayoutAttributesIndexAttributeKey];
	return indexOfLayer ? [indexOfLayer unsignedIntegerValue] :  NSNotFound;
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ( self.inLiveResize ) {
		return (id<CAAction>)[NSNull null];
	}
	return nil;
}

#pragma mark - CALayer overrides

- (void)layoutSublayers
{
	if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerWillRelayout:)] ) {
		[self.dataSource coverFlowLayerWillRelayout:self];
	}
	self.layout.visibleSize = self.bounds.size;
	self.replicatorLayer.instanceTransform = CATransform3DConcat( CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, -self.layout.itemSize.height, 0));
	[CATransaction begin];
	[CATransaction setDisableActions:self.inLiveResize];
	[CATransaction setAnimationDuration:self.scrollDuration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[self applyLayout];
	[CATransaction setCompletionBlock:^{
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerDidRelayout:)] ) {
			[self.dataSource coverFlowLayerDidRelayout:self];
		}
	} ];
	[CATransaction commit];
}

#pragma mark - layout

- (void)applyLayout
{
	self.layout.visibleSize = self.bounds.size;
	[self.contentLayers enumerateObjectsUsingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		MMCoverFlowLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndex:idx];
		[attributes applyToLayer:contentLayer];
	}];
	[self updateVisibleItems];
}

- (void)updateVisibleItems
{
	__block NSUInteger firstVisibleItem = NSNotFound;
	__block NSUInteger numberOfVisibleItems = 0;

	[self.contentLayers enumerateObjectsUsingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		if (CGRectIntersectsRect(self.bounds, contentLayer.frame)) {
			if ( firstVisibleItem == NSNotFound ) {
				firstVisibleItem = idx;
			}
			numberOfVisibleItems++;
			[self.dataSource coverFlowLayer:self willShowLayer:contentLayer atIndex:idx];
		}
		if ( idx > (firstVisibleItem + numberOfVisibleItems) ) {
			*stop = YES;
		}
	}];
	self.visibleItemIndexes = ( firstVisibleItem != NSNotFound ) ? [NSIndexSet indexSetWithIndexesInRange:NSMakeRange( firstVisibleItem, numberOfVisibleItems )] : [NSIndexSet indexSet];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kLayoutObservationContext) {
        [self setNeedsLayout];
    }
	else if (context == kReloadContentObservationContext) {
		[self reloadContent];
	}
	else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setupObservations
{
	for ( NSString *keyPath in [[self class] layoutObservationKeyPaths] ) {
		[self.layout addObserver:self
					  forKeyPath:keyPath
						 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
						 context:kLayoutObservationContext];
	}
	for (NSString *keyPath in [[self class] reloadContentObservationKeyPaths] ) {
		[self.layout addObserver:self
					  forKeyPath:keyPath
						 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
						 context:kReloadContentObservationContext];
	}
}

- (void)tearDownObservations
{
	for ( NSString *keyPath in [[self class] layoutObservationKeyPaths] ) {
		[self.layout removeObserver:self
						 forKeyPath:keyPath
							context:kLayoutObservationContext];
	}
	for (NSString *keyPath in [[self class] reloadContentObservationKeyPaths] ) {
		[self.layout removeObserver:self
						 forKeyPath:keyPath
							context:kReloadContentObservationContext];
	}
}

#pragma mark - accessibility

- (void)setupAccessibility
{
	__weak typeof(self) weakSelf = self;
	
	[self setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:^id{
		return NSAccessibilityListRole;
	}];
	[self setReadableAccessibilityAttribute:NSAccessibilitySubroleAttribute withBlock:^id{
		return NSAccessibilityContentListSubrole;
	}];
	[self setReadableAccessibilityAttribute:NSAccessibilityOrientationAttribute withBlock:^id{
		return NSAccessibilityHorizontalOrientationValue;
	}];
	[self setReadableAccessibilityAttribute:NSAccessibilityVisibleChildrenAttribute withBlock:^id{
		MMCoverFlowLayer *strongSelf = weakSelf;
		
		NSArray *children = NSAccessibilityUnignoredChildren(strongSelf.contentLayers);
		return children ? [children objectsAtIndexes:strongSelf.visibleItemIndexes] : @[];
	}];
	[self setWritableAccessibilityAttribute:NSAccessibilitySelectedChildrenAttribute
								  readBlock:^id{
									  MMCoverFlowLayer *strongSelf = weakSelf;
									  NSArray *children = NSAccessibilityUnignoredChildren(strongSelf.contentLayers);
									  return children ? [children subarrayWithRange:NSMakeRange(strongSelf.layout.selectedItemIndex, 1)] : @[];
								  }
								 writeBlock:^(id value) {
									 MMCoverFlowLayer *strongSelf = weakSelf;
									 
									 if ( [value isKindOfClass:[NSArray class]] && [value count] ) {
										 CALayer *layer = [value firstObject];
										 if ( [layer isKindOfClass:[CALayer class]] ) {
											 NSUInteger index = [strongSelf.contentLayers indexOfObject:layer];
											 strongSelf.layout.selectedItemIndex = index;
										 }
									 }
								 }];
}


@end
