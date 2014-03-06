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
#import "MMMacros.h"

static NSString * const kLayerName = @"MMScrollBarLayerName";
static const CGFloat kBorderWidth = 1.;
static const CGFloat kCornerRadius = 10.;
static const CGFloat kHeight = 20.;
static const CGFloat kYOffset = 10.;
static const CGFloat kWidthScale = .75;
static const CGFloat kHorizontalKnobMargin = 5.;
static const CGFloat kVerticalKnobMargin = 2.;
static const CGFloat kMinimumKnobWidth = 40.;

@implementation MMScrollBarLayer

@dynamic scrollBarDelegate;

#pragma mark - init/cleanup

- (id)init
{
    self = [super init];
    if (self) {
        self.name = kLayerName;
		self.backgroundColor = [ [ NSColor blackColor ] CGColor ];
		self.borderColor = [ [ NSColor grayColor ] CGColor ];
		self.opaque = YES;
		self.borderWidth = kBorderWidth;
		self.cornerRadius = kCornerRadius;
		self.frame = CGRectMake(0, 0, 100., kHeight);
		[self setupConstraints];
		[self mm_disableImplicitPositionAndBoundsAnimations];
		[self setupAccessibility];
		[self setupSublayers];
    }
    return self;
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

- (void)mouseDownAtPoint:(CGPoint)pointInLayerCoordinates
{
	MMScrollKnobLayer *knob = [self.sublayers firstObject];

	if (pointInLayerCoordinates.x < CGRectGetMinX(knob.frame) &&
		[self.scrollBarDelegate respondsToSelector:@selector(decrementClickedInScrollBarLayer:)]) {
		[self.scrollBarDelegate decrementClickedInScrollBarLayer:self];
	}
	else if (pointInLayerCoordinates.x > CGRectGetMaxX(knob.frame) &&
			 [self.scrollBarDelegate respondsToSelector:@selector(incrementClickedInScrollBarLayer:)]) {
		[self.scrollBarDelegate incrementClickedInScrollBarLayer:self];
	}
	else {
		[self beginDragAtPoint:pointInLayerCoordinates];
	}
}

#pragma mark - dragging

- (void)beginDragAtPoint:(CGPoint)pointInLayerCoordinates
{
	if (!CGRectContainsPoint(self.bounds, pointInLayerCoordinates)) {
		self.dragOrigin = CGPointZero;
		return;
	}
	self.dragOrigin = pointInLayerCoordinates;
}

- (void)mouseDraggedToPoint:(CGPoint)pointInLayerCoordinates
{
	if (CGPointEqualToPoint(self.dragOrigin, CGPointZero) ||
		![self.scrollBarDelegate respondsToSelector:@selector(scrollBarLayer:knobDraggedToPosition:)]) {
		return;
	}
	MMScrollKnobLayer *knobLayer = [self.sublayers firstObject];
	CGFloat minX = kHorizontalKnobMargin;
	CGFloat maxX = CGRectGetMaxX(self.bounds) - kHorizontalKnobMargin - CGRectGetWidth(knobLayer.bounds);
	CGFloat draggedPosition = CLAMP(pointInLayerCoordinates.x, minX, maxX);
	CGFloat scrollWidth = maxX - minX;
	CGFloat position = (draggedPosition - minX) / scrollWidth;
	[self.scrollBarDelegate scrollBarLayer:self knobDraggedToPosition:position];
}

- (void)endDrag
{
	self.dragOrigin = CGPointZero;
}

#pragma mark - CALayer overrides

- (CGFloat)contentSize
{
	if (![self.scrollBarDelegate respondsToSelector:@selector(contentSizeForScrollBarLayer:)]) {
		return 1;
	}
	CGFloat contentSize = [self.scrollBarDelegate contentSizeForScrollBarLayer:self];
	return contentSize > 0 ? contentSize : 1;
}

- (CGFloat)visibleSize
{
	if (![self.scrollBarDelegate respondsToSelector:@selector(visibleSizeForScrollBarLayer:)]) {
		return 1;
	}
	CGFloat visibliSize = [self.scrollBarDelegate visibleSizeForScrollBarLayer:self];
	return visibliSize > 0 ? visibliSize : 1;
}

- (CGFloat)contentToVisibleAspectRatio
{
	CGFloat contentSize = [self contentSize];
	CGFloat visibleSize = [self visibleSize];

	return contentSize > visibleSize ? visibleSize / contentSize : 1;
}

- (CGFloat)currentKnobPosition
{
	if (![self.scrollBarDelegate respondsToSelector:@selector(currentKnobPositionInScrollBarLayer:)]) {
		return 0;
	}
	return CLAMP([self.scrollBarDelegate currentKnobPositionInScrollBarLayer:self], 0, 1);
}

- (void)layoutSublayers
{
	CGFloat contentToVisibleAspectRatio = [self contentToVisibleAspectRatio];
	self.hidden = (contentToVisibleAspectRatio == 1);

	CGFloat effectiveScrollerWidth = CGRectGetWidth(self.bounds) - 2*kHorizontalKnobMargin;
	CGFloat knobWidth = MAX(kMinimumKnobWidth, effectiveScrollerWidth * contentToVisibleAspectRatio);
	CGFloat currentKnobPosition = [self currentKnobPosition];
	CGFloat availableScrollingSize = effectiveScrollerWidth - knobWidth;
	
	CALayer *knobLayer = [self.sublayers firstObject];
	knobLayer.frame = CGRectMake(kHorizontalKnobMargin + currentKnobPosition*availableScrollingSize, kVerticalKnobMargin, knobWidth, CGRectGetHeight(self.bounds) - 2*kVerticalKnobMargin);
}

@end
