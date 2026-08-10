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
//  MMFlowViewItemLayerSpec.m
//
//  Created by Markus Müller on 06.12.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowViewItemLayer.h"
#import "MMFlowViewImageLayer.h"

@interface MMFlowViewItemLayerSpec : XCTestCase

@end

@implementation MMFlowViewItemLayerSpec
{
	MMFlowViewItemLayer *_sut;
}

static NSString *const expectedImageUID = @"imageUID";
static const NSUInteger expectedIndex = 1;

- (void)setUp
{
	[super setUp];
	_sut = [MMFlowViewItemLayer layerWithImageUID:expectedImageUID andIndex:expectedIndex];
}

- (void)tearDown
{
	_sut = nil;
	[super tearDown];
}

- (void)testThrowsWhenCreatedWithLayer
{
	XCTAssertThrowsSpecificNamed([MMFlowViewItemLayer layer], NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInit
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMFlowViewItemLayer alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testInstanceExists
{
	XCTAssertNotNil(_sut);
}

- (void)testIsCAReplicatorLayerSubclass
{
	XCTAssertTrue([_sut isKindOfClass:[CAReplicatorLayer class]]);
}

- (void)testDefaultWidthOfFifty
{
	XCTAssertEqual(CGRectGetWidth(_sut.frame), (CGFloat)50);
}

- (void)testDefaultHeightOfFifty
{
	XCTAssertEqual(CGRectGetHeight(_sut.frame), (CGFloat)50);
}

- (void)testInstanceCountOfTwo
{
	XCTAssertEqual(_sut.instanceCount, 2);
}

- (void)testPreservesDepth
{
	XCTAssertTrue(_sut.preservesDepth);
}

- (void)testIndexFromDesignatedInitializer
{
	XCTAssertEqual(_sut.index, expectedIndex);
}

- (void)testImageUIDFromDesignatedInitializer
{
	XCTAssertEqualObjects(_sut.imageUID, expectedImageUID);
}

- (void)testHasImageLayer
{
	XCTAssertNotNil(_sut.imageLayer);
}

- (void)testImageLayerIsMMFlowViewImageLayer
{
	XCTAssertTrue([_sut.imageLayer isKindOfClass:[MMFlowViewImageLayer class]]);
}

- (void)testReflectionOffsetDefault
{
	XCTAssertEqualWithAccuracy(_sut.reflectionOffset, (CGFloat)-.4, .0000001);
}

- (void)testReflectionOffsetAppliesToInstanceColorOffsets
{
	_sut.reflectionOffset = -.2;
	XCTAssertEqualWithAccuracy(_sut.instanceRedOffset, _sut.reflectionOffset, .000001);
	XCTAssertEqualWithAccuracy(_sut.instanceGreenOffset, _sut.reflectionOffset, .000001);
	XCTAssertEqualWithAccuracy(_sut.instanceBlueOffset, _sut.reflectionOffset, .000001);
}

- (void)testSettingImageSizesImageLayerToAspectRatio
{
	CGImageRef expectedImage = [[NSImage imageNamed:NSImageNameAdvanced] CGImageForProposedRect:NULL context:nil hints:nil];
	CGFloat aspectRatio = (CGFloat)CGImageGetWidth(expectedImage) / (CGFloat)CGImageGetHeight(expectedImage);
	CGSize size;
	if (aspectRatio >= 1) {
		size = CGSizeMake(CGRectGetWidth(_sut.bounds), CGRectGetHeight(_sut.bounds) / aspectRatio);
	} else {
		size = CGSizeMake(CGRectGetWidth(_sut.bounds) * aspectRatio, CGRectGetHeight(_sut.bounds));
	}
	NSValue *expectedSize = [NSValue valueWithSize:size];

	[_sut setImage:expectedImage];

	XCTAssertEqualObjects([NSValue valueWithSize:_sut.imageLayer.bounds.size], expectedSize);
	CGImageRelease(expectedImage);
}

@end
