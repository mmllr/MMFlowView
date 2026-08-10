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
//  MMScrollKnobLayerSpec.m
//
//  Created by Markus Müller on 21.10.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMScrollKnobLayer.h"
#import "MMScrollBarLayer.h"

@interface MMScrollKnobLayerSpec : XCTestCase

@end

@implementation MMScrollKnobLayerSpec
{
	MMScrollKnobLayer *_sut;
}

- (void)setUp
{
	[super setUp];
	_sut = [MMScrollKnobLayer layer];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testIsCAGradientLayerClass
{
	XCTAssertTrue([_sut isKindOfClass:[CAGradientLayer class]]);
}

- (void)testName
{
	XCTAssertEqualObjects(_sut.name, @"MMScrollKnobLayer");
}

- (void)testHeightOfSixteen
{
	XCTAssertEqual(CGRectGetHeight(_sut.frame), (CGFloat)16.);
}

- (void)testWidthOfForty
{
	XCTAssertEqual(CGRectGetWidth(_sut.frame), (CGFloat)40.);
}

- (void)testDisplaysOnBoundsChange
{
	XCTAssertTrue(_sut.needsDisplayOnBoundsChange);
}

- (void)testGrayBorderColor
{
	XCTAssertEqualObjects([NSColor colorWithCGColor:_sut.borderColor], [NSColor grayColor]);
}

- (void)testBorderWidthOfOne
{
	XCTAssertEqual(_sut.borderWidth, (CGFloat)1.);
}

- (void)testCornerRadiusOfNine
{
	XCTAssertEqual(_sut.cornerRadius, (CGFloat)9.);
}

- (void)testAnchorPoint
{
	XCTAssertEqualObjects([NSValue valueWithPoint:_sut.anchorPoint], [NSValue valueWithPoint:CGPointMake(.5, .5)]);
}

- (void)testStartPoint
{
	XCTAssertEqualObjects([NSValue valueWithPoint:_sut.startPoint], [NSValue valueWithPoint:CGPointMake(0.5, 1.)]);
}

- (void)testEndPoint
{
	XCTAssertEqualObjects([NSValue valueWithPoint:_sut.endPoint], [NSValue valueWithPoint:CGPointMake(0.5, 0)]);
}

- (void)testGradientColors
{
	NSArray *expectedColors = @[(__bridge id)[[NSColor colorWithCalibratedRed:64.f / 255.f green:64.f / 255.f blue:74.f / 255.f alpha:1] CGColor],
								(__bridge id)[[NSColor colorWithCalibratedRed:46.f / 255.f green:46.f / 255.f blue:58.f / 255.f alpha:1.f] CGColor],
								(__bridge id)[[NSColor colorWithCalibratedRed:37.f / 255.f green:37.f / 255.f blue:50.f / 255.f alpha:1.f] CGColor],
								(__bridge id)[[NSColor colorWithCalibratedRed:51.f / 255.f green:52.f / 255.f blue:66.f / 255.f alpha:1.f] CGColor]];
	XCTAssertEqualObjects(_sut.colors, expectedColors);
}

- (void)testGradientLocations
{
	NSArray *expectedLocations = @[@0., @0.5, @0.51, @1.];
	XCTAssertEqualObjects(_sut.locations, expectedLocations);
}

- (void)testAxialGradientType
{
	XCTAssertEqualObjects(_sut.type, kCAGradientLayerAxial);
}

- (void)testDisabledImplicitPositionAction
{
	XCTAssertEqualObjects(_sut.actions[@"position"], [NSNull null]);
}

- (void)testDisabledImplicitBoundsAction
{
	XCTAssertEqualObjects(_sut.actions[@"bounds"], [NSNull null]);
}

- (void)testAccessibilityIsNotIgnored
{
	XCTAssertFalse([_sut accessibilityIsIgnored]);
}

- (void)testAccessibilityValueIndicatorRole
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityRoleAttribute], NSAccessibilityValueIndicatorRole);
}

- (void)testAccessibilityEnabled
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityEnabledAttribute], @YES);
}

// DISABLED: the original NSAccessibilityValueAttribute context stubbed the knob's
// superlayer with a mocked MMScrollBarLayer to verify value delegation
// (accessibilityAttributeValue:/accessibilitySetValue:forAttribute: forwarded to
// the parent). This requires stubbing the superlayer relationship and is not
// testable with plain XCTest.

@end
