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
//  MMQuickLookImageDecoderSpec.m
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2014 https://codeberg.org/mmllr/MMFlowView.git. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MMTestFixtures.h"

#import "MMQuickLookImageDecoder.h"
#import "MMMacros.h"

@interface MMQuickLookImageDecoderSpec : XCTestCase

@end

@implementation MMQuickLookImageDecoderSpec
{
	MMQuickLookImageDecoder *_sut;
	CGImageRef _imageRef;
	NSURL *_testImageURL;
	NSString *_testImagePath;
}

static const NSUInteger expectedImageSize = 100;

- (void)setUp
{
	[super setUp];
	_testImageURL = MMTestFixtureURL(@"TestImage01", @"jpg");
	_testImagePath = [_testImageURL path];
}

- (void)tearDown
{
	_sut = nil;
	_imageRef = NULL;
	_testImageURL = nil;
	_testImagePath = nil;
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMQuickLookImageDecoder alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMQuickLookImageDecoder alloc] initWithItem:nil maxPixelSize:expectedImageSize]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithZeroMaximumPixelSize
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:0]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInvalidItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMQuickLookImageDecoder alloc] initWithItem:[NSColor blueColor] maxPixelSize:expectedImageSize]), NSException, NSInternalInconsistencyException);
}

- (void)testURLInstanceExists
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut);
}

- (void)testURLInstanceConformsToDecoderProtocol
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
}

- (void)testURLInstanceRespondsToProtocolSelectors
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut respondsToSelector:@selector(CGImage)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(image)]);
}

- (void)testURLCGImageLoadsAnImage
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testURLCGImageDimensionsAreLimited
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testURLImageLoadsAnImage
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImageURL maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut.image);
}

- (void)testPathInstanceExists
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImagePath maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut);
}

- (void)testPathInstanceConformsToDecoderProtocol
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImagePath maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
}

- (void)testPathInstanceRespondsToProtocolSelectors
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImagePath maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut respondsToSelector:@selector(CGImage)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(image)]);
}

- (void)testPathCGImageLoadsAnImage
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImagePath maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testPathCGImageDimensionsAreLimited
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImagePath maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testPathImageLoadsAnImage
{
	_sut = [[MMQuickLookImageDecoder alloc] initWithItem:_testImagePath maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut.image);
}

@end
