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
//  MMScrollBarLayerSpec.m
//
//  Created by Markus Müller on 14.11.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMScrollBarLayer.h"
#import "MMScrollKnobLayer.h"
#import "MMFlowViewTestDoubles.h"

@interface MMScrollBarLayerSpec : XCTestCase

@end

@implementation MMScrollBarLayerSpec
{
	MMScrollBarLayer *_sut;
	MMScrollKnobLayer *_knobLayer;
	MMTestScrollBarDelegate *_delegate;
}

static const CGFloat horizontalKnobMargin = 5;
static const CGFloat verticalKnobMargin = 2;

- (void)setUp
{
	[super setUp];
	_sut = [[MMScrollBarLayer alloc] init];
	_knobLayer = [_sut.sublayers firstObject];
	_delegate = [[MMTestScrollBarDelegate alloc] init];
}

- (void)tearDown
{
	_delegate = nil;
	_sut = nil;
	_knobLayer = nil;
	[super tearDown];
}

- (void)testInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testIsKindOfMMScrollBarLayer
{
	XCTAssertTrue([_sut isKindOfClass:[MMScrollBarLayer class]]);
}

- (void)testName
{
	XCTAssertEqualObjects(_sut.name, @"MMScrollBarLayerName");
}

- (void)testBlackBackgroundColor
{
	XCTAssertEqualObjects([NSColor colorWithCGColor:_sut.backgroundColor], [NSColor blackColor]);
}

- (void)testGrayBorderColor
{
	XCTAssertEqualObjects([NSColor colorWithCGColor:_sut.borderColor], [NSColor grayColor]);
}

- (void)testIsOpaque
{
	XCTAssertTrue(_sut.opaque);
}

- (void)testBorderWidthOfOne
{
	XCTAssertEqual(_sut.borderWidth, (CGFloat)1.);
}

- (void)testCornerRadiusOfTen
{
	XCTAssertEqual(_sut.cornerRadius, (CGFloat)10.);
}

- (void)testHeightOfTwenty
{
	XCTAssertEqual(CGRectGetHeight(_sut.frame), (CGFloat)20);
}

- (void)testWidthOfOneHundred
{
	XCTAssertEqual(CGRectGetWidth(_sut.frame), (CGFloat)100);
}

- (void)testNilScrollBarDelegate
{
	XCTAssertNil(_sut.scrollBarDelegate);
}

- (void)testOneSublayer
{
	XCTAssertEqual([_sut.sublayers count], (NSUInteger)1);
}

- (void)testSublayerIsMMScrollKnobLayer
{
	XCTAssertTrue([_knobLayer isKindOfClass:[MMScrollKnobLayer class]]);
}

- (void)testKnobLayerPosition
{
	XCTAssertTrue(NSEqualPoints(_knobLayer.frame.origin, NSMakePoint(horizontalKnobMargin, verticalKnobMargin)));
}

- (void)testThreeConstraints
{
	XCTAssertEqual([_sut.constraints count], (NSUInteger)3);
}

- (void)testFirstConstraintIsMidXOfSuperlayer
{
	CAConstraint *constraint = _sut.constraints[0];
	XCTAssertEqualObjects(constraint.sourceName, @"superlayer");
	XCTAssertEqual(constraint.sourceAttribute, kCAConstraintMidX);
	XCTAssertEqual(constraint.attribute, kCAConstraintMidX);
	XCTAssertEqual(constraint.scale, (CGFloat)1);
	XCTAssertEqual(constraint.offset, (CGFloat)0);
}

- (void)testSecondConstraintIsMinYOfSuperlayerWithOffset
{
	CAConstraint *constraint = _sut.constraints[1];
	XCTAssertEqualObjects(constraint.sourceName, @"superlayer");
	XCTAssertEqual(constraint.sourceAttribute, kCAConstraintMinY);
	XCTAssertEqual(constraint.attribute, kCAConstraintMinY);
	XCTAssertEqual(constraint.scale, (CGFloat)1);
	XCTAssertEqual(constraint.offset, (CGFloat)10.);
}

- (void)testThirdConstraintIsWidthOfSuperlayerWithScale
{
	CAConstraint *constraint = _sut.constraints[2];
	XCTAssertEqualObjects(constraint.sourceName, @"superlayer");
	XCTAssertEqual(constraint.sourceAttribute, kCAConstraintWidth);
	XCTAssertEqual(constraint.attribute, kCAConstraintWidth);
	XCTAssertEqual(constraint.offset, (CGFloat)0.);
	XCTAssertEqual(constraint.scale, (CGFloat).75);
}

- (void)testDisabledImplicitPositionAction
{
	XCTAssertEqualObjects(_sut.actions[@"position"], [NSNull null]);
}

- (void)testDisabledImplicitBoundsAction
{
	XCTAssertEqualObjects(_sut.actions[@"bounds"], [NSNull null]);
}

#pragma mark - NSAccessibility

- (void)testAccessibilityIsNotIgnored
{
	XCTAssertFalse([_sut accessibilityIsIgnored]);
}

- (void)testAccessibilityScrollBarRole
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityRoleAttribute], NSAccessibilityScrollBarRole);
}

- (void)testAccessibilityHorizontalOrientation
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityOrientationAttribute], NSAccessibilityHorizontalOrientationValue);
}

- (void)testAccessibilityEnabled
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityEnabledAttribute], @YES);
}

- (void)testAccessibilityValueAttributePresent
{
	XCTAssertTrue([[_sut accessibilityAttributeNames] containsObject:NSAccessibilityValueAttribute]);
}

- (void)testAccessibilityValueReturnsKnobPositionFromDelegate
{
	_delegate.knobPosition = .5;
	_sut.scrollBarDelegate = _delegate;
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityValueAttribute], @(.5));
}

- (void)testAccessibilityValueIsSettable
{
	_delegate.knobPosition = .5;
	_sut.scrollBarDelegate = _delegate;
	XCTAssertTrue([_sut accessibilityIsAttributeSettable:NSAccessibilityValueAttribute]);
}

- (void)testAccessibilitySetValueNotifiesDelegate
{
	_delegate.knobPosition = .5;
	_sut.scrollBarDelegate = _delegate;
	[_sut accessibilitySetValue:@(.9) forAttribute:NSAccessibilityValueAttribute];
	XCTAssertEqualObjects(_delegate.draggedPositions.lastObject, @(.9));
}

- (void)testAccessibilityValueReturnsZeroWithoutDelegate
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityValueAttribute], @0);
}

- (void)testAccessibilityValueReturnsZeroWithIncompleteDelegate
{
	_sut.scrollBarDelegate = (id<MMScrollBarDelegate>)[NSObject new];
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityValueAttribute], @0);
}

- (void)testAccessibilitySetValueWithIncompleteDelegateDoesNotThrow
{
	_sut.scrollBarDelegate = (id<MMScrollBarDelegate>)[NSObject new];
	XCTAssertNoThrow([_sut accessibilitySetValue:@(.4) forAttribute:NSAccessibilityValueAttribute]);
}

#pragma mark - layoutSublayers

- (void)testLayoutSublayersAsksDelegateForSizesAndPosition
{
	_delegate.contentSize = 2000;
	_delegate.visibleSize = 500;
	_delegate.knobPosition = 0;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, 375, 20);

	[_sut layoutSublayers];

	XCTAssertEqual(_delegate.knobPosition, (CGFloat)0);
}

- (void)knobFrameForPosition:(CGFloat)position
				contentSize:(CGFloat)contentSize
				visibleSize:(CGFloat)visibleSize
				scrollBarWidth:(CGFloat)scrollBarWidth
				expectedFrame:(CGRect *)outFrame
				expectHidden:(BOOL *)outHidden
{
	_delegate.contentSize = contentSize;
	_delegate.visibleSize = visibleSize;
	_delegate.knobPosition = position;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, scrollBarWidth, 20);

	[_sut layoutSublayers];

	*outFrame = _knobLayer.frame;
	*outHidden = _sut.hidden;
}

- (void)testKnobFrameAndVisibilityForLeftmostPosition
{
	CGFloat contentSize = 2000;
	CGFloat visibleSize = 500;
	CGFloat scrollBarWidth = visibleSize * .75;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGFloat contentToVisibleAspectRatio = visibleSize / contentSize;
	CGFloat expectedKnobWidth = effectiveScrollBarWidth * contentToVisibleAspectRatio;
	CGFloat availableScrollingSize = effectiveScrollBarWidth - expectedKnobWidth;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin + availableScrollingSize * 0, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:0 contentSize:contentSize visibleSize:visibleSize scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
	XCTAssertFalse(hidden);
}

- (void)testKnobFrameAndVisibilityForMidPosition
{
	CGFloat contentSize = 2000;
	CGFloat visibleSize = 500;
	CGFloat scrollBarWidth = visibleSize * .75;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGFloat contentToVisibleAspectRatio = visibleSize / contentSize;
	CGFloat expectedKnobWidth = effectiveScrollBarWidth * contentToVisibleAspectRatio;
	CGFloat availableScrollingSize = effectiveScrollBarWidth - expectedKnobWidth;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin + availableScrollingSize * .5, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:.5 contentSize:contentSize visibleSize:visibleSize scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
	XCTAssertFalse(hidden);
}

- (void)testKnobFrameAndVisibilityForRightmostPosition
{
	CGFloat contentSize = 2000;
	CGFloat visibleSize = 500;
	CGFloat scrollBarWidth = visibleSize * .75;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGFloat contentToVisibleAspectRatio = visibleSize / contentSize;
	CGFloat expectedKnobWidth = effectiveScrollBarWidth * contentToVisibleAspectRatio;
	CGFloat availableScrollingSize = effectiveScrollBarWidth - expectedKnobWidth;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin + availableScrollingSize * 1, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:1 contentSize:contentSize visibleSize:visibleSize scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
	XCTAssertFalse(hidden);
}

- (void)testKnobFrameClampedForNegativePosition
{
	CGFloat contentSize = 2000;
	CGFloat visibleSize = 500;
	CGFloat scrollBarWidth = visibleSize * .75;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGFloat contentToVisibleAspectRatio = visibleSize / contentSize;
	CGFloat expectedKnobWidth = effectiveScrollBarWidth * contentToVisibleAspectRatio;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:-10 contentSize:contentSize visibleSize:visibleSize scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
	XCTAssertFalse(hidden);
}

- (void)testKnobFrameClampedForPositionGreaterThanOne
{
	CGFloat contentSize = 2000;
	CGFloat visibleSize = 500;
	CGFloat scrollBarWidth = visibleSize * .75;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGFloat contentToVisibleAspectRatio = visibleSize / contentSize;
	CGFloat expectedKnobWidth = effectiveScrollBarWidth * contentToVisibleAspectRatio;
	CGFloat expectedPosition = horizontalKnobMargin + effectiveScrollBarWidth - expectedKnobWidth;
	CGRect expectedKnobFrame = CGRectMake(expectedPosition, verticalKnobMargin, expectedKnobWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:2 contentSize:contentSize visibleSize:visibleSize scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
	XCTAssertFalse(hidden);
}

- (void)testHiddenWhenVisibleAndContentSizeEqual
{
	CGFloat scrollBarWidth = 100;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, effectiveScrollBarWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:0 contentSize:100 visibleSize:100 scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(hidden);
	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
}

- (void)testHiddenWhenContentSizeWayGreaterThanVisibleSize
{
	CGFloat scrollBarWidth = 100;
	CGFloat minimumKnobWidth = 40.;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, minimumKnobWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:0 contentSize:5000 visibleSize:10 scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertFalse(hidden);
	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
}

- (void)testHiddenWhenVisibleSizeGreaterThanContentSize
{
	CGFloat scrollBarWidth = 100;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, effectiveScrollBarWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:0 contentSize:100 visibleSize:200 scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(hidden);
	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
}

- (void)testHiddenAndFullWidthKnobForZeroContentSize
{
	CGFloat scrollBarWidth = 100;
	CGFloat effectiveScrollBarWidth = scrollBarWidth - 2 * horizontalKnobMargin;
	CGRect expectedKnobFrame = CGRectMake(horizontalKnobMargin, verticalKnobMargin, effectiveScrollBarWidth, CGRectGetHeight(_sut.bounds) - 2 * verticalKnobMargin);

	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:0 contentSize:0 visibleSize:100 scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];

	XCTAssertTrue(hidden);
	XCTAssertTrue(CGRectEqualToRect(actualFrame, expectedKnobFrame));
}

- (void)testHiddenForNegativeContentSize
{
	CGFloat scrollBarWidth = 100;
	CGRect actualFrame;
	BOOL hidden;
	[self knobFrameForPosition:0 contentSize:-100 visibleSize:100 scrollBarWidth:scrollBarWidth expectedFrame:&actualFrame expectHidden:&hidden];
	XCTAssertTrue(hidden);
}

- (void)testHiddenWithIncompleteDelegate
{
	_sut.scrollBarDelegate = (id<MMScrollBarDelegate>)[NSObject new];
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	[_sut layoutSublayers];
	XCTAssertTrue(_sut.hidden);
}

#pragma mark - dragging

- (void)testRespondsToBeginDragAtPoint
{
	XCTAssertTrue([_sut respondsToSelector:@selector(beginDragAtPoint:)]);
}

- (void)testBeginDragOutsideKnobSetsDraggingOffsetToMinusOne
{
	CGPoint dragPoint = CGPointMake(CGRectGetMinX(_knobLayer.frame) - 10, CGRectGetMinY(_knobLayer.frame) - 10);
	[_sut beginDragAtPoint:dragPoint];
	XCTAssertEqualWithAccuracy(_sut.draggingOffset, -1, .0000001);
}

- (void)testBeginDragInsideKnobSetsDraggingOffsetToClickPosition
{
	CGPoint dragPoint = CGPointMake(CGRectGetMidX(_knobLayer.frame), CGRectGetMinY(_knobLayer.frame));
	CGFloat expectedOffset = dragPoint.x - CGRectGetMinX(_knobLayer.frame);
	[_sut beginDragAtPoint:dragPoint];
	XCTAssertEqualWithAccuracy(_sut.draggingOffset, expectedOffset, .0000001);
}

- (void)testRespondsToEndDrag
{
	XCTAssertTrue([_sut respondsToSelector:@selector(endDrag)]);
}

- (void)testEndDragSetsDraggingOffsetToMinusOne
{
	[_sut endDrag];
	XCTAssertEqualWithAccuracy(_sut.draggingOffset, -1, .0000001);
}

- (void)testRespondsToMouseDraggedToPoint
{
	XCTAssertTrue([_sut respondsToSelector:@selector(mouseDraggedToPoint:)]);
}

- (void)testMouseDraggedToPointWhileDragging
{
	_delegate.contentSize = 1000;
	_delegate.visibleSize = 100;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	[_sut layoutSublayers];

	_sut.draggingOffset = 15;
	NSUInteger before = [_delegate.draggedPositions count];

	// drag far left -> position 0
	CGPoint draggedPoint = CGPointMake(CGRectGetMinX(_sut.frame) - 10, CGRectGetMidY(_sut.frame));
	[_sut mouseDraggedToPoint:draggedPoint];
	XCTAssertEqual([_delegate.draggedPositions count], before + 1);
	XCTAssertEqualObjects(_delegate.draggedPositions.lastObject, @(0));

	// drag to rightmost -> position 1
	draggedPoint = CGPointMake(CGRectGetMaxX(_sut.frame), CGRectGetMidY(_sut.frame));
	[_sut mouseDraggedToPoint:draggedPoint];
	XCTAssertEqualObjects(_delegate.draggedPositions.lastObject, @(1));

	// drag to mid position adjusted by draggingOffset
	draggedPoint = CGPointMake(CGRectGetMidX(_sut.frame) + 10, CGRectGetMidY(_sut.frame));
	[_sut mouseDraggedToPoint:draggedPoint];
	CGFloat dragPointCorrectedByOffset = draggedPoint.x - _sut.draggingOffset;
	CGFloat minX = horizontalKnobMargin;
	CGFloat maxX = CGRectGetMaxX(_sut.bounds) - horizontalKnobMargin - CGRectGetWidth(_knobLayer.bounds);
	CGFloat scrollWidth = maxX - minX;
	CGFloat expectedPosition = (dragPointCorrectedByOffset - minX) / scrollWidth;
	XCTAssertEqualWithAccuracy([_delegate.draggedPositions.lastObject doubleValue], expectedPosition, 0.000001);
}

- (void)testMouseDraggedToPointNotInDragDoesNotInvokeDelegate
{
	_delegate.contentSize = 1000;
	_delegate.visibleSize = 100;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	[_sut layoutSublayers];

	_sut.draggingOffset = -1;
	NSUInteger before = [_delegate.draggedPositions count];
	[_sut mouseDraggedToPoint:CGPointMake(CGRectGetMidX(_sut.frame), CGRectGetMidY(_sut.frame))];
	XCTAssertEqual([_delegate.draggedPositions count], before);
}

- (void)testMouseDraggedToPointWithIncompleteDelegateDoesNotThrow
{
	_sut.scrollBarDelegate = (id<MMScrollBarDelegate>)[NSObject new];
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	_sut.draggingOffset = 15;
	XCTAssertNoThrow([_sut mouseDraggedToPoint:CGPointMake(50, 10)]);
}

#pragma mark - mouseDown

- (void)testRespondsToMouseDownAtPoint
{
	XCTAssertTrue([_sut respondsToSelector:@selector(mouseDownAtPoint:)]);
}

- (void)testMouseDownLeftOfKnobDecrements
{
	_delegate.contentSize = 1000;
	_delegate.visibleSize = 100;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	[_sut layoutSublayers];

	CGPoint mousePoint = CGPointMake(CGRectGetMinX(_knobLayer.frame) - 10, CGRectGetMidY(_sut.bounds));
	[_sut mouseDownAtPoint:mousePoint];

	XCTAssertGreaterThan(_delegate.decrementCount, (NSUInteger)0);
	XCTAssertEqual(_delegate.incrementCount, (NSUInteger)0);
}

- (void)testMouseDownRightOfKnobIncrements
{
	_delegate.contentSize = 1000;
	_delegate.visibleSize = 100;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	[_sut layoutSublayers];

	CGPoint mousePoint = CGPointMake(CGRectGetMaxX(_knobLayer.frame) + 10, CGRectGetMidY(_sut.bounds));
	[_sut mouseDownAtPoint:mousePoint];

	XCTAssertGreaterThan(_delegate.incrementCount, (NSUInteger)0);
	XCTAssertEqual(_delegate.decrementCount, (NSUInteger)0);
}

- (void)testMouseDownOnKnobStartsDrag
{
	_delegate.contentSize = 1000;
	_delegate.visibleSize = 100;
	_sut.scrollBarDelegate = _delegate;
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	[_sut layoutSublayers];

	CGPoint mousePoint = CGPointMake(CGRectGetMidX(_knobLayer.frame), CGRectGetMidY(_sut.bounds));
	[_sut mouseDownAtPoint:mousePoint];

	XCTAssertNotEqualWithAccuracy(_sut.draggingOffset, -1, .0000001);
	XCTAssertEqual(_delegate.decrementCount, (NSUInteger)0);
	XCTAssertEqual(_delegate.incrementCount, (NSUInteger)0);
}

- (void)testMouseDownLeftOfKnobWithIncompleteDelegateDoesNotThrow
{
	_sut.scrollBarDelegate = (id<MMScrollBarDelegate>)[NSObject new];
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	XCTAssertNoThrow([_sut mouseDownAtPoint:CGPointMake(1, 10)]);
}

- (void)testMouseDownRightOfKnobWithIncompleteDelegateDoesNotThrow
{
	_sut.scrollBarDelegate = (id<MMScrollBarDelegate>)[NSObject new];
	_sut.bounds = CGRectMake(0, 0, 100, 20);
	XCTAssertNoThrow([_sut mouseDownAtPoint:CGPointMake(99, 10)]);
}

@end
