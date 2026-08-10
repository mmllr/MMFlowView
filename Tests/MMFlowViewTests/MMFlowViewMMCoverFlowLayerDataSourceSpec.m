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
//  MMFlowViewMMCoverFlowLayerDataSourceSpec.m
//
//  Created by Markus Müller on 11.03.14.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMFlowView+MMCoverFlowLayerDataSource.h"
#import "MMCoverFlowLayer.h"
#import "MMFlowView_Private.h"
#import "MMFlowViewImageFactory.h"
#import "MMMacros.h"
#import "MMCoverFlowLayout.h"
#import "MMScrollBarLayer.h"
#import "MMFlowViewImageCache.h"
#import "MMTestImageItem.h"
#import "MMFlowViewTestDoubles.h"

@interface MMFlowViewMMCoverFlowLayerDataSourceSpec : XCTestCase

@end

@implementation MMFlowViewMMCoverFlowLayerDataSourceSpec
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

- (void)testConformsToCoverFlowLayerDataSourceProtocol
{
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMCoverFlowLayerDataSource)]);
}

- (void)testRespondsToDataSourceSelectors
{
	XCTAssertTrue([_sut respondsToSelector:@selector(coverFlowLayer:contentLayerForIndex:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(coverFlowLayerWillRelayout:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(coverFlowLayerDidRelayout:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(coverFlowLayer:willShowLayer:atIndex:)]);
}

- (void)testIsTheDatasourceForTheCoverFlowLayer
{
	XCTAssertEqualObjects(_sut, _sut.coverFlowLayer.dataSource);
}

- (void)testCoverFlowLayerWillRelayoutDoesNotThrow
{
	_sut.imageFactory = [[MMFlowViewImageFactory alloc] init];
	XCTAssertNoThrow([_sut coverFlowLayerWillRelayout:_sut.coverFlowLayer]);
}

- (void)testCoverFlowLayerDidRelayoutDoesNotThrow
{
	XCTAssertNoThrow([_sut coverFlowLayerDidRelayout:_sut.coverFlowLayer]);
}

- (void)testContentLayerForIndexReturnsALayer
{
	MMCoverFlowLayer *layer = [[MMCoverFlowLayer alloc] initWithLayout:[[MMCoverFlowLayout alloc] init]];
	CALayer *contentLayer = [_sut coverFlowLayer:layer contentLayerForIndex:0];
	XCTAssertNotNil(contentLayer);
	XCTAssertNotNil(contentLayer.contents);
	XCTAssertEqualObjects(contentLayer.contentsGravity, kCAGravityResizeAspectFill);
	XCTAssertEqualObjects(contentLayer.actions[@"bounds"], [NSNull null]);
	XCTAssertEqualObjects(contentLayer.actions[@"contents"], [NSNull null]);
}

// DISABLED: coverFlowLayer:willShowLayer:atIndex: was verified with mocked image
// factory, image cache, and content adapter to trace the asynchronous image
// decoding pipeline (maxImageSize forwarding, cache lookups, completion block
// side effects like setupTrackingAreas). These interactions require intercepting
// the factory's completion path and are not testable with plain XCTest without a
// mocking framework. The synchronous content layer creation is covered above.

@end
