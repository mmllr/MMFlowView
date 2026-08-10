/*
 
 The MIT License (MIT)
 
 Copyright (c) 2014 Markus Müller https://codeberg.org/mmllr All rights reserved.
 
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
//  MMCoverFlowImageLayerSpec.m
//
//  Created by Markus Müller on 06.12.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowViewImageLayer.h"

@interface MMCoverFlowImageLayerSpec : XCTestCase

@end

@implementation MMCoverFlowImageLayerSpec
{
	MMFlowViewImageLayer *_sut;
}

static const NSUInteger expectedIndex = 1;

- (void)setUp
{
	[super setUp];
	_sut = [[MMFlowViewImageLayer alloc] initWithIndex:expectedIndex];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testThrowsWhenCreatedWithLayer
{
	XCTAssertThrowsSpecificNamed([MMFlowViewImageLayer layer], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInit
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewImageLayer alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testHasIndex
{
	XCTAssertEqual(_sut.index, expectedIndex);
}

- (void)testHasName
{
	XCTAssertEqualObjects(_sut.name, @"MMFlowViewContentLayerImage");
}

- (void)testHasContentsGravityResizeAspect
{
	XCTAssertEqualObjects(_sut.contentsGravity, kCAGravityResizeAspect);
}

- (void)testHasConstraintLayoutManager
{
	XCTAssertEqualObjects(_sut.layoutManager, [CAConstraintLayoutManager layoutManager]);
}

- (void)testOrderOutTransitionIsFadingHalfSecond
{
	CATransition *transition = (CATransition *)[_sut actionForKey:kCAOnOrderOut];
	XCTAssertTrue([transition isKindOfClass:[CATransition class]]);
	XCTAssertEqualObjects(transition.type, kCATransitionFade);
	XCTAssertEqual(transition.duration, (CGFloat).5);
}

- (void)testOrderInTransitionIsRevealingHalfSecond
{
	CATransition *transition = (CATransition *)[_sut actionForKey:kCAOnOrderIn];
	XCTAssertTrue([transition isKindOfClass:[CATransition class]]);
	XCTAssertEqualObjects(transition.type, kCATransitionReveal);
	XCTAssertEqual(transition.duration, (CGFloat).5);
}

- (void)testNoContentsAction
{
	XCTAssertNil([_sut actionForKey:@"contents"]);
}

- (void)testNoBoundsAction
{
	XCTAssertNil([_sut actionForKey:@"bounds"]);
}

@end
