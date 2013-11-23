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

static const CGFloat kDefaultWidth = 50.;
static const CGFloat kDefaultHeight = 50.;
static const CGFloat kDefaultEyeDistance = 1500.;

static void* kLayoutObservationContext = @"layoutContext";
static void* kReloadContentObservationContext = @"reloadContent";

@interface MMCoverFlowLayer ()

@property (nonatomic, strong, readwrite) MMCoverFlowLayout *layout;
@property (nonatomic, readwrite) NSIndexSet *visibleItemIndexes;
@property (nonatomic, readonly) CGPoint selectedScrollPoint;

@end

@implementation MMCoverFlowLayer

@dynamic numberOfItems;
@dynamic selectedItemIndex;
@dynamic selectedScrollPoint;

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

#pragma mark - init/cleanup

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithLayout: instead"];
	return nil;
}

- (id)initWithLayout:(MMCoverFlowLayout*)layout
{
    self = [super init];
    if (self) {
		self.frame = CGRectMake(0, 0, kDefaultWidth, kDefaultHeight);
		self.layout = layout;
        self.scrollMode = kCAScrollHorizontally;
		self.masksToBounds = NO;
		self.inLiveResize = NO;
		self.eyeDistance = kDefaultEyeDistance;
		self.delegate = self;
		self.layoutManager = self;
		self.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
		_visibleItemIndexes = [NSIndexSet indexSet];
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

- (NSUInteger)selectedItemIndex
{
	return self.layout.selectedItemIndex;
}

- (void)setSelectedItemIndex:(NSUInteger)selectedItemIndex
{
	self.layout.selectedItemIndex = selectedItemIndex;
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
	CGPoint point = CGPointMake( attr.position.x - (CGRectGetWidth(self.bounds) / 2.) + self.layout.itemSize.width / 2, 0 );
	return point;
}

#pragma mark - class logic

- (void)reloadContent
{
	self.sublayers = nil;
	for ( NSInteger i = 0; i < self.layout.numberOfItems; ++i ) {
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayer:contentLayerForIndex:)] ) {
			CALayer *contentLayer = [self.dataSource coverFlowLayer:self contentLayerForIndex:i];
			[self addSublayer:contentLayer];
		}
	}
	[self layoutSublayers];
}

#pragma mark - CALayerDelegate

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
	if ( layer == self && self.inLiveResize ) {
		// disable implicit animations for scrolllayer in live resize
		return (id<CAAction>)[ NSNull null ];
	}
	return nil;
}

#pragma mark - CALayer overrides

- (void)layoutSublayers
{
	if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerWillRelayout:)] ) {
		[self.dataSource coverFlowLayerWillRelayout:self];
	}
	[self applyLayout];
	if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerDidRelayout:)] ) {
		[self.dataSource coverFlowLayerDidRelayout:self];
	}
}

- (void)applyLayout
{
	self.layout.contentHeight = CGRectGetHeight(self.bounds);
	[self.sublayers enumerateObjectsUsingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		MMCoverFlowLayoutAttributes *attributes = [self.layout layoutAttributesForItemAtIndex:idx];
		[self applyAttributes:attributes toContentLayer:contentLayer];
	}];
	[self scrollToPoint:self.selectedScrollPoint];
	[self updateVisibleItems];
}

- (void)applyAttributes:(MMCoverFlowLayoutAttributes*)attributes toContentLayer:(CALayer*)contentLayer
{
	contentLayer.anchorPoint = attributes.anchorPoint;
	contentLayer.transform = attributes.transform;
	contentLayer.position = attributes.position;
	contentLayer.bounds = attributes.bounds;
	contentLayer.zPosition = attributes.zPosition;
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

		NSArray *children = NSAccessibilityUnignoredChildren(strongSelf.sublayers);
		return children ? [children objectsAtIndexes:strongSelf.visibleItemIndexes] : [NSArray array];
	}];
	[self setWritableAccessibilityAttribute:NSAccessibilitySelectedChildrenAttribute
								   readBlock:^id{
									   MMCoverFlowLayer *strongSelf = weakSelf;
									   NSArray *children = NSAccessibilityUnignoredChildren(strongSelf.sublayers);
									   return children ? [children subarrayWithRange:NSMakeRange(strongSelf.selectedItemIndex, 1)] : [NSArray array];
								   }
								  writeBlock:^(id value) {
									  MMCoverFlowLayer *strongSelf = weakSelf;

									  if ( [value isKindOfClass:[NSArray class]] && [value count] ) {
										  CALayer *layer = [value firstItem];
										  if ( [layer isKindOfClass:[CALayer class]] ) {
											  NSUInteger index = [strongSelf.sublayers indexOfObject:layer];
											  strongSelf.selectedItemIndex = index;
										  }
									  }
								  }];
}

- (void)updateVisibleItems
{
	__block NSUInteger firstVisibleItem = NSNotFound;
	__block NSUInteger numberOfVisibleItems = 0;

	[ self.sublayers enumerateObjectsUsingBlock:^(CALayer *contentLayer, NSUInteger idx, BOOL *stop) {
		if ( !CGRectIsEmpty( contentLayer.visibleRect ) ) {
			if ( firstVisibleItem == NSNotFound ) {
				firstVisibleItem = idx;
			}
			numberOfVisibleItems++;
		}
		if ( firstVisibleItem + numberOfVisibleItems < idx ) {
			*stop = YES;
		}
	}];
	self.visibleItemIndexes = ( firstVisibleItem != NSNotFound ) ? [ NSIndexSet indexSetWithIndexesInRange:NSMakeRange( firstVisibleItem, numberOfVisibleItems ) ] : [ NSIndexSet indexSet ];
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
