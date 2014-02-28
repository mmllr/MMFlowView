//
//  MMScrollBarLayer.m
//  MMFlowViewDemo
//
//  Created by Markus Müller on 14.11.13.
//  Copyright (c) 2013 www.isnotnil.com. All rights reserved.
//

#import "MMScrollBarLayer.h"
#import "CALayer+NSAccessibility.h"
#import "MMScrollKnobLayer.h"
#import "CALayer+MMAdditions.h"
#import "NSArray+MMAdditions.h"

static void* kRelayoutObservationContext = @"MMRelayoutObservationContext";

static NSString * const kLayerName = @"MMScrollBarLayerName";
static const CGFloat kBorderWidth = 1.;
static const CGFloat kCornerRadius = 10.;
static const CGFloat kHeight = 20.;
static const CGFloat kYOffset = 10.;
static const CGFloat kWidthScale = .75;
static const CGFloat kKnobMargin = 5.;
static const CGFloat kMinimumKnobWidth = 40.;

@interface MMScrollBarLayer ()

@property (strong) NSArray *observedSublayers;

@end

@implementation MMScrollBarLayer

#pragma mark - class methods

+ (NSSet*)scrollLayerRelayoutObservationKeys
{
	static NSSet *keys = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keys = [NSSet setWithObjects:@"bounds", @"sublayers", nil];
	});
	return keys;
}

+ (NSArray*)contentLayerObservationKeys
{
	static NSArray *keys = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keys = @[@"bounds", @"position"];
	});
	return keys;
}

#pragma mark - init/cleanup

- (id)init
{
	[ NSException raise:NSInternalInconsistencyException format:@"init not allowed, use designated initalizer initWithScrollLayer: instead"];
	return nil;
}

- (id)initWithScrollLayer:(CAScrollLayer*)scrollLayer
{
    self = [super init];
    if (self) {
		_scrollLayer = scrollLayer;
        self.name = kLayerName;
		self.backgroundColor = [ [ NSColor blackColor ] CGColor ];
		self.borderColor = [ [ NSColor grayColor ] CGColor ];
		self.opaque = YES;
		self.borderWidth = kBorderWidth;
		self.cornerRadius = kCornerRadius;
		self.frame = CGRectMake(0, 0, 100., kHeight);
		[self setupConstraints];
		[self disableImplicitPositionAndBoundsAnimations];
		[self setupAccessibility];
		[self setupSublayers];
		[self setupObservations];
    }
    return self;
}

- (void)dealloc
{
    [self tearDownObservations];
}

- (void)setupConstraints
{
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
												   relativeTo:@"superlayer"
													attribute:kCAConstraintMidX]];
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY
												   relativeTo:@"superlayer"
													attribute:kCAConstraintMinY
													   offset:kYOffset]];
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
												   relativeTo:@"superlayer"
													attribute:kCAConstraintWidth
														scale:kWidthScale
													   offset:0 ] ];
}

- (void)setupSublayers
{
	self.sublayers = nil;
	MMScrollKnobLayer *knobLayer = [MMScrollKnobLayer layer];
	[self addSublayer:knobLayer];
	[self layoutSublayers];
}

- (void)setupAccessibility
{
	[self setReadableAccessibilityAttribute:NSAccessibilityRoleAttribute withBlock:^id{
		return NSAccessibilityScrollBarRole;
	}];
	[self setReadableAccessibilityAttribute:NSAccessibilityOrientationAttribute withBlock:^id{
		return NSAccessibilityHorizontalOrientationValue;
	}];
}

- (void)setupObservations
{
	for ( NSString *key in [[self class] scrollLayerRelayoutObservationKeys] ) {
		[self.scrollLayer addObserver:self
						   forKeyPath:key
							  options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
							  context:kRelayoutObservationContext];
	}
}

- (void)tearDownObservations
{
	for ( NSString *key in [[self class] scrollLayerRelayoutObservationKeys] ) {
		[self.scrollLayer removeObserver:self
							  forKeyPath:key
								 context:kRelayoutObservationContext];
	}
	[self.observedSublayers mm_removeObserver:self
								  forKeyPaths:[[self class] contentLayerObservationKeys]
									  context:kRelayoutObservationContext];
}

#pragma mark - dragging

- (void)beginDragAtPoint:(CGPoint)pointInLayerCoordinates
{
	if (!CGRectContainsPoint(self.frame, pointInLayerCoordinates)) {
		self.dragOrigin = CGPointZero;
		return;
	}
	self.dragOrigin = pointInLayerCoordinates;
}

- (void)mouseDraggedToPoint:(CGPoint)pointInLayerCoordinates
{
}

- (void)endDrag
{
	self.dragOrigin = CGPointZero;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)observedObject change:(NSDictionary *)change context:(void *)context
{
    if (context == kRelayoutObservationContext) {
		if ([keyPath isEqualToString:@"sublayers"]) {
			// Have items been removed from the bound-to container?
			/*
			 Should be able to use
			 NSArray *oldItems = [change objectForKey:NSKeyValueChangeOldKey];
			 etc. but the dictionary doesn't contain old and new arrays.
			 */

			NSArray *newLayers = [observedObject valueForKeyPath:keyPath];
			NSMutableArray *onlyNew = [NSMutableArray arrayWithArray:newLayers];
			[onlyNew removeObjectsInArray:self.observedSublayers];
			[onlyNew mm_addObserver:self
						forKeyPaths:[[self class] contentLayerObservationKeys]
							context:kRelayoutObservationContext];
			NSMutableArray *removed = [self.observedSublayers mutableCopy];
			[removed removeObjectsInArray:newLayers];
			[removed mm_removeObserver:self
						   forKeyPaths:[[self class] contentLayerObservationKeys]
							   context:kRelayoutObservationContext];
			self.observedSublayers = newLayers;
		}
        [self layoutSublayers];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:observedObject change:change context:context];
    }
}

#pragma mark - CALayer overrides

- (CGSize)scrollAreaSize
{
	__block CGRect scrollArea = CGRectZero;
	
	[self.scrollLayer.sublayers enumerateObjectsUsingBlock:^(CALayer *layer, NSUInteger idx, BOOL *stop) {
		if (CGRectEqualToRect(scrollArea, CGRectZero)) {
			scrollArea = layer.frame;
		}
		scrollArea = CGRectUnion(scrollArea, layer.frame);
	}];
	return scrollArea.size;
}

- (void)layoutSublayers
{
	CGFloat scrollAreaWidth = [self scrollAreaSize].width;

	CALayer *knobLayer = [self.sublayers firstObject];
	if ( !CGRectIsEmpty(self.scrollLayer.visibleRect) && scrollAreaWidth > 0 ) {
		CGFloat visibleWidth = CGRectGetWidth(self.scrollLayer.visibleRect);
		CGFloat aspectRatio = visibleWidth / scrollAreaWidth;
		
		CGFloat effectiveScrollerWidth = CGRectGetWidth(self.bounds) - 2*kKnobMargin;
		CGFloat knobWidth = MAX(kMinimumKnobWidth, effectiveScrollerWidth * aspectRatio);
		CGFloat scale = MAX(0., CGRectGetMinX(self.scrollLayer.bounds)) / scrollAreaWidth;
		CGFloat knobPositionX = MIN(kKnobMargin + (effectiveScrollerWidth - knobWidth) * scale, CGRectGetMaxX(self.bounds) - knobWidth - kKnobMargin);
		
		knobLayer.frame = CGRectMake(knobPositionX, CGRectGetMinY(knobLayer.frame), knobWidth, CGRectGetHeight(knobLayer.bounds));
		self.hidden = aspectRatio >= 1;
	}
	else {
		self.hidden = YES;
		knobLayer.frame = CGRectMake(kKnobMargin, CGRectGetMinY(knobLayer.frame), kMinimumKnobWidth, CGRectGetHeight(knobLayer.bounds));
	}
}

@end
