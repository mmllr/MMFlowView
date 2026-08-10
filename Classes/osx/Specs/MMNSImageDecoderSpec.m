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
//  MMNSImageDecoderSpec.m
//
//  Created by Markus Müller on 17.12.13.
//  Copyright 2014 www.isnotnil.com. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MMNSImageDecoder.h"
#import "MMMacros.h"

@interface MMNSImageDecoderSpec : XCTestCase

@end

@implementation MMNSImageDecoderSpec
{
	MMNSImageDecoder *_sut;
	CGImageRef _imageRef;
	NSImage *_testImage;
}

static const NSUInteger expectedImageSize = 100;

- (void)setUp
{
	[super setUp];
	NSURL *testImageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TestImage01" withExtension:@"jpg"];
	_testImage = [[NSImage alloc] initWithContentsOfURL:testImageURL];
}

- (void)tearDown
{
	_sut = nil;
	_imageRef = NULL;
	_testImage = nil;
	[super tearDown];
}

- (void)testThrowsWhenNotCreatedWithDesignatedInitializer
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSImageDecoder alloc] init]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithNilItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSImageDecoder alloc] initWithItem:nil maxPixelSize:expectedImageSize]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithZeroMaximumPixelSize
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:0]), NSException, NSInternalInconsistencyException);
}

- (void)testThrowsWhenCreatedWithInvalidItem
{
	XCTAssertThrowsSpecificNamed((_sut = [[MMNSImageDecoder alloc] initWithItem:@"Test" maxPixelSize:expectedImageSize]), NSException, NSInternalInconsistencyException);
}

- (void)testValidInstanceExists
{
	_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:expectedImageSize];
	XCTAssertNotNil(_sut);
}

- (void)testValidInstanceConformsToDecoderProtocol
{
	_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut conformsToProtocol:@protocol(MMImageDecoderProtocol)]);
}

- (void)testValidInstanceRespondsToProtocolSelectors
{
	_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:expectedImageSize];
	XCTAssertTrue([_sut respondsToSelector:@selector(initWithItem:maxPixelSize:)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(CGImage)]);
	XCTAssertTrue([_sut respondsToSelector:@selector(image)]);
}

- (void)testCGImageLoadsAnImage
{
	_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertTrue(_imageRef != NULL);
}

- (void)testCGImageDimensionsAreLimited
{
	_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:expectedImageSize];
	_imageRef = _sut.CGImage;
	XCTAssertLessThanOrEqual(CGImageGetWidth(_imageRef), (size_t)100);
	XCTAssertLessThanOrEqual(CGImageGetHeight(_imageRef), (size_t)100);
}

- (void)testImageReturnsTheImageItWasCreatedFrom
{
	_sut = [[MMNSImageDecoder alloc] initWithItem:_testImage maxPixelSize:expectedImageSize];
	XCTAssertEqualObjects(_sut.image, _testImage);
}

@end
