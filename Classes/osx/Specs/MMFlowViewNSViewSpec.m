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
//  MMFlowViewNSViewSpec.m
//
//  Created by Markus Müller on 02.04.14.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <objc/runtime.h>

#import "MMFlowView.h"
#import "MMFlowView_Private.h"
#import "MMFlowView+NSKeyValueObserving.h"
#import "MMTestImageItem.h"

static BOOL testingSuperInvoked = NO;

@interface MMFlowView (MMFlowViewNSViewSpec)
- (void)mmTesting_viewWillMoveToSuperview:(NSView *)newSuperview;
@end

@implementation MMFlowView (MMResponderTests)

- (void)mmTesting_viewWillMoveToSuperview:(NSView *)newSuperview
{
	testingSuperInvoked = YES;
}

@end

@interface MMFlowViewNSViewSpec : XCTestCase

@end

@implementation MMFlowViewNSViewSpec
{
	MMFlowView *_sut;
}

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testIsNotFlipped
{
	XCTAssertFalse([_sut isFlipped]);
}

- (void)testIsOpaque
{
	XCTAssertTrue([_sut isOpaque]);
}

- (void)testNeedsPanelToBecomeKey
{
	XCTAssertTrue([_sut needsPanelToBecomeKey]);
}

- (void)testAcceptsTouchEvents
{
	XCTAssertTrue([_sut acceptsTouchEvents]);
}

- (void)testHasNoIntrinsicContentSize
{
	NSSize expectedContentSize = NSMakeSize(NSViewNoIntrinsicMetric, NSViewNoIntrinsicMetric);
	XCTAssertTrue(NSEqualSizes(_sut.intrinsicContentSize, expectedContentSize));
}

- (void)testDoesNotTranslateAutoresizingMaskIntoConstraints
{
	XCTAssertFalse([_sut translatesAutoresizingMaskIntoConstraints]);
}

- (void)testViewWillMoveToSuperviewUnbindsContentArrayBinding
{
	NSArrayController *controller = [[NSArrayController alloc] initWithContent:@[[MMTestImageItem new], [MMTestImageItem new]]];
	[controller setObjectClass:[MMTestImageItem class]];
	[_sut bind:NSContentArrayBinding toObject:controller withKeyPath:@"arrangedObjects" options:nil];

	NSView *container = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 400, 300)];
	[container addSubview:_sut];
	XCTAssertNotNil([_sut superview]);

	[_sut viewWillMoveToSuperview:nil];

	XCTAssertNil([_sut infoForBinding:NSContentArrayBinding]);
}

- (void)testViewWillMoveToSuperviewCallsSuper
{
	Method supersMethod = class_getInstanceMethod([_sut superclass], @selector(viewWillMoveToSuperview:));
	Method testingMethod = class_getInstanceMethod([_sut class], @selector(mmTesting_viewWillMoveToSuperview:));
	method_exchangeImplementations(supersMethod, testingMethod);

	testingSuperInvoked = NO;
	[_sut viewWillMoveToSuperview:[NSView new]];
	XCTAssertTrue(testingSuperInvoked);

	method_exchangeImplementations(testingMethod, supersMethod);
}

@end
