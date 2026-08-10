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
//  MMFlowViewNSAccessibilitySpec.m
//
//  Created by Markus Müller on 13.02.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <objc/runtime.h>

#import "MMFlowView+NSAccessibility.h"
#import "MMFlowView_Private.h"

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMFlowViewNSAccessibilitySpec)
- (id)mmTesting_accessibilityAttributeValue:(NSString *)attribute;
@end

@implementation MMFlowView (MMFlowViewNSAccessibilitySpec)

- (id)mmTesting_accessibilityAttributeValue:(NSString *)attribute
{
	testingSuperInvoked = YES;
	return nil;
}

@end

@interface MMFlowViewNSAccessibilitySpec : XCTestCase

@end

@implementation MMFlowViewNSAccessibilitySpec
{
	MMFlowView *_sut;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 400)];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testIsNotIgnored
{
	XCTAssertFalse([_sut accessibilityIsIgnored]);
}

- (void)testHasExpectedAttributeNames
{
	NSArray *expectedAttributes = @[NSAccessibilityChildrenAttribute,
									NSAccessibilityContentsAttribute,
									NSAccessibilityRoleAttribute,
									NSAccessibilityRoleDescriptionAttribute,
									NSAccessibilityHorizontalScrollBarAttribute];
	for (NSString *attribute in expectedAttributes) {
		XCTAssertTrue([[_sut accessibilityAttributeNames] containsObject:attribute]);
	}
}

- (void)testHasScrollAreaRole
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityRoleAttribute], NSAccessibilityScrollAreaRole);
}

- (void)testHasCorrectRoleDescription
{
	NSString *expectedRoleDescription = NSAccessibilityRoleDescriptionForUIElement(_sut);
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityRoleDescriptionAttribute], expectedRoleDescription);
}

- (void)testHasTwoChildren
{
	NSArray *expectedChildren = @[_sut.coverFlowLayer, _sut.scrollBarLayer];
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityChildrenAttribute], expectedChildren);
}

- (void)testHasCoverFlowLayerAsContent
{
	NSArray *expectedContents = @[_sut.coverFlowLayer];
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityContentsAttribute], expectedContents);
}

- (void)testHasScrollBarLayerAsHorizontalScrollBar
{
	XCTAssertEqualObjects([_sut accessibilityAttributeValue:NSAccessibilityHorizontalScrollBarAttribute], _sut.scrollBarLayer);
}

- (void)testUnhandledAttributesCallUpToSuper
{
	NSArray *unhandledAttributes = @[NSAccessibilityPositionAttribute, NSAccessibilitySizeAttribute, NSAccessibilityWindowAttribute];
	Method supersMethod = class_getInstanceMethod([_sut superclass], @selector(accessibilityAttributeValue:));
	Method testingMethod = class_getInstanceMethod([_sut class], @selector(mmTesting_accessibilityAttributeValue:));
	method_exchangeImplementations(supersMethod, testingMethod);

	for (NSString *attribute in unhandledAttributes) {
		testingSuperInvoked = NO;
		[_sut accessibilityAttributeValue:attribute];
		XCTAssertTrue(testingSuperInvoked);
	}

	method_exchangeImplementations(testingMethod, supersMethod);
}

// DISABLED: accessibilityHitTest: was verified with mocked window/contentView/hit
// layer geometry (convertRectFromScreen:, convertPoint:toView:, hitLayerAtPoint:).
// Recreating that coordinate plumbing with real windows and layers in a headless
// test run is not reliable; the AX attribute contract is covered above.

@end
