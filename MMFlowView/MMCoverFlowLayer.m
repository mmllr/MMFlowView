//
//  MMCoverFlowLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 31.10.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMCoverFlowLayer.h"
#import "MMCoverFlowLayout.h"
#import "MMCoverFlowLayoutAttributes.h"
#import "CALayer+NSAccessibility.h"
#import "MMMacros.h"

static const CGFloat kDefaultWidth = 50.;
static const CGFloat kDefaultHeight = 50.;
static const CGFloat kDefaultEyeDistance = 1500.;
static const CFTimeInterval kDefaultScrollDuration = .4;
static const CGFloat kDefaultReflectionOffset = -.4;


static NSString * const kMMCoverFlowLayerIndexAttributeKey = @"mmCoverFlowLayerIndex";

static void* kLayoutObservationContext = @"layoutContext";
static void* kReloadContentObservationContext = @"reloadContent";

@interface MMCoverFlowLayer ()

@property (nonatomic, strong, readwrite) MMCoverFlowLayout *layout;
@property (nonatomic, readwrite) NSIndexSet *visibleItemIndexes;
@property (nonatomic, readonly) CGPoint selectedScrollPoint;
@property (nonatomic, strong) CAReplicatorLayer *replicatorLayer;

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
		_replicatorLayer = [[self class] createReplicatorLayer];
		[self addSublayer:_replicatorLayer];
        self.scrollMode = kCAScrollHorizontally;
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
		CGRect selectedBounds = selectedLayer.bounds;
		return CGRectMake(CGRectGetMidX(self.bounds) - CGRectGetMidX(selectedBounds), CGRectGetMidY(self.bounds) - CGRectGetMidY(selectedBounds), CGRectGetWidth(selectedBounds), CGRectGetHeight(selectedBounds));
	}
	return CGRectZero;
}

- (void)setEyeDistance:(CGFloat)eyeDistance
{
	_eyeDistance = eyeDistance;
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = 1. / - eyeDistance;
	self.sublayerTransform = transform;
}

- (CGPoint)selectedScrollPoint
{
	MMCoverFlowLayoutAttributes *attr = [self.layout layoutAttributesForItemAtIndex:self.layout.selectedItemIndex];
	return CGPointMake(attr.position.x - (CGRectGetWidth(self.bounds) / 2.) + self.layout.itemSize.width /2., 0);
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

- (NSUInteger)indexOfLayerAtPointInSuperLayer:(CGPoint)pointInLayer
{
	CALayer *hitLayer = [[self hitTest:pointInLayer] modelLayer];
	NSNumber *indexOfLayer = [hitLayer valueForKey:kMMCoverFlowLayerIndexAttributeKey];
	return indexOfLayer ? [indexOfLayer unsignedIntegerValue] :  NSNotFound;
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ( self.inLiveResize ) {
		// disable implicit animations for scrolllayer in live resize
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
	self.layout.contentHeight = CGRectGetHeight(self.bounds);
	//self.replicatorLayer.frame = CGRectMake(0, 0, self.layout.contentWidth, self.layout.contentHeight);
	self.replicatorLayer.instanceTransform = CATransform3DConcat( CATransform3DMakeScale(1, -1, 1), CATransform3DMakeTranslation(0, -self.layout.itemSize.height, 0));
	[CATransaction begin];
	[CATransaction setDisableActions:self.inLiveResize];
	[CATransaction setAnimationDuration:self.scrollDuration];
	[CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
	[self applyLayout];
	[ CATransaction setCompletionBlock:^{
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerDidRelayout:)] ) {
			[self.dataSource coverFlowLayerDidRelayout:self];
		}
	} ];
	[CATransaction commit];
}

#pragma mark - layout

- (void)applyLayout
{
	self.layout.contentHeight = CGRectGetHeight(self.bounds);
	[self.contentLayers enumerateObjectsUsingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		MMCoverFlowLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndex:idx];
		[self applyAttributes:attributes toContentLayer:contentLayer];
	}];
	[self scrollPoint:self.selectedScrollPoint];
	[self updateVisibleItems];
}

- (void)applyAttributes:(MMCoverFlowLayoutAttributes*)attributes toContentLayer:(CALayer*)contentLayer
{
	contentLayer.anchorPoint = attributes.anchorPoint;
	contentLayer.zPosition = attributes.zPosition;
	contentLayer.transform = attributes.transform;
	contentLayer.bounds = attributes.bounds;
	CGAffineTransform anchorTransform = CGAffineTransformMakeTranslation(attributes.anchorPoint.x*CGRectGetWidth(attributes.bounds), attributes.anchorPoint.y*CGRectGetHeight(attributes.bounds));
	contentLayer.position = CGPointApplyAffineTransform(attributes.position, anchorTransform);
	[contentLayer setValue:@(attributes.index) forKey:kMMCoverFlowLayerIndexAttributeKey];
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

- (void)updateVisibleItems
{
	__block NSUInteger firstVisibleItem = NSNotFound;
	__block NSUInteger numberOfVisibleItems = 0;

	[self.contentLayers enumerateObjectsUsingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		if ( !CGRectIsNull(contentLayer.visibleRect) ) {
			if ( firstVisibleItem == NSNotFound ) {
				firstVisibleItem = idx;
			}
			numberOfVisibleItems++;
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

@end
