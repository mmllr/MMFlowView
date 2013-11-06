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

static const CGFloat kDefaultWidth = 50.;
static const CGFloat kDefaultHeight = 50.;
static const CGFloat kDefaultEyeDistance = 1500.;

@interface MMCoverFlowLayer ()

@property (strong) MMCoverFlowLayout *layout;
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
    }
    return self;
}

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
	[self layoutSublayers];
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
	NSUInteger numberOfItems = 0;
	if ( [self.dataSource respondsToSelector:@selector(numberOfItemsInCoverFlowLayer:)] ) {
		numberOfItems = [self.dataSource numberOfItemsInCoverFlowLayer:self];
	}
	for ( NSInteger i = 0; i < numberOfItems; ++i ) {
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayer:contentLayerForIndex:)] ) {
			CALayer *contentLayer = [self.dataSource coverFlowLayer:self contentLayerForIndex:i];
			[self addSublayer:contentLayer];
		}
	}
	self.layout.numberOfItems = numberOfItems;
	//[self applyLayout];
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

#pragma mark - CALayoutManager

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
	if ( layer == self ) {
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerWillRelayout:)] ) {
			[self.dataSource coverFlowLayerWillRelayout:self];
		}
		[self applyLayout];
		if ( [self.dataSource respondsToSelector:@selector(coverFlowLayerDidRelayout:)] ) {
			[self.dataSource coverFlowLayerDidRelayout:self];
		}
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
}

- (void)applyAttributes:(MMCoverFlowLayoutAttributes*)attributes toContentLayer:(CALayer*)contentLayer
{
	contentLayer.anchorPoint = attributes.anchorPoint;
	contentLayer.transform = attributes.transform;
	contentLayer.position = attributes.position;
	contentLayer.bounds = attributes.bounds;
	contentLayer.zPosition = attributes.zPosition;
}

@end
