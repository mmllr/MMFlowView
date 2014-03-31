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
//  MMScrollBarLayer.m
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
@dynamic draggingOffset;

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
	__weak typeof(self) weakSelf = self;
	[self setWritableAccessibilityAttribute:NSAccessibilityValueAttribute readBlock:^id{
		MMScrollBarLayer *strongSelf = weakSelf;
		
		if ([strongSelf.scrollBarDelegate respondsToSelector:@selector(currentKnobPositionInScrollBarLayer:)]) {
			return @([strongSelf.scrollBarDelegate currentKnobPositionInScrollBarLayer:strongSelf]);
		}
		return @0;
	} writeBlock:^(id value) {
		MMScrollBarLayer *strongSelf = weakSelf;

		if ([strongSelf.scrollBarDelegate respondsToSelector:@selector(scrollBarLayer:knobDraggedToPosition:)]) {
			[strongSelf.scrollBarDelegate scrollBarLayer:strongSelf knobDraggedToPosition:[value doubleValue]];
		}
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
	NSAccessibilityPostNotification(self, NSAccessibilityValueChangedNotification);
}

#pragma mark - dragging

- (void)beginDragAtPoint:(CGPoint)pointInLayerCoordinates
{
	CALayer *knobLayer = [self.sublayers firstObject];
	if (!CGRectContainsPoint(knobLayer.frame, pointInLayerCoordinates)) {
		self.draggingOffset = -1;
		return;
	}
	self.draggingOffset = pointInLayerCoordinates.x - CGRectGetMinX(knobLayer.frame);
}

- (void)mouseDraggedToPoint:(CGPoint)pointInLayerCoordinates
{
	if (self.draggingOffset == -1 ||
		![self.scrollBarDelegate respondsToSelector:@selector(scrollBarLayer:knobDraggedToPosition:)]) {
		return;
	}
	CGFloat draggedPosition = CLAMP(pointInLayerCoordinates.x - self.draggingOffset, self.minimumKnobPosition, self.maximumKnobPosition);
	CGFloat position = (draggedPosition - self.minimumKnobPosition) / self.availabeScrollingSize;
	[self.scrollBarDelegate scrollBarLayer:self knobDraggedToPosition:position];
}

- (void)endDrag
{
	self.draggingOffset = -1;
}

#pragma mark - CALayer overrides

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

#pragma mark - helpers

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

- (CGFloat)minimumKnobPosition
{
	return kHorizontalKnobMargin;
}

- (CGFloat)maximumKnobPosition
{
	CALayer *knobLayer = [self.sublayers firstObject];
	return CGRectGetMaxX(self.bounds) - kHorizontalKnobMargin - CGRectGetWidth(knobLayer.bounds);
}

- (CGFloat)availabeScrollingSize
{
	return [self maximumKnobPosition] - [self minimumKnobPosition];
}

@end
